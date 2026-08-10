import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';

/// Merges a new outbound call event into existing Odoo call-log properties.
class CallLogUpdater {
  CallLogUpdater._();

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
}
