// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quotationRepositoryHash() =>
    r'b5c810eddcb60e119363804028c762b19b5bd9a2';

/// See also [quotationRepository].
@ProviderFor(quotationRepository)
final quotationRepositoryProvider = Provider<QuotationRepository>.internal(
  quotationRepository,
  name: r'quotationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quotationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuotationRepositoryRef = ProviderRef<QuotationRepository>;
String _$quotationNotifierHash() => r'54af7581ac11d4ab7630484b52730b7792bb91a5';

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

abstract class _$QuotationNotifier
    extends BuildlessAsyncNotifier<QuotationResult?> {
  late final int leadId;

  FutureOr<QuotationResult?> build(int leadId);
}

/// See also [QuotationNotifier].
@ProviderFor(QuotationNotifier)
const quotationNotifierProvider = QuotationNotifierFamily();

/// See also [QuotationNotifier].
class QuotationNotifierFamily extends Family<AsyncValue<QuotationResult?>> {
  /// See also [QuotationNotifier].
  const QuotationNotifierFamily();

  /// See also [QuotationNotifier].
  QuotationNotifierProvider call(int leadId) {
    return QuotationNotifierProvider(leadId);
  }

  @override
  QuotationNotifierProvider getProviderOverride(
    covariant QuotationNotifierProvider provider,
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
  String? get name => r'quotationNotifierProvider';
}

/// See also [QuotationNotifier].
class QuotationNotifierProvider
    extends AsyncNotifierProviderImpl<QuotationNotifier, QuotationResult?> {
  /// See also [QuotationNotifier].
  QuotationNotifierProvider(int leadId)
    : this._internal(
        () => QuotationNotifier()..leadId = leadId,
        from: quotationNotifierProvider,
        name: r'quotationNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$quotationNotifierHash,
        dependencies: QuotationNotifierFamily._dependencies,
        allTransitiveDependencies:
            QuotationNotifierFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  QuotationNotifierProvider._internal(
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
  FutureOr<QuotationResult?> runNotifierBuild(
    covariant QuotationNotifier notifier,
  ) {
    return notifier.build(leadId);
  }

  @override
  Override overrideWith(QuotationNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: QuotationNotifierProvider._internal(
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
  AsyncNotifierProviderElement<QuotationNotifier, QuotationResult?>
  createElement() {
    return _QuotationNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuotationNotifierProvider && other.leadId == leadId;
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
mixin QuotationNotifierRef on AsyncNotifierProviderRef<QuotationResult?> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _QuotationNotifierProviderElement
    extends AsyncNotifierProviderElement<QuotationNotifier, QuotationResult?>
    with QuotationNotifierRef {
  _QuotationNotifierProviderElement(super.provider);

  @override
  int get leadId => (origin as QuotationNotifierProvider).leadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
