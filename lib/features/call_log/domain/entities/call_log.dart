/// Call log information stored in Odoo `crm.lead.lead_properties`.
class CallLog {
  const CallLog({
    this.firstCallDate,
    this.lastCallDate,
    this.duration,
    this.status,
    this.totalDuration,
    this.totalInboundCalls,
    this.totalOutboundCalls,
    this.responseTimeMinutes,
  });

  /// Call Date & Time (First) — first outbound call by the salesperson.
  final DateTime? firstCallDate;

  /// Call Date & Time (Last) — most recent call.
  final DateTime? lastCallDate;

  /// Latest call duration (`MM:SS`) from the most recent event.
  final String? duration;

  /// Call Status tag from the most recent call.
  final String? status;

  /// Total Call Duration — cumulative duration across all logged calls.
  final String? totalDuration;

  /// Total InBound Calls from the lead's phone number.
  final int? totalInboundCalls;

  /// Total Outbound Calls placed from the app.
  final int? totalOutboundCalls;

  /// Response Time (Minutes) — lead creation → first outbound call.
  final double? responseTimeMinutes;

  bool get hasCall => lastCallDate != null;

  bool get hasAnyCallData =>
      firstCallDate != null ||
      lastCallDate != null ||
      (totalDuration != null && totalDuration!.trim().isNotEmpty) ||
      (duration != null && duration!.trim().isNotEmpty) ||
      (status != null && status!.trim().isNotEmpty) ||
      (totalInboundCalls ?? 0) > 0 ||
      (totalOutboundCalls ?? 0) > 0 ||
      responseTimeMinutes != null;

  CallLog copyWith({
    DateTime? firstCallDate,
    DateTime? lastCallDate,
    String? duration,
    String? status,
    String? totalDuration,
    int? totalInboundCalls,
    int? totalOutboundCalls,
    double? responseTimeMinutes,
  }) {
    return CallLog(
      firstCallDate: firstCallDate ?? this.firstCallDate,
      lastCallDate: lastCallDate ?? this.lastCallDate,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      totalDuration: totalDuration ?? this.totalDuration,
      totalInboundCalls: totalInboundCalls ?? this.totalInboundCalls,
      totalOutboundCalls: totalOutboundCalls ?? this.totalOutboundCalls,
      responseTimeMinutes: responseTimeMinutes ?? this.responseTimeMinutes,
    );
  }
}
