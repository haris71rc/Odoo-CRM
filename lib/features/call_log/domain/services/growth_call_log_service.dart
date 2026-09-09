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
import 'package:odoocrm/features/call_log/domain/utils/growth_call_retry_policy.dart';

/// Production Growth BI writer: durable outbox + stable idempotency keys.
///
/// Flow:
/// 1. Persist the full POST payload locally (outbox) before / while posting.
/// 2. POST `/api/v1/calls/log`.
/// 3. On success → remove from outbox (mark acked).
/// 4. On retryable failure → keep pending; retry on next drain / app launch.
/// 5. On permanent client error → dead-letter (still persisted, not retried).
///
/// Duplicate protection relies on deterministic `call_id` (UUID v5). If the
/// server already accepted a call but the client never saw the response, the
/// retry reuses the same `call_id`; the API may return `duplicate: true`.
/// Exactly-once delivery cannot be guaranteed by the client alone.
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

  /// Soft cap used only to bound in-session backoff growth — never deletes
  /// retryable items from the durable queue.
  static const maxBackoffAttempt = 8;

  Future<void>? _drainFuture;
  var _drainRequested = false;
  Timer? _retryTimer;

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
        _log('CallLogUpload: skip invalid lead_id=$leadId');
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
          _log(
            'CallLogRetryQueue: skip already-acked call_id=${ack.callId} '
            'lead_id=$leadId',
          );
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
        _log('CallLogUpload: skip invalid payload call_id=$callId');
        return;
      }

      await _outbox.upsert(
        GrowthOutboxItem(
          request: request,
          attempts: 0,
          enqueuedAt: now,
          status: GrowthOutboxStatus.pending,
        ),
      );
      _log('CallLogRetryQueue: Added call $callId lead_id=$leadId');
      unawaited(flushPending());
    } catch (e, st) {
      _log('CallLogRetryQueue: enqueue failed error=$e\n$st');
    }
  }

  /// Drains the durable outbox with the latest Odoo `session_id`.
  ///
  /// Safe to call concurrently — only one drain runs at a time; extra calls
  /// coalesce into a follow-up pass.
  Future<void> flushPending() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _drainRequested = true;
    return _drainFuture ??= _drainLoop().whenComplete(() {
      _drainFuture = null;
    });
  }

  /// Cancels in-session backoff wakeups (e.g. tests / logout).
  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<void> _drainLoop() async {
    do {
      _drainRequested = false;
      await _drainOnce();
    } while (_drainRequested);
    await _scheduleWakeForBackoff();
    _log('CallLogRetryQueue: Queue processing completed');
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
        _log(
          'CallLogRetryQueue: drain paused — no session_id '
          '(call_id=${item.callId})',
        );
        return;
      }

      final request = item.request.copyWith(sessionId: sessionId);
      _log('CallLogRetryQueue: Processing ${item.callId}');
      _log('CallLogUpload: POST started call_id=${item.callId}');

      await _outbox.update(
        item.copyWith(
          request: request,
          status: GrowthOutboxStatus.processing,
          lastAttemptAt: now,
        ),
      );

      try {
        final result = await _datasource.logCall(request);
        // Delete from queue only after the API confirms success.
        await _outbox.markAcked(item.copyWith(request: request));
        _log(
          'CallLogUpload: POST succeeded call_id=${request.callId} '
          'duplicate=${result['duplicate']} '
          'odoo_write_status=${result['odoo_write_status']}',
        );
        _log('CallLogRetryQueue: Retry succeeded for ${item.callId}');
      } on AuthFailure catch (e) {
        // 401: do not infinite-retry. Keep pending until re-login flush.
        await _outbox.update(
          item.copyWith(
            request: request,
            attempts: item.attempts + 1,
            lastError: e.message,
            lastAttemptAt: now,
            nextAttemptAt: now.add(const Duration(seconds: 30)),
            status: GrowthOutboxStatus.failed,
          ),
        );
        _log(
          'CallLogUpload: POST failed with status 401 call_id=${item.callId} '
          '— waiting for re-login',
        );
        _log('CallLogRetryQueue: Retry failed for ${item.callId}');
        return;
      } on NetworkFailure catch (e) {
        _log(
          'CallLogUpload: POST failed with network error '
          'call_id=${item.callId}',
        );
        await _scheduleRetry(item, request, e.message, now);
        _log('CallLogRetryQueue: Retryable failure, saving to queue');
        // Global connectivity problem — leave remaining items pending.
        return;
      } on ApiFailure catch (e) {
        _log(
          'CallLogUpload: POST failed with status ${e.statusCode} '
          'call_id=${item.callId}',
        );
        if (GrowthCallRetryPolicy.isRetryableStatus(e.statusCode)) {
          await _scheduleRetry(item, request, e.message, now);
          _log(
            'CallLogRetryQueue: Retryable failure, saving to queue '
            'status=${e.statusCode}',
          );
          if (GrowthCallRetryPolicy.isGlobalTransientStatus(e.statusCode)) {
            return;
          }
          continue;
        }
        // Permanent / client errors — dead-letter, continue other items.
        await _outbox.markDead(
          item.copyWith(
            request: request,
            attempts: item.attempts + 1,
            lastError: '${e.statusCode}: ${e.message}',
            lastAttemptAt: now,
            status: GrowthOutboxStatus.failed,
            deadLetter: true,
          ),
        );
        _log(
          'CallLogRetryQueue: dead-letter call_id=${item.callId} '
          'status=${e.statusCode}',
        );
      } catch (e) {
        _log('CallLogUpload: POST failed unexpected error call_id=${item.callId}');
        await _scheduleRetry(item, request, e.toString(), now);
        _log('CallLogRetryQueue: Retryable failure, saving to queue');
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
    // Never delete retryable call logs for attempt count — only back off.
    final delay = GrowthCallRetryPolicy.backoffDelay(attempts);
    await _outbox.update(
      item.copyWith(
        request: request,
        attempts: attempts,
        lastError: error,
        lastAttemptAt: now,
        nextAttemptAt: now.add(delay),
        status: GrowthOutboxStatus.failed,
        deadLetter: false,
      ),
    );
    _log(
      'CallLogRetryQueue: Retry failed for ${item.callId} attempt=$attempts '
      'next_in=${delay.inSeconds}s',
    );
    if (attempts >= maxBackoffAttempt) {
      _log(
        'CallLogRetryQueue: high attempt count for ${item.callId} '
        '($attempts) — still kept for next app launch',
      );
    }
  }

  /// Wakes the drain when the soonest [GrowthOutboxItem.nextAttemptAt] is due.
  Future<void> _scheduleWakeForBackoff() async {
    _retryTimer?.cancel();
    _retryTimer = null;

    final pending = await _outbox.loadPending();
    final now = DateTime.now().toUtc();
    DateTime? soonest;
    for (final item in pending) {
      if (item.deadLetter) continue;
      final next = item.nextAttemptAt;
      if (next == null) continue;
      if (!next.isAfter(now)) {
        // Already due — kick another drain without waiting.
        unawaited(flushPending());
        return;
      }
      if (soonest == null || next.isBefore(soonest)) {
        soonest = next;
      }
    }
    if (soonest == null) return;

    final wait = soonest.difference(now) + const Duration(milliseconds: 50);
    _retryTimer = Timer(wait, () {
      unawaited(flushPending());
    });
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
    debugPrint(message);
  }
}
