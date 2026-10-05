import 'dart:io';

import 'package:call_log/call_log.dart' as native;
import 'package:odoocrm/core/utils/phone_number_utils.dart';
import 'package:odoocrm/features/call_log/data/services/call_status_mapper.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';
import 'package:permission_handler/permission_handler.dart';

/// Reads native Android dialer call-log entries (timestamp, duration, type).
class DeviceCallReader {
  const DeviceCallReader({
    CallStatusMapper statusMapper = const CallStatusMapper(),
  }) : _statusMapper = statusMapper;

  final CallStatusMapper _statusMapper;

  bool get isSupported => Platform.isAndroid;

  Future<bool> ensurePermission() async {
    if (!isSupported) return false;
    final status = await Permission.phone.status;
    if (status.isGranted) return true;
    final result = await Permission.phone.request();
    return result.isGranted;
  }

  /// Latest dialer row for [phone] at or after [dialedAt].
  ///
  /// Android writes the row after the call ends, so this polls until the
  /// entry appears, then returns quickly. A short extra wait is used only when
  /// the row exists but duration is still 0 (some OEMs fill duration late).
  /// DNP / failed calls keep duration 0, so that wait is capped.
  ///
  /// [dialedAt] is kept as the CRM wall-clock for [CallLog.lastCallDate] so
  /// later dialer overlays can still re-trigger Connected promotion.
  Future<CallLog?> findRecentCall({
    required String phone,
    required DateTime dialedAt,
    List<CallStatusOption> statusOptions = const [],
    int maxAttempts = 8,
  }) async {
    if (!isSupported) return null;

    final permitted = await ensurePermission();
    if (!permitted) return null;

    final normalizedTarget = PhoneNumberUtils.normalize(phone);
    if (normalizedTarget.isEmpty) return null;

    native.CallLogEntry? entry;
    var zeroDurationSightings = 0;
    // At most ~1s extra once a row exists with duration still 0.
    const maxZeroDurationWait = 3;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
      final candidate = await _queryLatestMatching(
        normalizedTarget: normalizedTarget,
        from: dialedAt,
        preferOutbound: true,
      );
      if (candidate == null) continue;

      entry = candidate;
      final durationSeconds = candidate.duration ?? 0;
      if (durationSeconds > 0) break;

      // Row found — don't stall DNP/failed (duration stays 0 forever).
      zeroDurationSightings++;
      if (zeroDurationSightings >= maxZeroDurationWait) break;
    }

