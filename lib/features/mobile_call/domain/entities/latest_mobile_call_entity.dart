/// Domain model for a mobile call logged via Odoo Chatter.
class LatestMobileCallEntity {
  const LatestMobileCallEntity({
    required this.status,
    required this.duration,
    required this.direction,
    required this.phone,
    required this.timestamp,
    this.userId,
    this.messageId,
    this.loggedAt,
  });

  /// Call outcome: answered, no_answer, busy, missed, rejected.
  final String status;

  /// Call duration in seconds.
  final int duration;

  /// outgoing | incoming
  final String direction;

  final String phone;

  /// Dialer / device timestamp embedded in the log JSON.
  final DateTime timestamp;

  /// Odoo `res.users` id of the salesperson who placed the call.
  final int? userId;

  /// `mail.message` id of the Log Note (authoritative ordering).
  final int? messageId;

  /// When the Log Note was posted in Odoo (authoritative for stage checks).
  final DateTime? loggedAt;

  bool get isAnswered => status.toLowerCase() == 'answered';

  bool get isUnanswered {
    const unanswered = {'no_answer', 'busy', 'missed', 'rejected'};
    return unanswered.contains(status.toLowerCase());
  }

  LatestMobileCallEntity copyWith({
    String? status,
    int? duration,
    String? direction,
    String? phone,
    DateTime? timestamp,
    int? userId,
    int? messageId,
    DateTime? loggedAt,
  }) {
    return LatestMobileCallEntity(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      direction: direction ?? this.direction,
      phone: phone ?? this.phone,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      messageId: messageId ?? this.messageId,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}
