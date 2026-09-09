// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$leadDetailNotifierHash() =>
    r'53cf29495e053a1f6277eb5f2a3d5b82f95ccb4e';

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

abstract class _$LeadDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<LeadDetailEntity> {
  late final int leadId;

  FutureOr<LeadDetailEntity> build(int leadId);
}

/// See also [LeadDetailNotifier].
@ProviderFor(LeadDetailNotifier)
const leadDetailNotifierProvider = LeadDetailNotifierFamily();

/// See also [LeadDetailNotifier].
class LeadDetailNotifierFamily extends Family<AsyncValue<LeadDetailEntity>> {
  /// See also [LeadDetailNotifier].
  const LeadDetailNotifierFamily();

  /// See also [LeadDetailNotifier].
  LeadDetailNotifierProvider call(int leadId) {
    return LeadDetailNotifierProvider(leadId);
  }

  @override
  LeadDetailNotifierProvider getProviderOverride(
    covariant LeadDetailNotifierProvider provider,
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
  String? get name => r'leadDetailNotifierProvider';
}

/// See also [LeadDetailNotifier].
class LeadDetailNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          LeadDetailNotifier,
          LeadDetailEntity
        > {
  /// See also [LeadDetailNotifier].
  LeadDetailNotifierProvider(int leadId)
    : this._internal(
        () => LeadDetailNotifier()..leadId = leadId,
        from: leadDetailNotifierProvider,
        name: r'leadDetailNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$leadDetailNotifierHash,
        dependencies: LeadDetailNotifierFamily._dependencies,
        allTransitiveDependencies:
            LeadDetailNotifierFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  LeadDetailNotifierProvider._internal(
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
  FutureOr<LeadDetailEntity> runNotifierBuild(
    covariant LeadDetailNotifier notifier,
  ) {
    return notifier.build(leadId);
  }

  @override
  Override overrideWith(LeadDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: LeadDetailNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<LeadDetailNotifier, LeadDetailEntity>
  createElement() {
    return _LeadDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadDetailNotifierProvider && other.leadId == leadId;
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
mixin LeadDetailNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<LeadDetailEntity> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _LeadDetailNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          LeadDetailNotifier,
          LeadDetailEntity
        >
    with LeadDetailNotifierRef {
  _LeadDetailNotifierProviderElement(super.provider);

  @override
  int get leadId => (origin as LeadDetailNotifierProvider).leadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
