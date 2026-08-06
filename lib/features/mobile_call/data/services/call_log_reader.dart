import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:odoocrm/core/utils/phone_number_utils.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';
import 'package:permission_handler/permission_handler.dart';

/// Reads the device call log after the native dialer returns (Android).
class CallLogReader {
  const CallLogReader();

  bool get isSupported => Platform.isAndroid;

  Future<bool> ensurePermission() async {
    if (!isSupported) return false;

    final status = await Permission.phone.status;
    if (status.isGranted) return true;

    final result = await Permission.phone.request();
    return result.isGranted;
  }

  /// Finds the most recent call matching [phone] at or after [dialedAt].
  Future<LatestMobileCallEntity?> findRecentCall({
    required String phone,
    required DateTime dialedAt,
  }) async {
    if (!isSupported) return null;

    final permitted = await ensurePermission();
    if (!permitted) return null;

    final normalizedTarget = PhoneNumberUtils.normalize(phone);
    if (normalizedTarget.isEmpty) return null;

    // Call log writers can lag a moment after the dialer closes.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    try {
      final fromMs = dialedAt
          .subtract(const Duration(seconds: 5))
          .millisecondsSinceEpoch;

      final entries = await CallLog.query(dateFrom: fromMs);
      if (entries.isEmpty) return null;

      CallLogEntry? best;
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
      return _toEntity(best, fallbackPhone: phone);
    } catch (_) {
      return null;
    }
  }

  bool _numbersMatch(String normalizedTarget, String candidate) {
    final normalized = PhoneNumberUtils.normalize(candidate);
    if (normalized.isEmpty) return false;
    if (normalized == normalizedTarget) return true;

    // Compare last 10 digits (common for local vs +91 storage).
    final a = normalized.length > 10
        ? normalized.substring(normalized.length - 10)
        : normalized;
    final b = normalizedTarget.length > 10
        ? normalizedTarget.substring(normalizedTarget.length - 10)
        : normalizedTarget;
    return a == b;
  }

  LatestMobileCallEntity _toEntity(
    CallLogEntry entry, {
    required String fallbackPhone,
  }) {
    final duration = entry.duration ?? 0;
    final callType = entry.callType;
    final direction = _directionOf(callType);
    final status = _statusOf(callType, duration);
    final phone = (entry.number ?? entry.formattedNumber ?? fallbackPhone)
        .trim();
    final timestamp = entry.timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)
        : DateTime.now();

    return LatestMobileCallEntity(
      status: status,
      duration: duration,
      direction: direction,
      phone: phone,
      timestamp: timestamp,
    );
  }

  String _directionOf(CallType? type) {
    switch (type) {
      case CallType.incoming:
      case CallType.wifiIncoming:
      case CallType.missed:
        return 'incoming';
      case CallType.outgoing:
      case CallType.wifiOutgoing:
      case CallType.rejected:
      case CallType.blocked:
      case CallType.voiceMail:
      case CallType.answeredExternally:
      case CallType.unknown:
      case null:
        return 'outgoing';
    }
  }

  String _statusOf(CallType? type, int duration) {
    switch (type) {
      case CallType.missed:
        return 'missed';
      case CallType.rejected:
        return 'rejected';
      case CallType.blocked:
        return 'rejected';
      case CallType.outgoing:
      case CallType.wifiOutgoing:
        return duration > 0 ? 'answered' : 'no_answer';
      case CallType.incoming:
      case CallType.wifiIncoming:
        return duration > 0 ? 'answered' : 'missed';
      case CallType.voiceMail:
      case CallType.answeredExternally:
      case CallType.unknown:
      case null:
        return duration > 0 ? 'answered' : 'no_answer';
    }
  }
}
