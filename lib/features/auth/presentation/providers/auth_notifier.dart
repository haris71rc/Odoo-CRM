import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/constants/app_tenant.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/core/providers/tenant_notifier.dart';
import 'package:odoocrm/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:odoocrm/features/auth/data/repository/auth_repository_impl.dart';
import 'package:odoocrm/features/auth/domain/entities/user_entity.dart';
import 'package:odoocrm/features/auth/domain/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    datasource: AuthRemoteDatasource(
      dioClient: ref.watch(dioClientProvider),
      secureStorage: ref.watch(secureStorageServiceProvider),
    ),
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<UserEntity?> build() async {
    await ref.read(tenantNotifierProvider.future);
    final repository = ref.watch(authRepositoryProvider);
    final authResult = await repository.isAuthenticated();

    final isAuthenticated = authResult.valueOrNull ?? false;
    if (!isAuthenticated) return null;

    final userResult = await repository.getCurrentUser();
    return userResult.valueOrNull;
  }

  Future<String?> login({
    required String username,
    required String password,
    AppTenant tenant = AppTenant.fallback,
  }) async {
    state = const AsyncLoading();
    await ref.read(tenantNotifierProvider.notifier).select(tenant);
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.login(
      username: username.trim(),
      password: password,
    );

    if (result.isFailure) {
      final failure = result.failureOrNull!;
      state = AsyncError(failure, StackTrace.current);
      return failure.message;
    }

    final userResult = await repository.getCurrentUser();
    if (userResult.isFailure) {
      final failure = userResult.failureOrNull!;
      state = AsyncError(failure, StackTrace.current);
      return failure.message;
    }

    state = AsyncData(userResult.valueOrNull);
    return null;
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncData(null);
  }

  Future<void> refreshProfile() async {
    final repository = ref.read(authRepositoryProvider);
    final userResult = await repository.getCurrentUser();
    if (userResult.isSuccess) {
      state = AsyncData(userResult.valueOrNull);
    } else {
      state = AsyncError(userResult.failureOrNull!, StackTrace.current);
    }
  }
}
