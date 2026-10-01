/// One lead considered while looking for a shared phone number.
class DuplicateLeadCandidate {
  const DuplicateLeadCandidate({
    required this.id,
    this.phone,
    this.mobile,
    this.createdDate,
    this.firstCallDate,
    this.totalOutboundCalls = 0,
  });

  final int id;
  final String? phone;
  final String? mobile;
  final DateTime? createdDate;

  /// First outbound call stored on the lead.
  final DateTime? firstCallDate;

  /// Outbound calls the salesperson has already placed.
  final int totalOutboundCalls;

  bool get wasCalled => firstCallDate != null || totalOutboundCalls > 0;
}
