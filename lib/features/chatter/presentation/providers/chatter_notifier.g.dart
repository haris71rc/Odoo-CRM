// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatter_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatterRepositoryHash() => r'69addb3a13b62705cde9a6d4a64e7915099c8ed2';

/// See also [chatterRepository].
@ProviderFor(chatterRepository)
final chatterRepositoryProvider = Provider<ChatterRepository>.internal(
  chatterRepository,
  name: r'chatterRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatterRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatterRepositoryRef = ProviderRef<ChatterRepository>;
String _$chatterNotifierHash() => r'53afe4683f4e68ed0249d7f50708ba023c5ab9ae';

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

abstract class _$ChatterNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ChatterMessageEntity>> {
  late final int leadId;

  FutureOr<List<ChatterMessageEntity>> build(int leadId);
}

/// See also [ChatterNotifier].
@ProviderFor(ChatterNotifier)
const chatterNotifierProvider = ChatterNotifierFamily();

/// See also [ChatterNotifier].
class ChatterNotifierFamily
    extends Family<AsyncValue<List<ChatterMessageEntity>>> {
  /// See also [ChatterNotifier].
  const ChatterNotifierFamily();

  /// See also [ChatterNotifier].
  ChatterNotifierProvider call(int leadId) {
    return ChatterNotifierProvider(leadId);
  }

  @override
  ChatterNotifierProvider getProviderOverride(
    covariant ChatterNotifierProvider provider,
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
  String? get name => r'chatterNotifierProvider';
}

/// See also [ChatterNotifier].
class ChatterNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ChatterNotifier,
          List<ChatterMessageEntity>
        > {
  /// See also [ChatterNotifier].
  ChatterNotifierProvider(int leadId)
    : this._internal(
        () => ChatterNotifier()..leadId = leadId,
        from: chatterNotifierProvider,
        name: r'chatterNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatterNotifierHash,
        dependencies: ChatterNotifierFamily._dependencies,
        allTransitiveDependencies:
            ChatterNotifierFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  ChatterNotifierProvider._internal(
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
  FutureOr<List<ChatterMessageEntity>> runNotifierBuild(
    covariant ChatterNotifier notifier,
  ) {
    return notifier.build(leadId);
  }

  @override
  Override overrideWith(ChatterNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatterNotifierProvider._internal(
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
    ChatterNotifier,
    List<ChatterMessageEntity>
  >
  createElement() {
    return _ChatterNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatterNotifierProvider && other.leadId == leadId;
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
mixin ChatterNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ChatterMessageEntity>> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _ChatterNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ChatterNotifier,
          List<ChatterMessageEntity>
        >
    with ChatterNotifierRef {
  _ChatterNotifierProviderElement(super.provider);

  @override
  int get leadId => (origin as ChatterNotifierProvider).leadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
