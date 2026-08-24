import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odoocrm/core/constants/app_constants.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String sessionId,
    required int uid,
    required String login,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.sessionIdKey, value: sessionId),
      _storage.write(key: AppConstants.uidKey, value: uid.toString()),
      _storage.write(key: AppConstants.userLoginKey, value: login),
    ]);
  }

  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: AppConstants.sessionIdKey, value: sessionId);
  }

  Future<String?> getSessionId() =>
      _storage.read(key: AppConstants.sessionIdKey);

  Future<int?> getUid() async {
    final value = await _storage.read(key: AppConstants.uidKey);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<String?> getLogin() => _storage.read(key: AppConstants.userLoginKey);

  Future<void> saveTenantId(String tenantId) =>
      _storage.write(key: AppConstants.tenantKey, value: tenantId);

  Future<String?> getTenantId() => _storage.read(key: AppConstants.tenantKey);

  Future<bool> hasSession() async {
    final sessionId = await getSessionId();
    final uid = await getUid();
    return sessionId != null && sessionId.isNotEmpty && uid != null;
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: AppConstants.sessionIdKey),
      _storage.delete(key: AppConstants.uidKey),
      _storage.delete(key: AppConstants.userLoginKey),
    ]);
  }

  Future<bool> readFlag(String key) async {
    final value = await _storage.read(key: key);
    return value == '1' || value == 'true';
  }

  Future<void> writeFlag(String key, bool value) async {
    await _storage.write(key: key, value: value ? '1' : '0');
  }
}
