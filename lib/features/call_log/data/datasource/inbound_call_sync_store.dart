import 'dart:convert';

import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';

/// Durable watermark for incremental Android inbound call scanning.
class InboundCallSyncCursor {
  const InboundCallSyncCursor({
    required this.lastTimestampMs,
    required this.lastAndroidCallId,
    required this.initialized,
  });

  /// Epoch millis of the last successfully enqueued inbound row.
  final int lastTimestampMs;

  /// Android CallLog `_ID` tie-breaker for same-timestamp rows.
  final String lastAndroidCallId;

  /// False until the feature has been initialized (forward-only baseline).
  final bool initialized;

  static InboundCallSyncCursor uninitialized() => const InboundCallSyncCursor(
        lastTimestampMs: 0,
        lastAndroidCallId: '',
        initialized: false,
      );

  /// Forward-only baseline: start tracking from [at] (defaults to now).
  factory InboundCallSyncCursor.baselineAt([DateTime? at]) {
    final when = at ?? DateTime.now();
    return InboundCallSyncCursor(
      lastTimestampMs: when.millisecondsSinceEpoch,
      lastAndroidCallId: '',
      initialized: true,
    );
  }

  InboundCallSyncCursor copyWith({
    int? lastTimestampMs,
    String? lastAndroidCallId,
    bool? initialized,
  }) {
    return InboundCallSyncCursor(
      lastTimestampMs: lastTimestampMs ?? this.lastTimestampMs,
      lastAndroidCallId: lastAndroidCallId ?? this.lastAndroidCallId,
      initialized: initialized ?? this.initialized,
    );
  }

  Map<String, dynamic> toJson() => {
        'last_timestamp_ms': lastTimestampMs,
        'last_android_call_id': lastAndroidCallId,
        'initialized': initialized,
        'schema_version': 1,
      };

  factory InboundCallSyncCursor.fromJson(Map<String, dynamic> json) {
    return InboundCallSyncCursor(
      lastTimestampMs: (json['last_timestamp_ms'] as num?)?.toInt() ?? 0,
      lastAndroidCallId: json['last_android_call_id'] as String? ?? '',
      initialized: json['initialized'] == true,
    );
  }
}

/// Persists [InboundCallSyncCursor] in secure storage.
class InboundCallSyncStore {
  InboundCallSyncStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<InboundCallSyncCursor> load() async {
    final raw =
        await _secureStorage.read(AppConstants.inboundCallSyncCursorKey);
    if (raw == null || raw.isEmpty) {
      return InboundCallSyncCursor.uninitialized();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return InboundCallSyncCursor.fromJson(json);
    } catch (_) {
      return InboundCallSyncCursor.uninitialized();
    }
  }

  Future<void> save(InboundCallSyncCursor cursor) {
    return _secureStorage.write(
      AppConstants.inboundCallSyncCursorKey,
      jsonEncode(cursor.toJson()),
    );
  }
}
