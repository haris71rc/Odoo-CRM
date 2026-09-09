import 'dart:convert';

import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/call_log/domain/entities/growth_call_log_request.dart';

/// Queue status for a pending Growth POST.
enum GrowthOutboxStatus {
  pending,
  processing,
  failed,
}

/// One pending Growth POST kept until the API accepts it (incl. duplicates).
///
/// [callId] is the idempotency key sent to the API. Local identity is the same
/// key so upserts merge CRM dial + device sync into one queue row.
class GrowthOutboxItem {
  const GrowthOutboxItem({
    required this.request,
    required this.attempts,
    required this.enqueuedAt,
    this.lastError,
    this.lastAttemptAt,
    this.nextAttemptAt,
    this.status = GrowthOutboxStatus.pending,
    this.deadLetter = false,
  });

  final GrowthCallLogRequest request;
  final int attempts;
  final DateTime enqueuedAt;
  final String? lastError;
  final DateTime? lastAttemptAt;
  final DateTime? nextAttemptAt;
  final GrowthOutboxStatus status;
  final bool deadLetter;

  String get callId => request.callId;

  /// Local queue id — same as [callId] (API idempotency key).
  String get queueId => callId;

  GrowthOutboxItem copyWith({
    GrowthCallLogRequest? request,
    int? attempts,
    DateTime? enqueuedAt,
    String? lastError,
    DateTime? lastAttemptAt,
    DateTime? nextAttemptAt,
    GrowthOutboxStatus? status,
    bool? deadLetter,
    bool clearNextAttempt = false,
    bool clearLastError = false,
    bool clearLastAttempt = false,
  }) {
    return GrowthOutboxItem(
      request: request ?? this.request,
      attempts: attempts ?? this.attempts,
      enqueuedAt: enqueuedAt ?? this.enqueuedAt,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      lastAttemptAt:
          clearLastAttempt ? null : (lastAttemptAt ?? this.lastAttemptAt),
      nextAttemptAt:
          clearNextAttempt ? null : (nextAttemptAt ?? this.nextAttemptAt),
      status: status ?? this.status,
      deadLetter: deadLetter ?? this.deadLetter,
    );
  }

  Map<String, dynamic> toJson() => {
        'request': request.toJson(),
        'attempts': attempts,
        'enqueued_at': enqueuedAt.toUtc().toIso8601String(),
        if (lastError != null) 'last_error': lastError,
        if (lastAttemptAt != null)
          'last_attempt_at': lastAttemptAt!.toUtc().toIso8601String(),
        if (nextAttemptAt != null)
          'next_attempt_at': nextAttemptAt!.toUtc().toIso8601String(),
        'status': status.name,
        'dead_letter': deadLetter,
      };

