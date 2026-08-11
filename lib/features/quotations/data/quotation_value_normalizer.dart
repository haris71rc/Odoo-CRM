/// Converts Odoo onchange field values into `web_save`-compatible vals.
///
/// Onchange returns values in `web_read` format:
/// - many2one: `{id, display_name}` (or legacy `[id, name]`)
/// - x2many: command lists
///
/// `web_save` expects plain integer ids for many2one fields.
/// Only writable sale.order fields are kept.
class QuotationValueNormalizer {
  const QuotationValueNormalizer();

  /// Fields accepted when creating a quotation via `web_save`.
  static const writableFields = <String>{
    'partner_id',
    'partner_invoice_id',
    'partner_shipping_id',
    'pricelist_id',
    'currency_id',
    'payment_term_id',
    'fiscal_position_id',
    'company_id',
    'user_id',
    'team_id',
    'opportunity_id',
    'campaign_id',
    'medium_id',
    'source_id',
    'origin',
    'tag_ids',
    'date_order',
    'validity_date',
    'client_order_ref',
    'note',
    'order_line',
    'warehouse_id',
    'incoterm',
    'require_signature',
    'require_payment',
  };

  Map<String, dynamic> toWebSaveValues(
    Map<String, dynamic> onchangeValue, {
    Map<String, dynamic> actionContext = const {},
  }) {
    final merged = Map<String, dynamic>.from(onchangeValue);
    _applyContextDefaults(merged, actionContext);

    final values = <String, dynamic>{};
    for (final entry in merged.entries) {
      if (!writableFields.contains(entry.key)) continue;
      final normalized = _normalizeFieldValue(entry.value);
      if (normalized == null) continue;
      values[entry.key] = normalized;
    }
    return values;
  }

  void _applyContextDefaults(
    Map<String, dynamic> values,
    Map<String, dynamic> context,
  ) {
    void apply(String field, String defaultKey) {
      final current = values[field];
      if (!_isEmpty(current)) return;
      final raw = context[defaultKey];
      if (_isEmpty(raw)) return;
      values[field] = raw;
    }

    apply('opportunity_id', 'default_opportunity_id');
    apply('partner_id', 'default_partner_id');
    apply('company_id', 'default_company_id');
    apply('team_id', 'default_team_id');
    apply('user_id', 'default_user_id');
    apply('campaign_id', 'default_campaign_id');
    apply('medium_id', 'default_medium_id');
    apply('source_id', 'default_source_id');
    apply('origin', 'default_origin');
    apply('tag_ids', 'default_tag_ids');
  }

  bool _isEmpty(dynamic value) {
    if (value == null || value == false) return true;
    if (value is Map) {
      final id = value['id'];
      return id == null || id == false || id == 0;
    }
    if (value is int) return value == 0;
    return false;
  }

  dynamic _normalizeFieldValue(dynamic value) {
    if (value == null || value == false) return null;

    // web_read many2one: {id: 12, display_name: "Acme"}
    if (value is Map) {
      final id = value['id'];
      if (id is int) return id == 0 ? null : id;
      if (id is Map && id['id'] is int) {
        final nestedId = id['id'] as int;
        return nestedId == 0 ? null : nestedId;
      }
      return null;
    }

    // Legacy many2one tuple: [id, name] OR x2many commands: [[6, 0, [ids]], ...]
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is int) {
        if (value.length == 2 && (value[1] is String || value[1] == false)) {
          return first == 0 ? null : first;
        }
        return value;
      }
      if (first is List) {
        return value;
      }
    }

    if (value is int) return value == 0 ? null : value;
    if (value is double || value is String || value is bool) return value;

    return value;
  }
}
