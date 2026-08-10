import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/tags/domain/entities/lead_tag_entity.dart';

class TagMapper {
  const TagMapper();

  LeadTagEntity? toEntity(Map<String, dynamic> json) {
    final id = OdooFieldParser.asInt(json['id']);
    final name = OdooFieldParser.asString(json['name']);
    if (id == null || name == null) return null;
    return LeadTagEntity(
      id: id,
      name: name,
      color: OdooFieldParser.asInt(json['color']),
    );
  }

  List<LeadTagEntity> toEntityList(List<Map<String, dynamic>> rows) {
    return rows.map(toEntity).whereType<LeadTagEntity>().toList();
  }
}
