/// A CRM Call tap that still needs the Android dialer row.
class PendingOutboundDial {
  const PendingOutboundDial({
    required this.leadId,
    required this.phone,
    required this.dialedAt,
    this.awaitingDuration = false,
    this.passive = false,
  });

  final int leadId;
  final String phone;
  final DateTime dialedAt;

  /// Odoo already has this dial at `00:00`; a later resume may fill duration.
  final bool awaitingDuration;

  /// Do not block another Call tap. Resume still tries to sync this dial.
  final bool passive;

  bool get blocksNewCall => !passive && !awaitingDuration;

  PendingOutboundDial copyWith({
    bool? awaitingDuration,
    bool? passive,
  }) {
    return PendingOutboundDial(
      leadId: leadId,
      phone: phone,
      dialedAt: dialedAt,
      awaitingDuration: awaitingDuration ?? this.awaitingDuration,
      passive: passive ?? this.passive,
    );
  }

  Map<String, dynamic> toJson() => {
        'lead_id': leadId,
        'phone': phone,
        'dialed_at_ms': dialedAt.millisecondsSinceEpoch,
        'awaiting_duration': awaitingDuration,
        'passive': passive,
      };

  factory PendingOutboundDial.fromJson(Map<String, dynamic> json) {
    final leadId = (json['lead_id'] as num?)?.toInt();
    final phone = json['phone'] as String?;
    final dialedAtMs = (json['dialed_at_ms'] as num?)?.toInt();
    if (leadId == null || phone == null || phone.isEmpty || dialedAtMs == null) {
      throw const FormatException('Invalid pending outbound dial');
    }
    return PendingOutboundDial(
      leadId: leadId,
      phone: phone,
      dialedAt: DateTime.fromMillisecondsSinceEpoch(dialedAtMs),
      awaitingDuration: json['awaiting_duration'] == true,
      passive: json['passive'] == true,
    );
  }
}
