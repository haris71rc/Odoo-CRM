import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';

/// Merges a new outbound call event into existing Odoo call-log properties.
class CallLogUpdater {
  CallLogUpdater._();

  /// Ignore device calls within this window of the last saved call to avoid
  /// double-counting the same CRM-initiated call (dialer timestamp skew).
  static const duplicateWindow = Duration(seconds: 45);

  /// Applies an outbound call from the logged-in user (app dialer / outcome sheet).
  static CallLog applyOutboundCall({
    required CallLog existing,
    required CallLog callEvent,
    required DateTime? leadCreatedAt,
  }) {
    final eventDate = callEvent.lastCallDate;
    final isFirstOutbound = existing.firstCallDate == null;
    final firstDate = existing.firstCallDate ?? eventDate;

    double? responseTime = existing.responseTimeMinutes;
    if (isFirstOutbound && eventDate != null && leadCreatedAt != null) {
      final leadLocal = leadCreatedAt.toLocal();
      final callLocal = eventDate.toLocal();
      final diffMs = callLocal.difference(leadLocal).inMilliseconds;
      responseTime = diffMs <= 0 ? 0 : diffMs / 60000.0;
    }

    final previousTotal = existing.totalDuration ?? existing.duration;
    final eventSeconds = CallLogDuration.parseToSeconds(callEvent.duration);
    final totalDuration = eventSeconds > 0
        ? CallLogDuration.add(previousTotal, callEvent.duration)
        : previousTotal;

    return CallLog(
      firstCallDate: firstDate,
      lastCallDate: eventDate ?? existing.lastCallDate,
      duration: eventSeconds > 0
          ? callEvent.duration
          : CallLogDuration.formatFromSeconds(0),
      status: callEvent.status ?? existing.status,
      totalDuration: totalDuration,
      totalInboundCalls: existing.totalInboundCalls ?? 0,
      totalOutboundCalls: (existing.totalOutboundCalls ?? 0) + 1,
      responseTimeMinutes: responseTime,
    );
  }

  /// Updates inbound count when the device call log reports more incoming calls.
  static CallLog applyInboundSync({
    required CallLog existing,
    required int deviceInboundCount,
  }) {
    final current = existing.totalInboundCalls ?? 0;
    if (deviceInboundCount <= current) return existing;
    return existing.copyWith(totalInboundCalls: deviceInboundCount);
  }

  /// Syncs dialer-made calls discovered when Lead Detail opens.
  ///
  /// Outbound events older than / near the last saved call are skipped.
  /// Newer outbound events are applied oldest-first. Inbound count is maxed.
  static CallLog applyDeviceSync({
    required CallLog existing,
    required List<DeviceCallEvent> deviceCalls,
    required DateTime? leadCreatedAt,
  }) {
    var current = existing;

    final outbound = deviceCalls.where((e) => e.isOutbound).toList()
      ..sort((a, b) => a.at.compareTo(b.at));

    for (final event in outbound) {
      if (!shouldApplyDeviceOutbound(
        deviceAt: event.at,
        lastCallDate: current.lastCallDate,
      )) {
        continue;
      }

      current = applyOutboundCall(
        existing: current,
        callEvent: CallLog(
          lastCallDate: event.at,
          duration: event.duration,
          status: event.status,
        ),
        leadCreatedAt: leadCreatedAt,
      );
    }

    final inboundCount = deviceCalls.where((e) => e.isInbound).length;
    current = applyInboundSync(
      existing: current,
      deviceInboundCount: inboundCount,
    );

    return current;
  }

  /// `true` when [deviceAt] is a new outbound call not already stored in Odoo.
  static bool shouldApplyDeviceOutbound({
    required DateTime deviceAt,
    required DateTime? lastCallDate,
  }) {
    if (lastCallDate == null) return true;

    final deviceLocal = deviceAt.toLocal();
    final lastLocal = lastCallDate.toLocal();
    final delta = deviceLocal.difference(lastLocal).abs();

    // Same call already saved from CRM dial flow (timestamp skew).
    if (delta <= duplicateWindow) return false;

    return deviceLocal.isAfter(lastLocal);
  }
}
