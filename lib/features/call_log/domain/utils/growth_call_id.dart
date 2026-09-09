import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_updater.dart';

/// Stable Growth `call_id` so CRM dial + device sync map to one idempotency key.
class GrowthCallId {
  GrowthCallId._();

  /// Matches [CallLogUpdater.duplicateWindow] so both paths share a key.
  static Duration get dedupeWindow => CallLogUpdater.duplicateWindow;

  /// DNS namespace UUID (RFC 4122) used as v5 namespace.
  static const _namespace = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

  /// Reuses [known] ids within [dedupeWindow], else a deterministic UUID v5.
  static String resolve({
    required int leadId,
    required String direction,
    required DateTime callAt,
    Iterable<({int leadId, String direction, DateTime callAt, String callId})>
        known = const [],
  }) {
    final normalizedDirection =
        direction == 'inbound' ? 'inbound' : 'outbound';
    final callUtc = callAt.toUtc();

    for (final item in known) {
      if (item.leadId != leadId) continue;
      if (item.direction != normalizedDirection) continue;
      if (item.callAt.toUtc().difference(callUtc).abs() <= dedupeWindow) {
        return item.callId;
      }
    }

    final bucket =
        callUtc.millisecondsSinceEpoch ~/ dedupeWindow.inMilliseconds;
    return uuidV5('growth-call|$leadId|$normalizedDirection|$bucket');
  }

  /// RFC 4122 UUID version 5 (SHA-1).
  static String uuidV5(String name) {
    final namespaceBytes = _parseUuidBytes(_namespace);
    final hash = sha1.convert([...namespaceBytes, ...utf8.encode(name)]);
    final bytes = List<int>.from(hash.bytes.take(16));
    bytes[6] = (bytes[6] & 0x0f) | 0x50; // version 5
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant RFC 4122
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  static List<int> _parseUuidBytes(String uuid) {
    final hex = uuid.replaceAll('-', '');
    return [
      for (var i = 0; i < 32; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];
  }
}
