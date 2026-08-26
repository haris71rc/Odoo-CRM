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
    final lastDate = eventDate ?? existing.lastCallDate ?? firstDate;

    double? responseTime = existing.responseTimeMinutes;
    if (firstDate != null &&
        leadCreatedAt != null &&
        (isFirstOutbound || responseTime == null || responseTime == 0)) {
      final diffMs = firstDate
          .toLocal()
          .difference(leadCreatedAt.toLocal())
          .inMilliseconds;
      responseTime = diffMs <= 0 ? 0 : diffMs / 60000.0;
    }

    final previousTotal = existing.totalDuration ?? existing.duration;
    final eventSeconds = CallLogDuration.parseToSeconds(callEvent.duration);
    final totalDuration = eventSeconds > 0
        ? CallLogDuration.add(previousTotal, callEvent.duration)
        : previousTotal;

    return CallLog(
      firstCallDate: firstDate,
      lastCallDate: lastDate,
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

  /// Fills Last / outbound / response when Odoo has a call but those fields
  /// were left at their empty defaults (0, false, unset).
  static CallLog repairIncomplete({
    required CallLog existing,
    DateTime? leadCreatedAt,
  }) {
    final first = existing.firstCallDate ?? existing.lastCallDate;
    final last = existing.lastCallDate ?? existing.firstCallDate;

    var outbound = existing.totalOutboundCalls ?? 0;
    if (_hasCallEvidence(existing) && outbound <= 0) {
      outbound = 1;
    }

    var response = existing.responseTimeMinutes;
    if (first != null &&
        leadCreatedAt != null &&
        (response == null || response == 0)) {
      final diffMs =
          first.toLocal().difference(leadCreatedAt.toLocal()).inMilliseconds;
      if (diffMs > 0) {
        response = diffMs / 60000.0;
      }
    }

    return CallLog(
      firstCallDate: first,
      lastCallDate: last,
      duration: existing.duration,
      status: existing.status,
      totalDuration: existing.totalDuration ?? existing.duration,
      totalInboundCalls: existing.totalInboundCalls ?? 0,
      totalOutboundCalls: outbound,
      responseTimeMinutes: response,
    );
  }

  static bool metricsChanged(CallLog before, CallLog after) {
    return after.lastCallDate != before.lastCallDate ||
        after.firstCallDate != before.firstCallDate ||
        after.duration != before.duration ||
        after.totalDuration != before.totalDuration ||
        after.totalOutboundCalls != before.totalOutboundCalls ||
        after.totalInboundCalls != before.totalInboundCalls ||
        after.status != before.status ||
        after.responseTimeMinutes != before.responseTimeMinutes;
  }

  static bool _hasCallEvidence(CallLog log) {
    return log.firstCallDate != null ||
        log.lastCallDate != null ||
        (log.status != null && log.status!.trim().isNotEmpty) ||
        CallLogDuration.parseToSeconds(log.totalDuration ?? log.duration) > 0;
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
        firstCallDate: current.firstCallDate,
      )) {
        current = overlayDialerDetails(existing: current, event: event);
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

    return repairIncomplete(existing: current, leadCreatedAt: leadCreatedAt);
  }

  /// `true` when [deviceAt] is a new outbound call not already stored in Odoo.
  static bool shouldApplyDeviceOutbound({
    required DateTime deviceAt,
    required DateTime? lastCallDate,
    DateTime? firstCallDate,
  }) {
    final anchor = lastCallDate ?? firstCallDate;
    if (anchor == null) return true;

    final deviceLocal = deviceAt.toLocal();
    final anchorLocal = anchor.toLocal();
    final delta = deviceLocal.difference(anchorLocal).abs();

    // Same call already saved from CRM dial flow (timestamp skew).
    if (delta <= duplicateWindow) return false;

    return deviceLocal.isAfter(anchorLocal);
  }

  /// Replaces placeholder duration / CRM clock with the Android dialer row
  /// for the same call (within [duplicateWindow]) without incrementing counts.
  static CallLog overlayDialerDetails({
    required CallLog existing,
    required DeviceCallEvent event,
  }) {
    if (!event.isOutbound) return existing;

    final anchor = existing.lastCallDate ?? existing.firstCallDate;
    if (anchor == null) return existing;

    final delta = event.at.toLocal().difference(anchor.toLocal()).abs();
    if (delta > duplicateWindow) return existing;

    final deviceSeconds = CallLogDuration.parseToSeconds(event.duration);
    final storedLatest = CallLogDuration.parseToSeconds(existing.duration);
    final storedTotal = CallLogDuration.parseToSeconds(
      existing.totalDuration ?? existing.duration,
    );
    final placeholderLatest =
        existing.duration != null && storedLatest == 0;

    if (deviceSeconds <= storedLatest && !placeholderLatest) {
      return existing.copyWith(
        lastCallDate: event.at,
        status: event.status,
      );
    }

    final nextLatest =
        deviceSeconds > storedLatest ? deviceSeconds : storedLatest;
    var nextTotal = storedTotal;
    if (placeholderLatest) {
      // 00:00 was not added to the cumulative total.
      nextTotal = storedTotal + nextLatest;
    } else if (existing.duration == null && storedTotal == 0) {
      nextTotal = nextLatest;
    } else if (existing.duration != null && deviceSeconds > storedLatest) {
      nextTotal = storedTotal - storedLatest + deviceSeconds;
    }

    return existing.copyWith(
      lastCallDate: event.at,
      duration: CallLogDuration.formatFromSeconds(nextLatest),
      totalDuration: CallLogDuration.formatFromSeconds(nextTotal),
      status: event.status,
    );
  }
}
