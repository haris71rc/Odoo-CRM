import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/providers/core_providers.dart';
import 'package:odoocrm/features/users/data/datasource/user_remote_datasource.dart';
import 'package:odoocrm/features/users/data/repository/user_repository_impl.dart';
import 'package:odoocrm/features/users/domain/entities/user_entity.dart';
import 'package:odoocrm/features/users/domain/repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_notifier.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(
    datasource: UserRemoteDatasource(ref.watch(dioClientProvider)),
  );
}

/// Loads internal users once and keeps them cached.
@Riverpod(keepAlive: true)
class UsersNotifier extends _$UsersNotifier {
  @override
  FutureOr<List<UserEntity>> build() async {
    final repository = ref.watch(userRepositoryProvider);
    final result = await repository.getInternalUsers();

    return result.when(
      success: (users) => users,
      failure: (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userRepositoryProvider);
      final result = await repository.getInternalUsers();
      return result.when(
        success: (users) => users,
        failure: (failure) => throw failure,
      );
    });
  }
}
