// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_lead_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignLeadNotifierHash() =>
    r'59b1ab10d437f5980dee90632dc8c94c40b913e0';

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

abstract class _$AssignLeadNotifier
    extends BuildlessAutoDisposeAsyncNotifier<void> {
  late final int leadId;

  FutureOr<void> build(int leadId);
}

/// See also [AssignLeadNotifier].
@ProviderFor(AssignLeadNotifier)
const assignLeadNotifierProvider = AssignLeadNotifierFamily();

/// See also [AssignLeadNotifier].
class AssignLeadNotifierFamily extends Family<AsyncValue<void>> {
  /// See also [AssignLeadNotifier].
  const AssignLeadNotifierFamily();

  /// See also [AssignLeadNotifier].
  AssignLeadNotifierProvider call(int leadId) {
    return AssignLeadNotifierProvider(leadId);
  }

  @override
  AssignLeadNotifierProvider getProviderOverride(
    covariant AssignLeadNotifierProvider provider,
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
  String? get name => r'assignLeadNotifierProvider';
}

/// See also [AssignLeadNotifier].
class AssignLeadNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<AssignLeadNotifier, void> {
  /// See also [AssignLeadNotifier].
  AssignLeadNotifierProvider(int leadId)
    : this._internal(
        () => AssignLeadNotifier()..leadId = leadId,
        from: assignLeadNotifierProvider,
        name: r'assignLeadNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$assignLeadNotifierHash,
        dependencies: AssignLeadNotifierFamily._dependencies,
        allTransitiveDependencies:
            AssignLeadNotifierFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  AssignLeadNotifierProvider._internal(
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
  FutureOr<void> runNotifierBuild(covariant AssignLeadNotifier notifier) {
    return notifier.build(leadId);
  }

  @override
  Override overrideWith(AssignLeadNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: AssignLeadNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<AssignLeadNotifier, void>
  createElement() {
    return _AssignLeadNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignLeadNotifierProvider && other.leadId == leadId;
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
mixin AssignLeadNotifierRef on AutoDisposeAsyncNotifierProviderRef<void> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _AssignLeadNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AssignLeadNotifier, void>
    with AssignLeadNotifierRef {
  _AssignLeadNotifierProviderElement(super.provider);

  @override
  int get leadId => (origin as AssignLeadNotifierProvider).leadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
