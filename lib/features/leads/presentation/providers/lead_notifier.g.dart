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
    r'7d86b56d4a5d8aae52bc001671b2ebd24d1791c3';

/// See also [LeadFilterNotifier].
@ProviderFor(LeadFilterNotifier)
final leadFilterNotifierProvider =
    AutoDisposeNotifierProvider<LeadFilterNotifier, LeadFilterState>.internal(
      LeadFilterNotifier.new,
      name: r'leadFilterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leadFilterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LeadFilterNotifier = AutoDisposeNotifier<LeadFilterState>;
String _$leadNotifierHash() => r'e7108def3e61149d12a9b19bbf3bddd83e23a9aa';

/// See also [LeadNotifier].
@ProviderFor(LeadNotifier)
final leadNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LeadNotifier, List<LeadEntity>>.internal(
      LeadNotifier.new,
      name: r'leadNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leadNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LeadNotifier = AutoDisposeAsyncNotifier<List<LeadEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