    if (entry == null) return null;
    return _toCallLog(
      entry,
      // Prefer dial time for CRM-initiated calls (stable wall-clock).
      at: dialedAt,
      statusOptions: statusOptions,
    );
  }

  /// Device calls for [phone] since [since], oldest first.
  ///
  /// Used when Lead Detail opens to sync dialer-made calls into Odoo.
  Future<List<DeviceCallEvent>> findCallsForLead({
    required String phone,
    DateTime? since,
    List<CallStatusOption> statusOptions = const [],
  }) async {
    if (!isSupported) return const [];

    final permitted = await ensurePermission();
    if (!permitted) return const [];

    final normalizedTarget = PhoneNumberUtils.normalize(phone);
    if (normalizedTarget.isEmpty) return const [];

    try {
      final fromMs = (since ?? DateTime.fromMillisecondsSinceEpoch(0))
          .millisecondsSinceEpoch;

      final entries = await native.CallLog.query(dateFrom: fromMs);
      final events = <DeviceCallEvent>[];

      for (final entry in entries) {
        final event = _toDeviceEvent(
          entry,
          normalizedTarget: normalizedTarget,
          fromMs: fromMs,
          statusOptions: statusOptions,
          requirePhoneMatch: true,
        );
        if (event != null) events.add(event);
      }

      events.sort(_compareEvents);
      return events;
    } catch (_) {
      return const [];
    }
  }

  /// All inbound / missed / rejected device calls since [since], oldest first.
  ///
  /// Used by the global inbound Growth sync (not lead-scoped).
  Future<List<DeviceCallEvent>> findInboundCallsSince({
    required DateTime since,
    List<CallStatusOption> statusOptions = const [],
  }) async {
    if (!isSupported) return const [];

    final permitted = await ensurePermission();
    if (!permitted) return const [];

    try {
      final fromMs = since.millisecondsSinceEpoch;
      final entries = await native.CallLog.query(dateFrom: fromMs);
      final events = <DeviceCallEvent>[];

      for (final entry in entries) {
        final event = _toDeviceEvent(
          entry,
          normalizedTarget: '',
          fromMs: fromMs,
          statusOptions: statusOptions,
          requirePhoneMatch: false,
          inboundOnly: true,
        );
        if (event != null) events.add(event);
      }

      events.sort(_compareEvents);
      return events;
    } catch (_) {
      return const [];
    }
  }

  /// Counts incoming calls from [phone] in the device call log (Android only).
  Future<int?> countInboundCalls({
    required String phone,
    DateTime? since,
  }) async {
    if (!isSupported) return null;
    final permitted = await ensurePermission();
    if (!permitted) return null;

    final events = await findCallsForLead(phone: phone, since: since);
    return events.where((e) => e.isInbound).length;
  }

  Future<native.CallLogEntry?> _queryLatestMatching({
    required String normalizedTarget,
    required DateTime from,
    required bool preferOutbound,
  }) async {
    try {
      // Dialer timestamps can land slightly before CRM dialedAt (set before
      // launchUrl), so look back a few seconds to avoid missing the row.
      final fromMs =
          from.subtract(const Duration(seconds: 15)).millisecondsSinceEpoch;
      final entries = await native.CallLog.query(dateFrom: fromMs);
      native.CallLogEntry? best;
      native.CallLogEntry? bestAny;

      for (final entry in entries) {
        if (!_matchesPhone(normalizedTarget, entry)) continue;
        final ts = entry.timestamp;
        if (ts == null || ts < fromMs) continue;

        bestAny = _later(bestAny, entry);
        if (preferOutbound && !_isOutbound(entry.callType)) continue;
        best = _later(best, entry);
      }

      return best ?? bestAny;
    } catch (_) {
      return null;
    }
  }

  DeviceCallEvent? _toDeviceEvent(
    native.CallLogEntry entry, {
    required String normalizedTarget,
    required int fromMs,
    required List<CallStatusOption> statusOptions,
    required bool requirePhoneMatch,
    bool inboundOnly = false,
  }) {
    if (requirePhoneMatch && !_matchesPhone(normalizedTarget, entry)) {
      return null;
    }

    final ts = entry.timestamp;
    if (ts == null || ts < fromMs) return null;

    final isOutbound = _isOutbound(entry.callType);
    final isInbound = _isInboundLike(entry.callType);
    if (inboundOnly) {
      if (!isInbound) return null;
    } else if (!isOutbound && !isInbound) {
      return null;
    }

    final durationSeconds = entry.duration ?? 0;
    final rawNumber = entry.number ?? entry.formattedNumber ?? '';
    final normalizedPhone = PhoneNumberUtils.normalizeOrNull(rawNumber);

    return DeviceCallEvent(
      at: DateTime.fromMillisecondsSinceEpoch(ts),
      duration: CallLogDuration.formatFromSeconds(durationSeconds),
      status: _statusFor(entry.callType, durationSeconds, statusOptions),
      isOutbound: isOutbound,
      isInbound: isInbound,
      androidCallLogId: entry.id,
      phoneNumber: normalizedPhone ?? rawNumber.trim(),
    );
  }

  CallLog _toCallLog(
    native.CallLogEntry entry, {
    DateTime? at,
    required List<CallStatusOption> statusOptions,
  }) {
    final ts = entry.timestamp;
    final durationSeconds = entry.duration ?? 0;
    return CallLog(
      lastCallDate: at ??
          (ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null),
      duration: CallLogDuration.formatFromSeconds(durationSeconds),
      status: _statusFor(entry.callType, durationSeconds, statusOptions),
    );
  }

  String _statusFor(
    native.CallType? type,
    int durationSeconds,
    List<CallStatusOption> statusOptions,
  ) {
    if (statusOptions.isEmpty) {
      return _legacyMapStatus(type, durationSeconds);
    }
    return _statusMapper.mapDeviceStatus(
      type: type,
      durationSeconds: durationSeconds,
      options: statusOptions,
    );
  }

  bool _matchesPhone(String normalizedTarget, native.CallLogEntry entry) {
    final number = entry.number ?? entry.formattedNumber ?? '';
    return _numbersMatch(normalizedTarget, number);
  }

  native.CallLogEntry _later(native.CallLogEntry? current, native.CallLogEntry next) {
    if (current == null) return next;
    final currentTs = current.timestamp ?? 0;
    final nextTs = next.timestamp ?? 0;
    return nextTs >= currentTs ? next : current;
  }

  /// Incoming answered/wifi, plus missed, rejected, and voicemail.
  ///
  /// A missed call that goes to voicemail is often stored as [voiceMail]
  /// (the Phone app shows a mic on that row) rather than [missed].
  bool _isInboundLike(native.CallType? type) {
    return type == native.CallType.incoming ||
        type == native.CallType.wifiIncoming ||
        type == native.CallType.missed ||
        type == native.CallType.rejected ||
        type == native.CallType.voiceMail;
  }

  bool _isOutbound(native.CallType? type) {
    return type == native.CallType.outgoing ||
        type == native.CallType.wifiOutgoing;
  }

  bool _numbersMatch(String normalizedTarget, String candidate) {
    final normalized = PhoneNumberUtils.normalize(candidate);
    if (normalized.isEmpty) return false;
    if (normalized == normalizedTarget) return true;

    final a = normalized.length > 10
        ? normalized.substring(normalized.length - 10)
        : normalized;
    final b = normalizedTarget.length > 10
        ? normalizedTarget.substring(normalizedTarget.length - 10)
        : normalizedTarget;
    return a == b;
  }

  int _compareEvents(DeviceCallEvent a, DeviceCallEvent b) {
    final byTime = a.at.compareTo(b.at);
    if (byTime != 0) return byTime;
    return (a.androidCallLogId ?? '').compareTo(b.androidCallLogId ?? '');
  }

  String _legacyMapStatus(native.CallType? type, int durationSeconds) {
    switch (type) {
      case native.CallType.missed:
      case native.CallType.voiceMail:
        return 'missed';
      case native.CallType.rejected:
      case native.CallType.blocked:
        return 'hanged_up';
      case native.CallType.outgoing:
      case native.CallType.wifiOutgoing:
        return durationSeconds > 0 ? 'picked' : 'dnp';
      case native.CallType.incoming:
      case native.CallType.wifiIncoming:
        return durationSeconds > 0 ? 'picked' : 'missed';
      case native.CallType.answeredExternally:
      case native.CallType.unknown:
      case null:
        return durationSeconds > 0 ? 'picked' : 'call_failed';
    }
  }
}
