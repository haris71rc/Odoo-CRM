import 'package:odoocrm/core/utils/odoo_field_parser.dart';

/// Phone fields used to find leads that share a number.
class LeadPhoneSnapshot {
  const LeadPhoneSnapshot({
    required this.id,
    this.phone,
    this.mobile,
    this.createdDate,
  });

  final int id;
  final String? phone;
  final String? mobile;
  final DateTime? createdDate;

  factory LeadPhoneSnapshot.fromJson(Map<String, dynamic> json) {
    final id = OdooFieldParser.asInt(json['id']);
    if (id == null) {
      throw const FormatException('Lead phone snapshot missing id');
    }
    return LeadPhoneSnapshot(
      id: id,
      phone: OdooFieldParser.asString(json['phone']),
      mobile: OdooFieldParser.asString(json['mobile']),
      createdDate: OdooFieldParser.asDateTime(json['create_date']),
    );
  }
}
