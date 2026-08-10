import 'dart:io';

import 'package:odoocrm/core/services/app_permission.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests and tracks runtime permissions used by the CRM app.
class AppPermissionsService {
  AppPermissionsService(this._secureStorage);

  final SecureStorageService _secureStorage;

  static const _promptedKey = 'app_permissions_prompted_v1';

  List<AppPermissionKind> get managedPermissions {
    if (Platform.isAndroid) {
      return AppPermissionKind.values;
    }
    // iOS: contacts may be used; phone/call-log APIs are Android-only.
    return const [AppPermissionKind.contacts];
  }

  Future<List<AppPermissionStatus>> getStatuses() async {
    final statuses = <AppPermissionStatus>[];
    for (final kind in managedPermissions) {
      statuses.add(await getStatus(kind));
    }
    return statuses;
  }

  Future<AppPermissionStatus> getStatus(AppPermissionKind kind) async {
    if (!_isSupported(kind)) {
      return AppPermissionStatus(
        kind: kind,
        granted: false,
        permanentlyDenied: false,
        supported: false,
      );
    }

    final status = await kind.permission.status;
    return AppPermissionStatus(
      kind: kind,
      granted: status.isGranted || status.isLimited || status.isProvisional,
      permanentlyDenied: status.isPermanentlyDenied,
      supported: true,
    );
  }

  Future<AppPermissionStatus> request(AppPermissionKind kind) async {
    if (!_isSupported(kind)) return getStatus(kind);

    final current = await kind.permission.status;
    if (current.isGranted || current.isLimited || current.isProvisional) {
      return getStatus(kind);
    }

    if (current.isPermanentlyDenied) {
      await openAppSettings();
      return getStatus(kind);
    }

    await kind.permission.request();
    return getStatus(kind);
  }

  /// Opens system settings so the user can revoke or enable a permission.
  Future<bool> openSettings() => openAppSettings();

  /// One-time prompt after install / first login into the shell.
  Future<void> requestStartupPermissionsIfNeeded() async {
    final prompted = await _secureStorage.readFlag(_promptedKey);
    if (prompted) return;

    await _secureStorage.writeFlag(_promptedKey, true);

    for (final kind in managedPermissions) {
      final status = await kind.permission.status;
      if (status.isGranted ||
          status.isLimited ||
          status.isProvisional ||
          status.isPermanentlyDenied) {
        continue;
      }
      await kind.permission.request();
    }
  }

  bool _isSupported(AppPermissionKind kind) {
    if (Platform.isAndroid) return true;
    if (Platform.isIOS) return kind == AppPermissionKind.contacts;
    return false;
  }
}
