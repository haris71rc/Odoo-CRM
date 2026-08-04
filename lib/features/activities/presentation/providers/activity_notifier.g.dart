// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityRepositoryHash() =>
    r'daf552f19f9b8b1b0610784a6fc91ce0b3550a2b';

/// See also [activityRepository].
@ProviderFor(activityRepository)
final activityRepositoryProvider = Provider<ActivityRepository>.internal(
  activityRepository,
  name: r'activityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityRepositoryRef = ProviderRef<ActivityRepository>;
String _$activityNotifierHash() => r'8cf63543aeaf0e24ba43b7468b0a608103816954';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ActivityNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ActivityEntity>> {
  late final int leadId;

  FutureOr<List<ActivityEntity>> build(int leadId);
}

/// See also [ActivityNotifier].
@ProviderFor(ActivityNotifier)
const activityNotifierProvider = ActivityNotifierFamily();

/// See also [ActivityNotifier].
class ActivityNotifierFamily extends Family<AsyncValue<List<ActivityEntity>>> {
  /// See also [ActivityNotifier].
  const ActivityNotifierFamily();

  /// See also [ActivityNotifier].
  ActivityNotifierProvider call(int leadId) {
    return ActivityNotifierProvider(leadId);
  }

  @override
  ActivityNotifierProvider getProviderOverride(
    covariant ActivityNotifierProvider provider,
  ) {
    return call(provider.leadId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activityNotifierProvider';
}

/// See also [ActivityNotifier].
class ActivityNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ActivityNotifier,
          List<ActivityEntity>
        > {
  /// See also [ActivityNotifier].
  ActivityNotifierProvider(int leadId)
    : this._internal(
        () => ActivityNotifier()..leadId = leadId,
        from: activityNotifierProvider,
        name: r'activityNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$activityNotifierHash,
        dependencies: ActivityNotifierFamily._dependencies,
        allTransitiveDependencies:
            ActivityNotifierFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  ActivityNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.leadId,
  }) : super.internal();

  final int leadId;

  @override
  FutureOr<List<ActivityEntity>> runNotifierBuild(
    covariant ActivityNotifier notifier,
  ) {
    return notifier.build(leadId);
  }

  @override
  Override overrideWith(ActivityNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ActivityNotifierProvider._internal(
        () => create()..leadId = leadId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        leadId: leadId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ActivityNotifier,
    List<ActivityEntity>
  >
  createElement() {
    return _ActivityNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityNotifierProvider && other.leadId == leadId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, leadId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActivityNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ActivityEntity>> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _ActivityNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ActivityNotifier,
          List<ActivityEntity>
        >
    with ActivityNotifierRef {
  _ActivityNotifierProviderElement(super.provider);

  @override
  int get leadId => (origin as ActivityNotifierProvider).leadId;
}

String _$activityTypesNotifierHash() =>
    r'963f7726d56916af7f028009d1b8573d8409a849';

/// See also [ActivityTypesNotifier].
@ProviderFor(ActivityTypesNotifier)
final activityTypesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ActivityTypesNotifier,
      List<ActivityTypeEntity>
    >.internal(
      ActivityTypesNotifier.new,
      name: r'activityTypesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activityTypesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActivityTypesNotifier =
    AutoDisposeAsyncNotifier<List<ActivityTypeEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
