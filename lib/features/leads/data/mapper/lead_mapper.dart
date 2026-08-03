import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/leads/data/dto/lead_dto.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/named_ref_entity.dart';

class LeadMapper {
  const LeadMapper();

  LeadEntity toEntity(LeadDto dto) {
    final stage = OdooFieldParser.asMany2One(dto.stageId);
    final user = OdooFieldParser.asMany2One(dto.userId);

    return LeadEntity(
      id: dto.id,
      name: OdooFieldParser.asString(dto.name) ?? 'Untitled Lead',
      phone: OdooFieldParser.asString(dto.phone),
      partnerName: OdooFieldParser.asString(dto.partnerName),
      stage: stage == null
          ? null
          : NamedRefEntity(id: stage.id, name: stage.name),
      assignedUser: user == null
          ? null
          : NamedRefEntity(id: user.id, name: user.name),
      priority: OdooFieldParser.asString(dto.priority),
      createdDate: OdooFieldParser.asDateTime(dto.createDate),
      description: OdooFieldParser.asString(dto.description),
    );
  }

  List<LeadEntity> toEntityList(List<LeadDto> dtos) =>
      dtos.map(toEntity).toList();
}
