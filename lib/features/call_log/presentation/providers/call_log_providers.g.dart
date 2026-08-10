// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$callLogRepositoryHash() => r'41cc4ccb63bc86cb4ae2d1a39aebdf281ecb479d';

/// See also [callLogRepository].
@ProviderFor(callLogRepository)
final callLogRepositoryProvider = Provider<CallLogRepository>.internal(
  callLogRepository,
  name: r'callLogRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$callLogRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CallLogRepositoryRef = ProviderRef<CallLogRepository>;
String _$callLogServiceHash() => r'a8f8b1f898ef03e82e174b5b3d632defebc4fdf8';

/// See also [callLogService].
@ProviderFor(callLogService)
final callLogServiceProvider = Provider<CallLogService>.internal(
  callLogService,
  name: r'callLogServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$callLogServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CallLogServiceRef = ProviderRef<CallLogService>;
String _$deviceCallReaderHash() => r'3e415f7e48e6e001e6410e694731857e1879bc75';

/// See also [deviceCallReader].
@ProviderFor(deviceCallReader)
final deviceCallReaderProvider = Provider<DeviceCallReader>.internal(
  deviceCallReader,
  name: r'deviceCallReaderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceCallReaderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceCallReaderRef = ProviderRef<DeviceCallReader>;
String _$leadCallLogHash() => r'a4abe59ca36efe795ecf9bc76b075d0316973a97';

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

/// Prefetched when Lead Detail opens. Also syncs inbound calls from device.
///
/// Copied from [leadCallLog].
@ProviderFor(leadCallLog)
const leadCallLogProvider = LeadCallLogFamily();

/// Prefetched when Lead Detail opens. Also syncs inbound calls from device.
///
/// Copied from [leadCallLog].
class LeadCallLogFamily extends Family<AsyncValue<CallLog>> {
  /// Prefetched when Lead Detail opens. Also syncs inbound calls from device.
  ///
  /// Copied from [leadCallLog].
  const LeadCallLogFamily();

  /// Prefetched when Lead Detail opens. Also syncs inbound calls from device.
  ///
  /// Copied from [leadCallLog].
  LeadCallLogProvider call(int leadId) {
    return LeadCallLogProvider(leadId);
  }

  @override
  LeadCallLogProvider getProviderOverride(
    covariant LeadCallLogProvider provider,
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
  String? get name => r'leadCallLogProvider';
}

/// Prefetched when Lead Detail opens. Also syncs inbound calls from device.
///
/// Copied from [leadCallLog].
class LeadCallLogProvider extends AutoDisposeFutureProvider<CallLog> {
  /// Prefetched when Lead Detail opens. Also syncs inbound calls from device.
  ///
  /// Copied from [leadCallLog].
  LeadCallLogProvider(int leadId)
    : this._internal(
        (ref) => leadCallLog(ref as LeadCallLogRef, leadId),
        from: leadCallLogProvider,
        name: r'leadCallLogProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$leadCallLogHash,
        dependencies: LeadCallLogFamily._dependencies,
        allTransitiveDependencies: LeadCallLogFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  LeadCallLogProvider._internal(
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
    FutureOr<CallLog> Function(LeadCallLogRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LeadCallLogProvider._internal(
        (ref) => create(ref as LeadCallLogRef),
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
  AutoDisposeFutureProviderElement<CallLog> createElement() {
    return _LeadCallLogProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadCallLogProvider && other.leadId == leadId;
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
mixin LeadCallLogRef on AutoDisposeFutureProviderRef<CallLog> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _LeadCallLogProviderElement
    extends AutoDisposeFutureProviderElement<CallLog>
    with LeadCallLogRef {
  _LeadCallLogProviderElement(super.provider);

  @override
  int get leadId => (origin as LeadCallLogProvider).leadId;
}

String _$callStatusOptionsHash() => r'0019dbe9ffdd6f532e333465d04a759c02c2c041';

/// Call Status tag options from Odoo `lead_properties` for this lead.
///
/// Copied from [callStatusOptions].
@ProviderFor(callStatusOptions)
const callStatusOptionsProvider = CallStatusOptionsFamily();

/// Call Status tag options from Odoo `lead_properties` for this lead.
///
/// Copied from [callStatusOptions].
class CallStatusOptionsFamily
    extends Family<AsyncValue<List<CallStatusOption>>> {
  /// Call Status tag options from Odoo `lead_properties` for this lead.
  ///
  /// Copied from [callStatusOptions].
  const CallStatusOptionsFamily();

  /// Call Status tag options from Odoo `lead_properties` for this lead.
  ///
  /// Copied from [callStatusOptions].
  CallStatusOptionsProvider call(int leadId) {
    return CallStatusOptionsProvider(leadId);
  }

  @override
  CallStatusOptionsProvider getProviderOverride(
    covariant CallStatusOptionsProvider provider,
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
  String? get name => r'callStatusOptionsProvider';
}

/// Call Status tag options from Odoo `lead_properties` for this lead.
///
/// Copied from [callStatusOptions].
class CallStatusOptionsProvider
    extends AutoDisposeFutureProvider<List<CallStatusOption>> {
  /// Call Status tag options from Odoo `lead_properties` for this lead.
  ///
  /// Copied from [callStatusOptions].
  CallStatusOptionsProvider(int leadId)
    : this._internal(
        (ref) => callStatusOptions(ref as CallStatusOptionsRef, leadId),
        from: callStatusOptionsProvider,
        name: r'callStatusOptionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$callStatusOptionsHash,
        dependencies: CallStatusOptionsFamily._dependencies,
        allTransitiveDependencies:
            CallStatusOptionsFamily._allTransitiveDependencies,
        leadId: leadId,
      );

  CallStatusOptionsProvider._internal(
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
    FutureOr<List<CallStatusOption>> Function(CallStatusOptionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CallStatusOptionsProvider._internal(
        (ref) => create(ref as CallStatusOptionsRef),
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
  AutoDisposeFutureProviderElement<List<CallStatusOption>> createElement() {
    return _CallStatusOptionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CallStatusOptionsProvider && other.leadId == leadId;
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
mixin CallStatusOptionsRef
    on AutoDisposeFutureProviderRef<List<CallStatusOption>> {
  /// The parameter `leadId` of this provider.
  int get leadId;
}

class _CallStatusOptionsProviderElement
    extends AutoDisposeFutureProviderElement<List<CallStatusOption>>
    with CallStatusOptionsRef {
  _CallStatusOptionsProviderElement(super.provider);

  @override
  int get leadId => (origin as CallStatusOptionsProvider).leadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
