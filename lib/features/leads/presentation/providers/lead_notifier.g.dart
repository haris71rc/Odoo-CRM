// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$leadRepositoryHash() => r'7de92d0b495b09c195f0e869f41b6839f5e17e87';

/// See also [leadRepository].
@ProviderFor(leadRepository)
final leadRepositoryProvider = Provider<LeadRepository>.internal(
  leadRepository,
  name: r'leadRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leadRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeadRepositoryRef = ProviderRef<LeadRepository>;
String _$leadFilterNotifierHash() =>
    r'3ade3d75db9be9ebdc172936e563fe6e65036e8a';

/// See also [LeadFilterNotifier].
@ProviderFor(LeadFilterNotifier)
final leadFilterNotifierProvider =
    NotifierProvider<LeadFilterNotifier, LeadFilterState>.internal(
      LeadFilterNotifier.new,
      name: r'leadFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leadFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LeadFilterNotifier = Notifier<LeadFilterState>;
String _$leadNotifierHash() => r'16f7a4d35ff1750d84bfaf5f2ddc0b8b7e750123';

/// See also [LeadNotifier].
@ProviderFor(LeadNotifier)
final leadNotifierProvider =
    AsyncNotifierProvider<LeadNotifier, List<LeadEntity>>.internal(
      LeadNotifier.new,
      name: r'leadNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leadNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LeadNotifier = AsyncNotifier<List<LeadEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
