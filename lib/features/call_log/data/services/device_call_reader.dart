import 'dart:io';

import 'package:call_log/call_log.dart' as native;
import 'package:odoocrm/core/utils/phone_number_utils.dart';
import 'package:odoocrm/features/call_log/data/services/call_status_mapper.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:permission_handler/permission_handler.dart';

/// Reads native call log after the dialer returns (Android).
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

    await Future<void>.delayed(const Duration(milliseconds: 800));

    try {
      final fromMs = dialedAt
          .subtract(const Duration(seconds: 5))
          .millisecondsSinceEpoch;

      final entries = await native.CallLog.query(dateFrom: fromMs);
      if (entries.isEmpty) return null;

      native.CallLogEntry? best;
      for (final entry in entries) {
        final number = entry.number ?? entry.formattedNumber ?? '';
        if (!_numbersMatch(normalizedTarget, number)) continue;

        final ts = entry.timestamp;
        if (ts != null && ts < fromMs) continue;

        if (best == null) {
          best = entry;
          continue;
        }
        final bestTs = best.timestamp ?? 0;
        final entryTs = ts ?? 0;
        if (entryTs >= bestTs) best = entry;
      }

      if (best == null) return null;
      return _toCallLog(
        best,
        // Prefer dial time for CRM-initiated calls (stable wall-clock).
        at: dialedAt,
        statusOptions: statusOptions,
      );
    } catch (_) {
      return null;
    }
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
          .subtract(const Duration(hours: 1))
          .millisecondsSinceEpoch;

      final entries = await native.CallLog.query(dateFrom: fromMs);
      final events = <DeviceCallEvent>[];

      for (final entry in entries) {
        final number = entry.number ?? entry.formattedNumber ?? '';
        if (!_numbersMatch(normalizedTarget, number)) continue;

        final ts = entry.timestamp;
        if (ts == null) continue;
        if (ts < fromMs) continue;

        final at = DateTime.fromMillisecondsSinceEpoch(ts);
        if (since != null && at.isBefore(since.subtract(const Duration(days: 1)))) {
          continue;
        }

        final durationSeconds = entry.duration ?? 0;
        final isOutbound = _isOutbound(entry.callType);
        final isInbound = _isInbound(entry.callType);
        if (!isOutbound && !isInbound) continue;

        final status = statusOptions.isEmpty
            ? _legacyMapStatus(entry.callType, durationSeconds)
            : _statusMapper.mapDeviceStatus(
                type: entry.callType,
                durationSeconds: durationSeconds,
                options: statusOptions,
              );

        events.add(
          DeviceCallEvent(
            at: at,
            duration: _formatDuration(durationSeconds),
            status: status,
            isOutbound: isOutbound,
            isInbound: isInbound,
          ),
        );
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

  CallLog _toCallLog(
    native.CallLogEntry entry, {
    required DateTime at,
    required List<CallStatusOption> statusOptions,
  }) {
    final durationSeconds = entry.duration ?? 0;
    final status = statusOptions.isEmpty
        ? _legacyMapStatus(entry.callType, durationSeconds)
        : _statusMapper.mapDeviceStatus(
            type: entry.callType,
            durationSeconds: durationSeconds,
            options: statusOptions,
          );

    return CallLog(
      lastCallDate: at,
      duration: _formatDuration(durationSeconds),
      status: status,
    );
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

  String _formatDuration(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final minutes = safe ~/ 60;
    final secs = safe % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
