// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRepositoryHash() => r'177b32c52b592020c6e5b5e7fedc4cdd677a425e';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = Provider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = ProviderRef<UserRepository>;
String _$usersNotifierHash() => r'b58c64c5a0b403466d7cea5d16dab96587ad4054';

/// Loads internal users once and keeps them cached.
///
/// Copied from [UsersNotifier].
@ProviderFor(UsersNotifier)
final usersNotifierProvider =
    AsyncNotifierProvider<UsersNotifier, List<UserEntity>>.internal(
      UsersNotifier.new,
      name: r'usersNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$usersNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UsersNotifier = AsyncNotifier<List<UserEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
