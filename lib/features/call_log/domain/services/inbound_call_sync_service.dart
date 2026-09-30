import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:odoocrm/features/call_log/data/datasource/inbound_call_sync_store.dart';
import 'package:odoocrm/features/call_log/data/services/device_call_reader.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/services/growth_call_log_service.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';

/// Scans Android CallLog for inbound/missed calls and enqueues Growth POSTs.
///
/// Reliability contract:
/// - Advance the sync cursor only after durable outbox enqueue.
/// - HTTP success/failure is owned by [GrowthCallLogService] / outbox.
/// - First run is forward-only (no historical backfill).
class InboundCallSyncService {
  InboundCallSyncService({
    required DeviceCallReader deviceCallReader,
    required GrowthCallLogService growthCallLogService,
    required InboundCallSyncStore syncStore,
  })  : _reader = deviceCallReader,
        _growth = growthCallLogService,
        _store = syncStore;

  final DeviceCallReader _reader;
  final GrowthCallLogService _growth;
  final InboundCallSyncStore _store;

  /// Re-query overlap so OEM delayed rows / same-ms collisions are not missed.
  static const overlap = Duration(seconds: 90);

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
      cursor = InboundCallSyncCursor.baselineAt();
      await _store.save(cursor);
      _log(
        'InboundCallSync: initialized forward-only cursor '
        'at_ms=${cursor.lastTimestampMs}',
      );
      return;
    }

    final since = DateTime.fromMillisecondsSinceEpoch(cursor.lastTimestampMs)
        .subtract(overlap);
    final events = await _reader.findInboundCallsSince(since: since);
    final candidates = events
        .where((event) => isAfterCursor(event, cursor))
        .take(maxBatch)
        .toList(growable: false);

    if (candidates.isEmpty) {
      _log('InboundCallSync: no new inbound rows');
      return;
    }

    DeviceCallEvent? lastEnqueued;
    for (final event in candidates) {
      await _growth.enqueueInboundCall(
        callEvent: CallLog(
          lastCallDate: event.at,
          duration: event.duration,
          status: event.status,
        ),
        salesperson: salesperson,
        androidCallLogId: event.androidCallLogId,
        phoneNumber: event.phoneNumber,
        flush: false,
      );
      lastEnqueued = event;
    }

    if (lastEnqueued == null) return;

    final next = cursor.copyWith(
      lastTimestampMs: lastEnqueued.at.millisecondsSinceEpoch,
      lastAndroidCallId: cursorIdFor(lastEnqueued),
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
