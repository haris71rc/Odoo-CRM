import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/entities/lead_call_sync_cursor.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_updater.dart';

/// Result of catching the Odoo call log up to the Android dialer.
class CallCatchUp {
  const CallCatchUp({
    required this.log,
    required this.newOutbound,
    required this.cursor,
    required this.appliedCount,
  });

  final CallLog log;
  final List<DeviceCallEvent> newOutbound;
  final LeadCallSyncCursor cursor;

  /// Outbound rows inserted plus inbound rows added.
  final int appliedCount;
}

/// Syncs every device call after the last call already stored in Odoo.
///
/// The last saved call is refreshed in place (duration / status). Every other
/// Android row after that time is applied, including calls a few seconds apart.
/// Rows at or before the saved time stay in the existing totals.
class CallLogCatchUp {
  CallLogCatchUp._();

  /// Re-read window so a dialer timestamp slightly before the CRM clock
  /// still matches the saved call.
  static const lookback = Duration(seconds: 90);

  static const _skew = Duration(seconds: 2);
  static const _maxKeys = 400;

  static DateTime? cursorOf(CallLog log) => log.lastCallDate ?? log.firstCallDate;

  /// Android query start: last synced time minus [lookback], or [leadCreatedAt].
  static DateTime? querySince({
    required CallLog log,
    required DateTime? leadCreatedAt,
  }) {
    final cursor = cursorOf(log);
    if (cursor == null) return leadCreatedAt;
    return cursor.subtract(lookback);
  }

  static String eventKey(DeviceCallEvent event) {
    final id = event.androidCallLogId?.trim() ?? '';
    if (id.isNotEmpty) return 'id:$id';
    final seconds = CallLogDuration.parseToSeconds(event.duration);
    final direction = event.isOutbound
        ? 'out'
        : event.isInbound
            ? 'in'
            : 'other';
    final phone = event.phoneNumber?.trim() ?? '';
    return '$direction|${event.at.millisecondsSinceEpoch}|$seconds|$phone';
  }

  static CallCatchUp apply({
    required CallLog existing,
    required List<DeviceCallEvent> deviceCalls,
    required DateTime? leadCreatedAt,
    LeadCallSyncCursor remembered = LeadCallSyncCursor.empty,
  }) {
    final cursor = cursorOf(existing);
    final storedSeconds = CallLogDuration.parseToSeconds(existing.duration);
    final unique = _dedupe(deviceCalls);
    final storedRow = _storedOutbound(unique, cursor, storedSeconds);

    var current = existing;
    if (storedRow != null) {
      current = CallLogUpdater.overlayDialerDetails(
        existing: current,
        event: storedRow,
      );
    }

    final keys = <String>{...remembered.keys};
    if (storedRow != null) keys.add(eventKey(storedRow));

    final freshOutbound = <DeviceCallEvent>[];

    for (final event in unique) {
      if (!event.isOutbound) continue;
      if (storedRow != null && eventKey(event) == eventKey(storedRow)) {
        continue;
      }
      final key = eventKey(event);
      if (keys.contains(key)) continue;
      if (!_isAfterSavedCall(event.at, cursor)) continue;

      freshOutbound.add(event);
      current = CallLogUpdater.applyOutboundCall(
        existing: current,
        callEvent: CallLog(
          lastCallDate: event.at,
          duration: event.duration,
          status: event.status,
        ),
        leadCreatedAt: leadCreatedAt,
      );
      keys.add(key);
    }

    final storedInbound = existing.totalInboundCalls ?? 0;
    var inboundAdded = 0;
    if (!remembered.seeded) {
      // First catch-up sees the lead's full Android history. The stored
      // inbound total is already a lifetime count, so raise it — never add.
      final deviceInbound = unique.where((event) => event.isInbound).length;
      if (deviceInbound > storedInbound) {
        current = current.copyWith(totalInboundCalls: deviceInbound);
        inboundAdded = deviceInbound - storedInbound;
      }
      for (final event in unique) {
        if (event.isInbound) keys.add(eventKey(event));
      }
    } else {
      for (final event in unique) {
        if (!event.isInbound) continue;
        final key = eventKey(event);
        if (!keys.add(key)) continue;
        if (!_isAfterSavedCall(event.at, cursor)) continue;
        inboundAdded++;
      }
      if (inboundAdded > 0) {
        current = current.copyWith(
          totalInboundCalls: storedInbound + inboundAdded,
        );
      }
    }

    current = CallLogUpdater.repairIncomplete(
      existing: current,
      leadCreatedAt: leadCreatedAt,
    );

    return CallCatchUp(
      log: current,
      newOutbound: freshOutbound,
      appliedCount: freshOutbound.length + inboundAdded,
      cursor: LeadCallSyncCursor(
        keys: _trimKeys(keys),
        seeded: true,
      ),
    );
  }

  static bool _isAfterSavedCall(DateTime at, DateTime? cursor) {
    if (cursor == null) return true;
    return at.isAfter(cursor.subtract(_skew));
  }

  static DeviceCallEvent? _storedOutbound(
    List<DeviceCallEvent> events,
    DateTime? cursor,
    int storedSeconds,
  ) {
    if (cursor == null) return null;
    DeviceCallEvent? best;
    var bestDelta = 0;
    for (final event in events) {
      if (!event.isOutbound) continue;
      final seconds = CallLogDuration.parseToSeconds(event.duration);
      final same = CallLogUpdater.isSameStoredOutbound(
        deviceAt: event.at,
        anchor: cursor,
        storedDurationSeconds: storedSeconds,
        deviceDurationSeconds: seconds,
      );
      if (!same) continue;
      final delta = event.at.difference(cursor).abs().inMilliseconds;
      if (best == null || delta < bestDelta) {
        best = event;
        bestDelta = delta;
      }
    }
    return best;
  }

  static List<DeviceCallEvent> _dedupe(List<DeviceCallEvent> events) {
    final seen = <String>{};
    final unique = <DeviceCallEvent>[];
    final sorted = [...events]..sort((a, b) {
        final byTime = a.at.compareTo(b.at);
        if (byTime != 0) return byTime;
        return eventKey(a).compareTo(eventKey(b));
      });
    for (final event in sorted) {
      if (seen.add(eventKey(event))) unique.add(event);
    }
    return unique;
  }

  static Set<String> _trimKeys(Set<String> keys) {
    if (keys.length <= _maxKeys) return keys;
    return keys.skip(keys.length - _maxKeys).toSet();
  }
}
