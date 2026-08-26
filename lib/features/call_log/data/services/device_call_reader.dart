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
  /// entry appears. Duration, timestamp, and status come from the dialer.
  Future<CallLog?> findRecentCall({
    required String phone,
    required DateTime dialedAt,
    List<CallStatusOption> statusOptions = const [],
  }) async {
    if (!isSupported) return null;

    final permitted = await ensurePermission();
    if (!permitted) return null;

    final normalizedTarget = PhoneNumberUtils.normalize(phone);
    if (normalizedTarget.isEmpty) return null;

    native.CallLogEntry? entry;
    for (var attempt = 0; attempt < 8 && entry == null; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
      }
      entry = await _queryLatestMatching(
        normalizedTarget: normalizedTarget,
        from: dialedAt,
        preferOutbound: true,
      );
    }

    if (entry == null) return null;
    return _toCallLog(entry, statusOptions: statusOptions);
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
        );
        if (event != null) events.add(event);
      }

      events.sort((a, b) => a.at.compareTo(b.at));
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
      final fromMs = from.millisecondsSinceEpoch;
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
  }) {
    if (!_matchesPhone(normalizedTarget, entry)) return null;

    final ts = entry.timestamp;
    if (ts == null || ts < fromMs) return null;

    final isOutbound = _isOutbound(entry.callType);
    final isInbound = _isInbound(entry.callType);
    if (!isOutbound && !isInbound) return null;

    final durationSeconds = entry.duration ?? 0;
    return DeviceCallEvent(
      at: DateTime.fromMillisecondsSinceEpoch(ts),
      duration: CallLogDuration.formatFromSeconds(durationSeconds),
      status: _statusFor(entry.callType, durationSeconds, statusOptions),
      isOutbound: isOutbound,
      isInbound: isInbound,
    );
  }

  CallLog _toCallLog(
    native.CallLogEntry entry, {
    required List<CallStatusOption> statusOptions,
  }) {
    final ts = entry.timestamp;
    final durationSeconds = entry.duration ?? 0;
    return CallLog(
      lastCallDate:
          ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null,
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

  bool _isInbound(native.CallType? type) {
    return type == native.CallType.incoming ||
        type == native.CallType.wifiIncoming;
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

  String _legacyMapStatus(native.CallType? type, int durationSeconds) {
    switch (type) {
      case native.CallType.missed:
        return 'missed';
      case native.CallType.rejected:
      case native.CallType.blocked:
        return 'rejected';
      case native.CallType.outgoing:
      case native.CallType.wifiOutgoing:
        return durationSeconds > 0 ? 'picked' : 'not_picked';
      case native.CallType.incoming:
      case native.CallType.wifiIncoming:
        return durationSeconds > 0 ? 'picked' : 'missed';
      case native.CallType.voiceMail:
      case native.CallType.answeredExternally:
      case native.CallType.unknown:
      case null:
        return durationSeconds > 0 ? 'picked' : 'failed';
    }
  }
}
