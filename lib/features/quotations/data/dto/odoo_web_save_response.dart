/// Parsed Odoo `sale.order.web_save` result (list of saved records).
class OdooWebSaveResponse {
  const OdooWebSaveResponse({
    required this.quotationId,
    this.quotationNumber,
  });

  final int quotationId;
  final String? quotationNumber;

  factory OdooWebSaveResponse.fromJson(dynamic json) {
    if (json is! List || json.isEmpty) {
      throw const FormatException('Unexpected web_save response');
    }

    final first = json.first;
    if (first is! Map) {
      throw const FormatException('Unexpected web_save record');
    }

    final record = Map<String, dynamic>.from(first);
    final id = record['id'];
    if (id is! int) {
      throw const FormatException('web_save response missing quotation id');
    }

    final name = record['name'];
    return OdooWebSaveResponse(
      quotationId: id,
      quotationNumber: name is String && name.isNotEmpty ? name : null,
    );
  }
}