  factory GrowthOutboxItem.fromJson(Map<String, dynamic> json) {
    final requestJson = Map<String, dynamic>.from(json['request'] as Map);
    return GrowthOutboxItem(
      request: GrowthCallLogRequest.fromJson(requestJson),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      enqueuedAt: DateTime.tryParse(json['enqueued_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      lastError: json['last_error'] as String?,
      lastAttemptAt: json['last_attempt_at'] is String
          ? DateTime.tryParse(json['last_attempt_at'] as String)
          : null,
      nextAttemptAt: json['next_attempt_at'] is String
          ? DateTime.tryParse(json['next_attempt_at'] as String)
          : null,
      status: _statusFrom(json['status'] as String?),
      deadLetter: json['dead_letter'] == true,
    );
  }

  static GrowthOutboxStatus _statusFrom(String? raw) {
    return switch (raw) {
      'processing' => GrowthOutboxStatus.processing,
      'failed' => GrowthOutboxStatus.failed,
      _ => GrowthOutboxStatus.pending,
    };
  }
}

/// Successfully accepted Growth call (for local dedupe across CRM + sync).
class GrowthAckedCall {
  const GrowthAckedCall({
    required this.callId,
    required this.leadId,
    required this.direction,
    required this.callAt,
  });

  final String callId;
  final int leadId;
  final String direction;
  final DateTime callAt;

  Map<String, dynamic> toJson() => {
        'call_id': callId,
        'lead_id': leadId,
        'direction': direction,
        'call_at': callAt.toUtc().toIso8601String(),
      };

  factory GrowthAckedCall.fromJson(Map<String, dynamic> json) {
    return GrowthAckedCall(
      callId: json['call_id'] as String? ?? '',
      leadId: (json['lead_id'] as num?)?.toInt() ?? 0,
      direction: json['direction'] as String? ?? 'outbound',
      callAt: DateTime.tryParse(json['call_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

/// Durable Growth outbox + recent acks in secure storage.
class GrowthCallOutbox {
  GrowthCallOutbox(this._secureStorage);

  final SecureStorageService _secureStorage;

  static const maxPending = 100;
  static const maxAcked = 100;
  static const maxDeadLetters = 20;

  Future<List<GrowthOutboxItem>> loadPending() async {
    final state = await _load();
    return List<GrowthOutboxItem>.from(state.pending);
  }

  Future<List<GrowthAckedCall>> loadAcked() async {
    final state = await _load();
    return List<GrowthAckedCall>.from(state.acked);
  }

  /// Inserts or merges by `call_id`. Prefer higher duration / richer status.
  Future<GrowthOutboxItem> upsert(GrowthOutboxItem item) async {
    final state = await _load();
    final pending = [...state.pending];
    final index = pending.indexWhere((e) => e.callId == item.callId);
    if (index >= 0) {
      pending[index] = _merge(pending[index], item);
    } else {
      pending.add(item);
      while (pending.length > maxPending) {
        pending.removeAt(0);
      }
    }
    await _save(state.copyWith(pending: pending));
    return index >= 0 ? pending[index] : item;
  }

  Future<void> update(GrowthOutboxItem item) async {
    final state = await _load();
    final pending = [...state.pending];
    final index = pending.indexWhere((e) => e.callId == item.callId);
    if (index < 0) return;
    pending[index] = item;
    await _save(state.copyWith(pending: pending));
  }

  Future<void> markAcked(GrowthOutboxItem item) async {
    final state = await _load();
    final pending =
        state.pending.where((e) => e.callId != item.callId).toList();
    final acked = [
      GrowthAckedCall(
        callId: item.callId,
        leadId: item.request.leadId,
        direction: item.request.direction,
        callAt: item.request.callDatetime,
      ),
      ...state.acked.where((e) => e.callId != item.callId),
    ];
    while (acked.length > maxAcked) {
      acked.removeLast();
    }
    final dead =
        state.dead.where((e) => e.callId != item.callId).toList();
    await _save(
      _OutboxState(pending: pending, acked: acked, dead: dead),
    );
  }

  Future<void> markDead(GrowthOutboxItem item) async {
    final state = await _load();
    final pending =
        state.pending.where((e) => e.callId != item.callId).toList();
    final dead = [
      item.copyWith(deadLetter: true),
      ...state.dead.where((e) => e.callId != item.callId),
    ];
    while (dead.length > maxDeadLetters) {
      dead.removeLast();
    }
    await _save(state.copyWith(pending: pending, dead: dead));
  }

  Future<_OutboxState> _load() async {
    final raw =
        await _secureStorage.read(AppConstants.growthCallOutboxKey);
    if (raw == null || raw.isEmpty) {
      return const _OutboxState();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _OutboxState.fromJson(json);
    } catch (_) {
      return const _OutboxState();
    }
  }

  Future<void> _save(_OutboxState state) {
    return _secureStorage.write(
      AppConstants.growthCallOutboxKey,
      jsonEncode(state.toJson()),
    );
  }

  GrowthOutboxItem _merge(GrowthOutboxItem existing, GrowthOutboxItem incoming) {
    final a = existing.request;
    final b = incoming.request;
    final richerDuration = b.durationSeconds > a.durationSeconds
        ? b.durationSeconds
        : a.durationSeconds;
    final richerStatus = _preferStatus(a.status, b.status);
    return existing.copyWith(
      request: a.copyWith(
        sessionId: b.sessionId.isNotEmpty ? b.sessionId : a.sessionId,
        durationSeconds: richerDuration,
        status: richerStatus,
        salesperson: (b.salesperson?.trim().isNotEmpty == true)
            ? b.salesperson
            : a.salesperson,
      ),
      // Keep attempts from the older entry so retries continue.
      status: GrowthOutboxStatus.pending,
      clearNextAttempt: true,
      clearLastError: true,
      deadLetter: false,
    );
  }

  String _preferStatus(String current, String incoming) {
    if (incoming.trim().isEmpty) return current;
    if (current.trim().isEmpty || current == 'unknown') return incoming;
    // Prefer non-zero-signal statuses over placeholders.
    const weak = {'unknown', 'completed', 'call_failed'};
    if (weak.contains(current) && !weak.contains(incoming)) return incoming;
    return incoming;
  }
}

class _OutboxState {
  const _OutboxState({
    this.pending = const [],
    this.acked = const [],
    this.dead = const [],
  });

  final List<GrowthOutboxItem> pending;
  final List<GrowthAckedCall> acked;
  final List<GrowthOutboxItem> dead;

  _OutboxState copyWith({
    List<GrowthOutboxItem>? pending,
    List<GrowthAckedCall>? acked,
    List<GrowthOutboxItem>? dead,
  }) {
    return _OutboxState(
      pending: pending ?? this.pending,
      acked: acked ?? this.acked,
      dead: dead ?? this.dead,
    );
  }

  Map<String, dynamic> toJson() => {
        'pending': pending.map((e) => e.toJson()).toList(),
        'acked': acked.map((e) => e.toJson()).toList(),
        'dead': dead.map((e) => e.toJson()).toList(),
      };

  factory _OutboxState.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> asMaps(dynamic value) {
      if (value is! List) return const [];
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return _OutboxState(
      pending: asMaps(json['pending']).map(GrowthOutboxItem.fromJson).toList(),
      acked: asMaps(json['acked']).map(GrowthAckedCall.fromJson).toList(),
      dead: asMaps(json['dead']).map(GrowthOutboxItem.fromJson).toList(),
    );
  }
}
