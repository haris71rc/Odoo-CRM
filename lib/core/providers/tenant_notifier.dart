import 'package:odoocrm/core/constants/app_environment.dart';
import 'package:odoocrm/core/constants/app_tenant.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tenant_notifier.g.dart';

@Riverpod(keepAlive: true)
class TenantNotifier extends _$TenantNotifier {
  @override
  FutureOr<AppTenant> build() async {
    final tenant = await _resolveTenant();
    ref.read(dioClientProvider).applyTenant(tenant);
    return tenant;
  }

  Future<void> select(AppTenant tenant) async {
    final resolved = AppEnvironment.isDev ? AppTenant.fallback : tenant;
    final previous = state.valueOrNull;
    if (previous != null && previous != resolved) {
      await ref.read(secureStorageServiceProvider).clear();
    }
    ref.read(dioClientProvider).applyTenant(resolved);
    state = AsyncData(resolved);
    if (!AppEnvironment.isDev) {
      await ref.read(secureStorageServiceProvider).saveTenantId(resolved.id);
    }
  }

  Future<AppTenant> _resolveTenant() async {
    if (AppEnvironment.isDev) return AppTenant.fallback;

    final saved = await ref.read(secureStorageServiceProvider).getTenantId();
    return AppTenant.fromId(saved);
  }
}
