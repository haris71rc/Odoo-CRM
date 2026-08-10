// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tagRepositoryHash() => r'73b5fb64a197f35a08556fa832e8b929c15d85a6';

/// See also [tagRepository].
@ProviderFor(tagRepository)
final tagRepositoryProvider = Provider<TagRepository>.internal(
  tagRepository,
  name: r'tagRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tagRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TagRepositoryRef = ProviderRef<TagRepository>;
String _$leadTemperatureTagsNotifierHash() =>
    r'af6a7caf145c076e35ca93ca0073950283347b7f';

/// Cached HOT_LEAD / WARM_LEAD tags from Odoo (by name → id).
///
/// Copied from [LeadTemperatureTagsNotifier].
@ProviderFor(LeadTemperatureTagsNotifier)
final leadTemperatureTagsNotifierProvider =
    AsyncNotifierProvider<
      LeadTemperatureTagsNotifier,
      List<LeadTagEntity>
    >.internal(
      LeadTemperatureTagsNotifier.new,
      name: r'leadTemperatureTagsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leadTemperatureTagsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LeadTemperatureTagsNotifier = AsyncNotifier<List<LeadTagEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
