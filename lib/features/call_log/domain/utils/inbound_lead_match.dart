import 'package:odoocrm/features/leads/domain/utils/duplicate_lead_matcher.dart';

/// A CRM lead that might own an inbound caller number.
class InboundLeadCandidate {
  const InboundLeadCandidate({
    required this.id,
    this.phone,
    this.mobile,
    this.createdDate,
  });

  final int id;
  final String? phone;
  final String? mobile;
  final DateTime? createdDate;
}

/// Picks the lead an inbound device call should be logged against.
class InboundLeadMatch {
  InboundLeadMatch._();

  /// Lead whose phone or mobile shares the last 10 digits of [phone].
  ///
  /// When several leads share the number, the earliest created one wins so
  /// the call lands on the same lead outbound calls already use.
  static int? pick({
    required String phone,
    required List<InboundLeadCandidate> leads,
  }) {
    final key = DuplicateLeadMatcher.keyOf(phone);
    if (key == null) return null;

    final matches = leads.where((lead) {
      return DuplicateLeadMatcher.sharesAnyKey(
        phone: lead.phone,
        mobile: lead.mobile,
        keys: {key},
      );
    }).toList();
    if (matches.isEmpty) return null;

    matches.sort((a, b) {
      final byCreated = _compareNullableDate(a.createdDate, b.createdDate);
      if (byCreated != 0) return byCreated;
      return a.id.compareTo(b.id);
    });
    return matches.first.id;
  }

  static int _compareNullableDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}
