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
        storedDurationSeconds: CallLogDuration.parseToSeconds(current.duration),
        deviceDurationSeconds: CallLogDuration.parseToSeconds(event.duration),
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
    int storedDurationSeconds = 0,
    int deviceDurationSeconds = 0,
  }) {
    final anchor = lastCallDate ?? firstCallDate;
    if (anchor == null) return true;

    if (isSameStoredOutbound(
      deviceAt: deviceAt,
      anchor: anchor,
      storedDurationSeconds: storedDurationSeconds,
      deviceDurationSeconds: deviceDurationSeconds,
    )) {
      return false;
    }

    return deviceAt.toLocal().isAfter(anchor.toLocal());
  }

  /// Same CRM dial as [anchor], including when the dialer timestamp is hangup
  /// time and the saved row is still a `00:00` placeholder.
  static bool isSameStoredOutbound({
    required DateTime deviceAt,
    required DateTime anchor,
    required int storedDurationSeconds,
    required int deviceDurationSeconds,
  }) {
    final deviceLocal = deviceAt.toLocal();
    final anchorLocal = anchor.toLocal();
    final delta = deviceLocal.difference(anchorLocal).abs();
    if (delta <= duplicateWindow) return true;

    const lookback = Duration(seconds: 15);
    final earliest = anchorLocal.subtract(lookback);

    if (storedDurationSeconds <= 0 && deviceDurationSeconds > 0) {
      final latest = anchorLocal.add(
        Duration(seconds: deviceDurationSeconds) + duplicateWindow,
      );
      return !deviceLocal.isBefore(earliest) && !deviceLocal.isAfter(latest);
    }

    if (storedDurationSeconds > 0 && deviceDurationSeconds > 0) {
      final durationGap = (deviceDurationSeconds - storedDurationSeconds).abs();
      final similar = durationGap <= 5 ||
          durationGap <= (storedDurationSeconds * 0.15).round();
      if (!similar) return false;
      final span = storedDurationSeconds > deviceDurationSeconds
          ? storedDurationSeconds
          : deviceDurationSeconds;
      final latest = anchorLocal.add(Duration(seconds: span) + duplicateWindow);
      return !deviceLocal.isBefore(earliest) && !deviceLocal.isAfter(latest);
    }

    return false;
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

    final deviceSeconds = CallLogDuration.parseToSeconds(event.duration);
    final storedLatest = CallLogDuration.parseToSeconds(existing.duration);
    if (!isSameStoredOutbound(
      deviceAt: event.at,
      anchor: anchor,
      storedDurationSeconds: storedLatest,
      deviceDurationSeconds: deviceSeconds,
    )) {
      return existing;
    }
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
    } else if (existing.duration == null &&
        deviceSeconds > 0 &&
        (existing.totalOutboundCalls ?? 0) <= 1) {
      // Odoo round-trip dropped latest duration; single-call total is the
      // latest talk time from the dialer.
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
