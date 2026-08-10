// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_permissions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appPermissionsServiceHash() =>
    r'71b41278588a0adee6fda4e3e7fa3feb9c1a37d2';

/// See also [appPermissionsService].
@ProviderFor(appPermissionsService)
final appPermissionsServiceProvider = Provider<AppPermissionsService>.internal(
  appPermissionsService,
  name: r'appPermissionsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appPermissionsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppPermissionsServiceRef = ProviderRef<AppPermissionsService>;
String _$appPermissionsNotifierHash() =>
    r'7fcfe02481b4de8cd4e718f5eef6f7f0bedf2126';

/// See also [AppPermissionsNotifier].
@ProviderFor(AppPermissionsNotifier)
final appPermissionsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      AppPermissionsNotifier,
      List<AppPermissionStatus>
    >.internal(
      AppPermissionsNotifier.new,
      name: r'appPermissionsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appPermissionsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppPermissionsNotifier =
    AutoDisposeAsyncNotifier<List<AppPermissionStatus>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
