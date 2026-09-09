import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:odoocrm/core/constants/app_tenant.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_log_datasource.dart';
import 'package:odoocrm/features/call_log/data/datasource/growth_call_outbox.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/growth_call_log_request.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';
import 'package:odoocrm/features/call_log/domain/utils/growth_call_id.dart';

/// Production Growth BI writer: durable outbox + stable idempotency keys.
///
/// - Persists each call before POST (survives kill / offline / 502 / 401).
/// - Reuses `call_id` across CRM dial + device sync within the duplicate window.
/// - Drains the outbox in the background; [flushPending] after login / cold start.
class GrowthCallLogService {
  GrowthCallLogService({
    required GrowthCallLogDatasource datasource,
    required SecureStorageService secureStorage,
    GrowthCallOutbox? outbox,
  })  : _datasource = datasource,
        _secureStorage = secureStorage,
        _outbox = outbox ?? GrowthCallOutbox(secureStorage);

  final GrowthCallLogDatasource _datasource;
  final SecureStorageService _secureStorage;
  final GrowthCallOutbox _outbox;

  /// Soft cap on transient retries before backing off in the outbox.
  static const maxDrainAttempts = 8;

  Future<void>? _drainFuture;
  var _drainRequested = false;

  /// Enqueues an outbound call and kicks a background drain.
  ///
  /// Completes after the local outbox write (not after HTTP).
  Future<void> enqueueOutboundCall({
    required int leadId,
    required CallLog callEvent,
    String? salesperson,
  }) {
    return enqueueCall(
      leadId: leadId,
      callEvent: callEvent,
      direction: 'outbound',
      salesperson: salesperson,
    );
  }

  /// @nodoc Compatibility alias used by older call sites / tests.
  Future<void> logOutboundCall({
    required int leadId,
    required CallLog callEvent,
    String? salesperson,
  }) =>
      enqueueOutboundCall(
        leadId: leadId,
        callEvent: callEvent,
        salesperson: salesperson,
      );

  Future<void> enqueueCall({
    required int leadId,
    required CallLog callEvent,
    required String direction,
    String? salesperson,
  }) async {
    try {
      if (leadId <= 0) {
        _log('skip invalid lead_id=$leadId');
        return;
      }

      final normalizedDirection =
          direction == 'inbound' ? 'inbound' : 'outbound';
      final callAt = callEvent.lastCallDate ?? DateTime.now();
      final known = await _knownFingerprints();

      // Already accepted by Growth for this real-world call.
      for (final ack in known.acked) {
        if (ack.leadId == leadId &&
            ack.direction == normalizedDirection &&
            ack.callAt.toUtc().difference(callAt.toUtc()).abs() <=
                GrowthCallId.dedupeWindow) {
          _log('skip already-acked call_id=${ack.callId} lead_id=$leadId');
          return;
        }
      }

      final callId = GrowthCallId.resolve(
        leadId: leadId,
        direction: normalizedDirection,
        callAt: callAt,
        known: [
          for (final p in known.pending)
            (
              leadId: p.request.leadId,
              direction: p.request.direction,
              callAt: p.request.callDatetime,
              callId: p.callId,
            ),
          for (final a in known.acked)
            (
              leadId: a.leadId,
              direction: a.direction,
              callAt: a.callAt,
              callId: a.callId,
            ),
        ],
      );

      final sessionId = await _secureStorage.getSessionId() ?? '';
      final tenant =
          await _secureStorage.getTenantId() ?? AppTenant.fallback.id;
      final now = DateTime.now().toUtc();
      final durationSeconds =
          CallLogDuration.parseToSeconds(callEvent.duration);
      final status = _normalizeStatus(callEvent.status);

      final request = GrowthCallLogRequest(
        tenant: tenant,
        sessionId: sessionId,
        leadId: leadId,
        callId: callId,
        salesperson: _resolveSalesperson(salesperson),
        callDatetime: callAt.toUtc(),
        durationSeconds: durationSeconds,
        direction: normalizedDirection,
        status: status,
        createdAt: now,
      );

      if (!_isValidPayload(request)) {
        _log('skip invalid payload call_id=$callId');
        return;
      }

      await _outbox.upsert(
        GrowthOutboxItem(
          request: request,
          attempts: 0,
          enqueuedAt: now,
        ),
      );
      _log('enqueued call_id=$callId lead_id=$leadId status=$status');
      unawaited(flushPending());
    } catch (e, st) {
      _log('enqueue failed error=$e\n$st');
    }
  }

