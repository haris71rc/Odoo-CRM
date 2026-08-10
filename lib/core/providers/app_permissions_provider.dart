import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/core/services/app_permission.dart';
import 'package:odoocrm/core/services/app_permissions_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_permissions_provider.g.dart';

@Riverpod(keepAlive: true)
AppPermissionsService appPermissionsService(Ref ref) {
  return AppPermissionsService(ref.watch(secureStorageServiceProvider));
}

@riverpod
class AppPermissionsNotifier extends _$AppPermissionsNotifier {
  @override
  FutureOr<List<AppPermissionStatus>> build() async {
    return ref.watch(appPermissionsServiceProvider).getStatuses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(appPermissionsServiceProvider).getStatuses(),
    );
  }

  Future<void> setEnabled(AppPermissionKind kind, bool enabled) async {
    final service = ref.read(appPermissionsServiceProvider);
    final current = await service.getStatus(kind);

    if (enabled) {
      if (!current.granted) {
        await service.request(kind);
      }
    } else if (current.granted) {
      // Apps cannot revoke runtime permissions themselves.
      await service.openSettings();
    }

    await refresh();
  }

  Future<void> requestStartupIfNeeded() {
    return ref.read(appPermissionsServiceProvider).requestStartupPermissionsIfNeeded();
  }
}
