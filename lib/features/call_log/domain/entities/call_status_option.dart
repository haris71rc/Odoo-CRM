/// A selectable Call Status tag defined on the lead's Odoo property field.
class CallStatusOption {
  const CallStatusOption({
    required this.key,
    required this.label,
  });

  /// Odoo tag key stored in `lead_properties` (e.g. `dnp`, `picked`).
  final String key;

  /// Human-readable label shown in the UI (e.g. `DNP`, `Picked`).
  final String label;
}
