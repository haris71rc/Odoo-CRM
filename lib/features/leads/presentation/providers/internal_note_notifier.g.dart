// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internal_note_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$internalNoteNotifierHash() =>
    r'02ba14e22118e8bc012457af121cdeb80e4b2afe';

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

abstract class _$InternalNoteNotifier
    extends BuildlessAutoDisposeNotifier<InternalNoteState> {
  late final int leadId;

  InternalNoteState build(int leadId);
}

/// See also [InternalNoteNotifier].
@ProviderFor(InternalNoteNotifier)
const internalNoteNotifierProvider = InternalNoteNotifierFamily();

/// See also [InternalNoteNotifier].
class InternalNoteNotifierFamily extends Family<InternalNoteState> {
  /// See also [InternalNoteNotifier].
  const InternalNoteNotifierFamily();

  /// See also [InternalNoteNotifier].
  InternalNoteNotifierProvider call(int leadId) {
    return InternalNoteNotifierProvider(leadId);
  }

  @override
  InternalNoteNotifierProvider getProviderOverride(
    covariant InternalNoteNotifierProvider provider,
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
  String? get name => r'internalNoteNotifierProvider';
}

/// See also [InternalNoteNotifier].
class InternalNoteNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          InternalNoteNotifier,
          InternalNoteState
        > {
  /// See also [InternalNoteNotifier].
  InternalNoteNotifierProvider(int leadId)
    : this._internal(
        () => InternalNoteNotifier()..leadId = leadId,
        from: internalNoteNotifierProvider,
        name: r'internalNoteNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$internalNoteNotifierHash,
        dependencies: InternalNoteNotifierFamily._dependencies,
        allTransitiveDependencies:
            InternalNoteNotifierFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  InternalNoteNotifierProvider._internal(
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
  InternalNoteState runNotifierBuild(covariant InternalNoteNotifier notifier) {
    return notifier.build(leadId);
  }

  @override
  Override overrideWith(InternalNoteNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: InternalNoteNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<InternalNoteNotifier, InternalNoteState>
  createElement() {
    return _InternalNoteNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InternalNoteNotifierProvider && other.leadId == leadId;
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
mixin InternalNoteNotifierRef
    on AutoDisposeNotifierProviderRef<InternalNoteState> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _InternalNoteNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          InternalNoteNotifier,
          InternalNoteState
        >
    with InternalNoteNotifierRef {
  _InternalNoteNotifierProviderElement(super.provider);

  @override
  int get leadId => (origin as InternalNoteNotifierProvider).leadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