  /// Drains the durable outbox with the latest Odoo `session_id`.
  Future<void> flushPending() {
    _drainRequested = true;
    return _drainFuture ??= _drainLoop().whenComplete(() {
      _drainFuture = null;
    });
  }

  Future<void> _drainLoop() async {
    do {
      _drainRequested = false;
      await _drainOnce();
    } while (_drainRequested);
  }

  Future<void> _drainOnce() async {
    final pending = await _outbox.loadPending();
    if (pending.isEmpty) return;

    final sessionId = await _secureStorage.getSessionId();
    final now = DateTime.now().toUtc();

    for (final item in pending) {
      if (item.deadLetter) continue;
      if (item.nextAttemptAt != null && item.nextAttemptAt!.isAfter(now)) {
        continue;
      }

      if (sessionId == null || sessionId.isEmpty) {
        _log('drain paused — no session_id (call_id=${item.callId})');
        return;
      }

      final request = item.request.copyWith(sessionId: sessionId);
      try {
        final result = await _datasource.logCall(request);
        await _outbox.markAcked(item.copyWith(request: request));
        _log(
          'posted call_id=${request.callId} '
          'duplicate=${result['duplicate']} '
          'odoo_write_status=${result['odoo_write_status']}',
        );
      } on AuthFailure catch (e) {
        // Keep in outbox — flush again after the user re-authenticates.
        await _outbox.update(
          item.copyWith(
            request: request,
            attempts: item.attempts + 1,
            lastError: e.message,
            nextAttemptAt: now.add(const Duration(seconds: 30)),
          ),
        );
        _log('401 session expired call_id=${item.callId} — waiting for re-login');
        return;
      } on NetworkFailure catch (e) {
        await _scheduleRetry(item, request, e.message, now);
      } on ApiFailure catch (e) {
        if (e.statusCode == 502) {
          await _scheduleRetry(item, request, e.message, now);
          continue;
        }
        // 404 / 422 / other: do not spin forever.
        await _outbox.markDead(
          item.copyWith(
            request: request,
            attempts: item.attempts + 1,
            lastError: '${e.statusCode}: ${e.message}',
            deadLetter: true,
          ),
        );
        _log(
          'dead-letter call_id=${item.callId} '
          'status=${e.statusCode} message=${e.message}',
        );
      } catch (e) {
        await _scheduleRetry(item, request, e.toString(), now);
      }
    }
  }

  Future<void> _scheduleRetry(
    GrowthOutboxItem item,
    GrowthCallLogRequest request,
    String error,
    DateTime now,
  ) async {
    final attempts = item.attempts + 1;
    if (attempts >= maxDrainAttempts) {
      await _outbox.markDead(
        item.copyWith(
          request: request,
          attempts: attempts,
          lastError: error,
          deadLetter: true,
        ),
      );
      _log('dead-letter after $attempts attempts call_id=${item.callId}');
      return;
    }

    final delay = Duration(seconds: (1 << (attempts - 1)).clamp(1, 60));
    await _outbox.update(
      item.copyWith(
        request: request,
        attempts: attempts,
        lastError: error,
        nextAttemptAt: now.add(delay),
      ),
    );
    _log(
      'retry scheduled call_id=${item.callId} attempt=$attempts '
      'in ${delay.inSeconds}s',
    );
  }

  Future<({List<GrowthOutboxItem> pending, List<GrowthAckedCall> acked})>
      _knownFingerprints() async {
    final pending = await _outbox.loadPending();
    final acked = await _outbox.loadAcked();
    return (pending: pending, acked: acked);
  }

  bool _isValidPayload(GrowthCallLogRequest request) {
    if (request.leadId <= 0) return false;
    if (request.callId.trim().isEmpty) return false;
    if (request.tenant.trim().isEmpty) return false;
    if (request.activityType != 'call') return false;
    if (request.direction != 'inbound' && request.direction != 'outbound') {
      return false;
    }
    if (request.durationSeconds < 0) return false;
    if (request.status.trim().isEmpty) return false;
    return true;
  }

  String _normalizeStatus(String? status) {
    final trimmed = status?.trim() ?? '';
    if (trimmed.isEmpty) return 'unknown';
    return trimmed;
  }

  String? _resolveSalesperson(String? salesperson) {
    final trimmed = salesperson?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  void _log(String message) {
    debugPrint('GrowthCallLog: $message');
  }
}
