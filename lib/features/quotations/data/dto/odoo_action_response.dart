/// Parsed Odoo `ir.actions.act_window` payload from
/// `crm.lead.action_sale_quotations_new`.
class OdooActionResponse {
  const OdooActionResponse({
    required this.resModel,
    required this.context,
    this.name,
    this.type,
  });

  final String? resModel;
  final Map<String, dynamic> context;
  final String? name;
  final String? type;

  /// True when Odoo returned the new-quotation form action for `sale.order`.
  bool get isNewQuotationAction => resModel == 'sale.order';

  /// True when Odoo asks to create/select a customer first.
  bool get requiresPartner =>
      resModel != null &&
      resModel != 'sale.order' &&
      (resModel!.contains('partner') || resModel!.contains('quotation.partner'));

  factory OdooActionResponse.fromJson(Map<String, dynamic> json) {
    final rawContext = json['context'];
    final context = <String, dynamic>{};
    if (rawContext is Map) {
      context.addAll(Map<String, dynamic>.from(rawContext));
    }

    return OdooActionResponse(
      resModel: json['res_model']?.toString(),
      context: context,
      name: json['name']?.toString(),
      type: json['type']?.toString(),
    );
  }
}
