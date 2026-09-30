import 'dart:convert';

import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/call_log/domain/entities/pending_outbound_dial.dart';

/// Durable pending CRM dial so a backgrounded or killed process can still sync.
abstract class PendingOutboundDialStore {
  Future<PendingOutboundDial?> load();

  Future<void> save(PendingOutboundDial dial);

  Future<void> clear();
}

class SecurePendingOutboundDialStore implements PendingOutboundDialStore {
  SecurePendingOutboundDialStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  @override
  Future<PendingOutboundDial?> load() async {
    final raw = await _secureStorage.read(AppConstants.pendingOutboundDialKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return PendingOutboundDial.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(PendingOutboundDial dial) {
    return _secureStorage.write(
      AppConstants.pendingOutboundDialKey,
      jsonEncode(dial.toJson()),
    );
  }

  @override
  Future<void> clear() {
    return _secureStorage.delete(AppConstants.pendingOutboundDialKey);
  }
}
