/// Known CRM lead temperature tags fetched by name from `crm.tag`.
enum LeadTemperatureTag {
  hot(
    apiName: 'HOT_LEAD',
    label: 'Hot Leads',
  ),
  warm(
    apiName: 'WARM_LEAD',
    label: 'Warm Leads',
  );

  const LeadTemperatureTag({
    required this.apiName,
    required this.label,
  });

  /// Exact Odoo `crm.tag.name` value.
  final String apiName;

  /// UI label shown in the filter sheet / chips.
  final String label;

  static const temperatureApiNames = ['HOT_LEAD', 'WARM_LEAD'];

  static LeadTemperatureTag? fromApiName(String name) {
    final normalized = name.trim().toUpperCase();
    for (final tag in LeadTemperatureTag.values) {
      if (tag.apiName == normalized) return tag;
    }
    return null;
  }
}
