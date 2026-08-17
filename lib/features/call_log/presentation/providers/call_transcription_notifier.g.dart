// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_transcription_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$callTranscriptionNotifierHash() =>
    r'8698f4539a4671c6db668632997f0fa383a351f1';

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

abstract class _$CallTranscriptionNotifier
    extends BuildlessAutoDisposeNotifier<CallTranscriptionState> {
  late final int leadId;

  CallTranscriptionState build(int leadId);
}

/// See also [CallTranscriptionNotifier].
@ProviderFor(CallTranscriptionNotifier)
const callTranscriptionNotifierProvider = CallTranscriptionNotifierFamily();

/// See also [CallTranscriptionNotifier].
class CallTranscriptionNotifierFamily extends Family<CallTranscriptionState> {
  /// See also [CallTranscriptionNotifier].
  const CallTranscriptionNotifierFamily();

  /// See also [CallTranscriptionNotifier].
  CallTranscriptionNotifierProvider call(int leadId) {
    return CallTranscriptionNotifierProvider(leadId);
  }

  @override
  CallTranscriptionNotifierProvider getProviderOverride(
    covariant CallTranscriptionNotifierProvider provider,
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
  String? get name => r'callTranscriptionNotifierProvider';
}

/// See also [CallTranscriptionNotifier].
class CallTranscriptionNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          CallTranscriptionNotifier,
          CallTranscriptionState
        > {
  /// See also [CallTranscriptionNotifier].
  CallTranscriptionNotifierProvider(int leadId)
    : this._internal(
        () => CallTranscriptionNotifier()..leadId = leadId,
        from: callTranscriptionNotifierProvider,
        name: r'callTranscriptionNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$callTranscriptionNotifierHash,
        dependencies: CallTranscriptionNotifierFamily._dependencies,
        allTransitiveDependencies:
            CallTranscriptionNotifierFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  CallTranscriptionNotifierProvider._internal(
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
  CallTranscriptionState runNotifierBuild(
    covariant CallTranscriptionNotifier notifier,
  ) {
    return notifier.build(leadId);
  }

  @override
  Override overrideWith(CallTranscriptionNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CallTranscriptionNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<
    CallTranscriptionNotifier,
    CallTranscriptionState
  >
  createElement() {
    return _CallTranscriptionNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CallTranscriptionNotifierProvider && other.leadId == leadId;
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
mixin CallTranscriptionNotifierRef
    on AutoDisposeNotifierProviderRef<CallTranscriptionState> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _CallTranscriptionNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          CallTranscriptionNotifier,
          CallTranscriptionState
        >
    with CallTranscriptionNotifierRef {
  _CallTranscriptionNotifierProviderElement(super.provider);

  @override
  int get leadId => (origin as CallTranscriptionNotifierProvider).leadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
