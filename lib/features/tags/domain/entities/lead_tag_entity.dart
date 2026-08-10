/// Domain model for an Odoo `crm.tag` used by lead temperature filters.
class LeadTagEntity {
  const LeadTagEntity({
    required this.id,
    required this.name,
    this.color,
  });

  final int id;
  final String name;
  final int? color;
}
