import 'dart:convert';

import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/call_log/domain/entities/lead_call_sync_cursor.dart';

/// Per-lead watermark of Android call rows already written to Odoo.
class LeadCallSyncStore {
  LeadCallSyncStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<LeadCallSyncCursor> load(int leadId) async {
    final all = await _readAll();
    return all['$leadId'] ?? LeadCallSyncCursor.empty;
  }

  Future<void> save(int leadId, LeadCallSyncCursor cursor) async {
    final all = await _readAll();
    all['$leadId'] = cursor;
    await _secureStorage.write(
      AppConstants.leadCallSyncCursorKey,
      jsonEncode({
        for (final entry in all.entries) entry.key: _toJson(entry.value),
      }),
    );
  }

  Future<Map<String, LeadCallSyncCursor>> _readAll() async {
    final raw = await _secureStorage.read(AppConstants.leadCallSyncCursorKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final cursors = <String, LeadCallSyncCursor>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! Map) continue;
        cursors[entry.key.toString()] = _fromJson(value);
      }
      return cursors;
    } catch (_) {
      return {};
    }
  }

  static Map<String, dynamic> _toJson(LeadCallSyncCursor cursor) {
    return {
      'keys': cursor.keys.toList(),
      'seeded': cursor.seeded,
    };
  }

  static LeadCallSyncCursor _fromJson(Map<dynamic, dynamic> json) {
    final rawKeys = json['keys'];
    final keys = <String>{
      if (rawKeys is List)
        for (final key in rawKeys)
          if (key is String && key.isNotEmpty) key,
    };
    return LeadCallSyncCursor(
      keys: keys,
      seeded: json['seeded'] == true,
    );
  }
}
