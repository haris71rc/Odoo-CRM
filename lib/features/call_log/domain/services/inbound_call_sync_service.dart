import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:odoocrm/features/call_log/data/datasource/inbound_call_sync_store.dart';
import 'package:odoocrm/features/call_log/data/services/device_call_reader.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/services/growth_call_log_service.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';

/// Resolves the CRM lead for an inbound caller number. Null when none match.
///
/// Throw to postpone that call until the next sync instead of logging it
/// with no lead.
typedef InboundLeadLookup = Future<int?> Function(String phoneNumber);

/// Scans Android CallLog for inbound/missed calls and enqueues Growth POSTs.
///
/// Reliability contract:
/// - Advance the sync cursor only after durable outbox enqueue.
/// - HTTP success/failure is owned by [GrowthCallLogService] / outbox.
/// - First run posts inbound calls inside [recentLookback], not full history.
/// - A cursor that jumped to "now" still retries unacked calls in that window,
///   so a missed call that arrived while the app was closed is not dropped.
class InboundCallSyncService {
  InboundCallSyncService({
    required DeviceCallReader deviceCallReader,
    required GrowthCallLogService growthCallLogService,
    required InboundCallSyncStore syncStore,
    InboundLeadLookup? resolveLeadId,
  })  : _reader = deviceCallReader,
        _growth = growthCallLogService,
        _store = syncStore,
        _resolveLeadId = resolveLeadId;

  final DeviceCallReader _reader;
  final GrowthCallLogService _growth;
  final InboundCallSyncStore _store;
  final InboundLeadLookup? _resolveLeadId;

  /// Re-query overlap so OEM delayed rows / same-ms collisions are not missed.
  static const overlap = Duration(seconds: 90);

  /// Calls in this window are posted even when the cursor was stamped at "now"
  /// and therefore sits ahead of a call that arrived while the app was closed.
  static const recentLookback = Duration(hours: 12);

  /// Soft cap per sync pass so a backlog cannot flood the Growth outbox.
  static const maxBatch = 50;

  Future<void>? _inFlight;

  /// Runs a single-flight inbound scan. Safe to call from startup + resume.
  Future<void> syncIfNeeded({String? salesperson}) {
    return _inFlight ??= _sync(salesperson: salesperson).whenComplete(() {
      _inFlight = null;
    });
  }

  Future<void> _sync({String? salesperson}) async {
    if (!_reader.isSupported) return;

    final permitted = await _reader.ensurePermission();
    if (!permitted) {
      _log('InboundCallSync: skipped — no READ_CALL_LOG permission');
      return;
    }

    var cursor = await _store.load();
    if (!cursor.initialized) {
      cursor = InboundCallSyncCursor.baselineAt(
        DateTime.now().subtract(recentLookback),
      );
      await _store.save(cursor);
      _log(
        'InboundCallSync: initialized cursor at_ms=${cursor.lastTimestampMs} '
        'lookback_hours=${recentLookback.inHours}',
      );
    }

    final now = DateTime.now();
    final recentSince = now.subtract(recentLookback);
    final cursorSince =
        DateTime.fromMillisecondsSinceEpoch(cursor.lastTimestampMs)
            .subtract(overlap);
    final since = cursorSince.isBefore(recentSince) ? cursorSince : recentSince;
    final events = await _reader.findInboundCallsSince(since: since);
    final forward = events
        .where((event) => isAfterCursor(event, cursor))
        .take(maxBatch)
        .toList(growable: false);
    final behindCursor = events
        .where(
          (event) =>
              !isAfterCursor(event, cursor) && !event.at.isBefore(recentSince),
        )
        .toList(growable: false);
    // Newest rows the cursor jumped over (first open after a missed call).
    final recovered = behindCursor.length <= maxBatch
        ? behindCursor
        : behindCursor.sublist(behindCursor.length - maxBatch);
    final candidates = [...forward, ...recovered];

    if (candidates.isEmpty) {
      _log('InboundCallSync: no new inbound rows');
      return;
    }

    final leadCache = <String, int?>{};
    DeviceCallEvent? lastForward;
    for (final event in candidates) {
      int? leadId;
      final phone = event.phoneNumber?.trim() ?? '';
      if (phone.isNotEmpty && _resolveLeadId != null) {
        try {
          if (leadCache.containsKey(phone)) {
            leadId = leadCache[phone];
          } else {
            leadId = await _resolveLeadId!(phone);
            leadCache[phone] = leadId;
          }
        } catch (e) {
          _log('InboundCallSync: lead lookup failed ($e); retry next open');
          break;
        }
      }
      await _growth.enqueueInboundCall(
        callEvent: CallLog(
          lastCallDate: event.at,
          duration: event.duration,
          status: event.status,
        ),
        salesperson: salesperson,
        leadId: leadId,
        androidCallLogId: event.androidCallLogId,
        phoneNumber: event.phoneNumber,
        flush: false,
      );
      if (isAfterCursor(event, cursor)) {
        lastForward = event;
      }
    }

    if (lastForward == null) {
      if (recovered.isNotEmpty) {
        unawaited(_growth.flushPending());
      }
      return;
    }

    final next = cursor.copyWith(
      lastTimestampMs: lastForward.at.millisecondsSinceEpoch,
      lastAndroidCallId: cursorIdFor(lastForward),
      initialized: true,
    );
    await _store.save(next);
    // Single drain after the full batch is durable — avoids outbox races.
    unawaited(_growth.flushPending());
    _log(
      'InboundCallSync: enqueued ${candidates.length} inbound call(s); '
      'cursor_ms=${next.lastTimestampMs} id=${next.lastAndroidCallId}',
    );
  }

  /// True when [event] is strictly after the durable cursor watermark.
  static bool isAfterCursor(
    DeviceCallEvent event,
    InboundCallSyncCursor cursor,
  ) {
    final ts = event.at.millisecondsSinceEpoch;
    if (ts > cursor.lastTimestampMs) return true;
    if (ts < cursor.lastTimestampMs) return false;
    return _compareAndroidIds(cursorIdFor(event), cursor.lastAndroidCallId) >
        0;
  }

  /// Stable cursor tie-breaker: prefer Android `_ID`, else phone+duration.
  static String cursorIdFor(DeviceCallEvent event) {
    final androidId = event.androidCallLogId?.trim() ?? '';
    if (androidId.isNotEmpty) return androidId;
    final phone = event.phoneNumber?.trim() ?? '';
    final duration = CallLogDuration.parseToSeconds(event.duration);
    return 'fallback:$phone:$duration';
  }

  /// Numeric compare when both ids parse as ints; otherwise lexicographic.
  static int _compareAndroidIds(String a, String b) {
    final ai = int.tryParse(a);
    final bi = int.tryParse(b);
    if (ai != null && bi != null) return ai.compareTo(bi);
    return a.compareTo(b);
  }

  void _log(String message) {
    debugPrint(message);
  }
}
