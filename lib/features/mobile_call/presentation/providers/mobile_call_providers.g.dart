// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_call_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mobileCallRepositoryHash() =>
    r'f9b3764dc3714a94d61f16725bd491f055f4994f';

/// See also [mobileCallRepository].
@ProviderFor(mobileCallRepository)
final mobileCallRepositoryProvider = Provider<MobileCallRepository>.internal(
  mobileCallRepository,
  name: r'mobileCallRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mobileCallRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MobileCallRepositoryRef = ProviderRef<MobileCallRepository>;
String _$callLogReaderHash() => r'a9ef977ff072e0c260ad5f5d860c7a5e4e055d53';

/// See also [callLogReader].
@ProviderFor(callLogReader)
final callLogReaderProvider = Provider<CallLogReader>.internal(
  callLogReader,
  name: r'callLogReaderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$callLogReaderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CallLogReaderRef = ProviderRef<CallLogReader>;
String _$latestMobileCallHash() => r'18ffb7e6d088df481437f78138a5fa359d334e51';

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

/// Prefetches the latest MOBILE_CALL log when Lead Detail opens.
///
/// Copied from [latestMobileCall].
@ProviderFor(latestMobileCall)
const latestMobileCallProvider = LatestMobileCallFamily();

/// Prefetches the latest MOBILE_CALL log when Lead Detail opens.
///
/// Copied from [latestMobileCall].
class LatestMobileCallFamily
    extends Family<AsyncValue<LatestMobileCallEntity?>> {
  /// Prefetches the latest MOBILE_CALL log when Lead Detail opens.
  ///
  /// Copied from [latestMobileCall].
  const LatestMobileCallFamily();

  /// Prefetches the latest MOBILE_CALL log when Lead Detail opens.
  ///
  /// Copied from [latestMobileCall].
  LatestMobileCallProvider call(int leadId) {
    return LatestMobileCallProvider(leadId);
  }

  @override
  LatestMobileCallProvider getProviderOverride(
    covariant LatestMobileCallProvider provider,
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
  String? get name => r'latestMobileCallProvider';
}

/// Prefetches the latest MOBILE_CALL log when Lead Detail opens.
///
/// Copied from [latestMobileCall].
class LatestMobileCallProvider
    extends AutoDisposeFutureProvider<LatestMobileCallEntity?> {
  /// Prefetches the latest MOBILE_CALL log when Lead Detail opens.
  ///
  /// Copied from [latestMobileCall].
  LatestMobileCallProvider(int leadId)
    : this._internal(
        (ref) => latestMobileCall(ref as LatestMobileCallRef, leadId),
        from: latestMobileCallProvider,
        name: r'latestMobileCallProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$latestMobileCallHash,
        dependencies: LatestMobileCallFamily._dependencies,
        allTransitiveDependencies:
            LatestMobileCallFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  LatestMobileCallProvider._internal(
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
  Override overrideWith(
    FutureOr<LatestMobileCallEntity?> Function(LatestMobileCallRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LatestMobileCallProvider._internal(
        (ref) => create(ref as LatestMobileCallRef),
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
  AutoDisposeFutureProviderElement<LatestMobileCallEntity?> createElement() {
    return _LatestMobileCallProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestMobileCallProvider && other.leadId == leadId;
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
mixin LatestMobileCallRef
    on AutoDisposeFutureProviderRef<LatestMobileCallEntity?> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _LatestMobileCallProviderElement
    extends AutoDisposeFutureProviderElement<LatestMobileCallEntity?>
    with LatestMobileCallRef {
  _LatestMobileCallProviderElement(super.provider);

  @override
  int get leadId => (origin as LatestMobileCallProvider).leadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
