/// Payload for `POST /api/v1/calls/log` on the Growth backend.
class GrowthCallLogRequest {
  const GrowthCallLogRequest({
    required this.tenant,
    required this.sessionId,
    required this.callId,
    required this.callDatetime,
    required this.durationSeconds,
    required this.direction,
    required this.status,
    required this.createdAt,
    this.leadId,
    this.salesperson,
    this.activityType = 'call',
    this.phone,
  });

  final String tenant;
  final String sessionId;

  /// Odoo lead id. Null for unmatched inbound device calls.
  final int? leadId;
  final String activityType;
  final String callId;
  final String? salesperson;
  final DateTime callDatetime;
  final int durationSeconds;
  final String direction;
  final String status;
  final DateTime createdAt;

  /// Caller number for inbound device calls (digits; typically last 10).
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      'tenant': tenant,
      'session_id': sessionId,
      'lead_id': leadId,
      'activity_type': activityType,
      'call_id': callId,
      if (salesperson != null && salesperson!.trim().isNotEmpty)
        'salesperson': salesperson,
      'call_datetime': _toIsoUtc(callDatetime),
      'duration_seconds': durationSeconds < 0 ? 0 : durationSeconds,
      'direction': direction,
      'status': status,
      'created_at': _toIsoUtc(createdAt),
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
    };
  }

  factory GrowthCallLogRequest.fromJson(Map<String, dynamic> json) {
    final rawLead = json['lead_id'];
    int? leadId;
    if (rawLead is num) {
      leadId = rawLead.toInt();
    } else if (rawLead is String) {
      leadId = int.tryParse(rawLead);
    }

    return GrowthCallLogRequest(
      tenant: json['tenant'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      leadId: leadId,
      activityType: json['activity_type'] as String? ?? 'call',
      callId: json['call_id'] as String? ?? '',
      salesperson: json['salesperson'] as String?,
      callDatetime: DateTime.tryParse(json['call_datetime'] as String? ?? '') ??
          DateTime.now().toUtc(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      direction: json['direction'] as String? ?? 'outbound',
      status: json['status'] as String? ?? 'dnp',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      phone: json['phone'] as String?,
    );
  }

  GrowthCallLogRequest copyWith({
    String? tenant,
    String? sessionId,
    int? leadId,
    bool clearLeadId = false,
    String? activityType,
    String? callId,
    String? salesperson,
    DateTime? callDatetime,
    int? durationSeconds,
    String? direction,
    String? status,
    DateTime? createdAt,
    String? phone,
  }) {
    return GrowthCallLogRequest(
      tenant: tenant ?? this.tenant,
      sessionId: sessionId ?? this.sessionId,
      leadId: clearLeadId ? null : (leadId ?? this.leadId),
      activityType: activityType ?? this.activityType,
      callId: callId ?? this.callId,
      salesperson: salesperson ?? this.salesperson,
      callDatetime: callDatetime ?? this.callDatetime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
    );
  }

  /// Digits-only phone suitable for Growth; prefers last 10 digits.
  static String? normalizePhoneForApi(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  static String _toIsoUtc(DateTime value) {
    final utc = value.toUtc();
    // Ensure trailing Z (API treats naive as UTC; be explicit).
    final iso = utc.toIso8601String();
    return iso.endsWith('Z') ? iso : '${iso}Z';
  }
}
