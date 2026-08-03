// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stageRepositoryHash() => r'57e4705e2ea32588fec69ea2b8067d8daf0c80bd';

/// See also [stageRepository].
@ProviderFor(stageRepository)
final stageRepositoryProvider = Provider<StageRepository>.internal(
  stageRepository,
  name: r'stageRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stageRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StageRepositoryRef = ProviderRef<StageRepository>;
String _$stageNotifierHash() => r'002c86e3b05f6a2f2a4ec21e1329e09c3510f080';

/// See also [StageNotifier].
@ProviderFor(StageNotifier)
final stageNotifierProvider =
    AutoDisposeAsyncNotifierProvider<StageNotifier, List<StageEntity>>.internal(
      StageNotifier.new,
      name: r'stageNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stageNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StageNotifier = AutoDisposeAsyncNotifier<List<StageEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
