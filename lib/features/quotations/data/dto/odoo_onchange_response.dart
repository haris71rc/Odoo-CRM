/// Parsed Odoo `sale.order.onchange` result.
class OdooOnchangeResponse {
  const OdooOnchangeResponse({
    required this.value,
    this.warning,
  });

  /// Field values initialized by Odoo for the new quotation.
  final Map<String, dynamic> value;
  final Map<String, dynamic>? warning;

  factory OdooOnchangeResponse.fromJson(dynamic json) {
    if (json is! Map) {
      return const OdooOnchangeResponse(value: {});
    }

    final map = Map<String, dynamic>.from(json);
    final rawValue = map['value'];
    final value = rawValue is Map
        ? Map<String, dynamic>.from(rawValue)
        : <String, dynamic>{};

    final rawWarning = map['warning'];
    final warning = rawWarning is Map
        ? Map<String, dynamic>.from(rawWarning)
        : null;

    return OdooOnchangeResponse(value: value, warning: warning);
  }
}
