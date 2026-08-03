import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/leads/data/dto/lead_detail_dto.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/named_ref_entity.dart';

class LeadDetailMapper {
  const LeadDetailMapper();

  LeadDetailEntity toEntity(LeadDetailDto dto) {
    NamedRefEntity? mapRef(dynamic value) {
      final ref = OdooFieldParser.asMany2One(value);
      if (ref == null) return null;
      return NamedRefEntity(id: ref.id, name: ref.name);
    }

    return LeadDetailEntity(
      id: dto.id,
      name: OdooFieldParser.asString(dto.name) ?? 'Untitled Lead',
      partnerName: OdooFieldParser.asString(dto.partnerName),
      phone: OdooFieldParser.asString(dto.phone),
      mobile: OdooFieldParser.asString(dto.mobile),
      email: OdooFieldParser.asString(dto.emailFrom),
      street: OdooFieldParser.asString(dto.street),
      city: OdooFieldParser.asString(dto.city),
      state: mapRef(dto.stateId),
      country: mapRef(dto.countryId),
      zip: OdooFieldParser.asString(dto.zip),
      description: OdooFieldParser.asString(dto.description),
      stage: mapRef(dto.stageId),
      assignedUser: mapRef(dto.userId),
      team: mapRef(dto.teamId),
      priority: OdooFieldParser.asString(dto.priority),
      createdDate: OdooFieldParser.asDateTime(dto.createDate),
      writeDate: OdooFieldParser.asDateTime(dto.writeDate),
      expectedRevenue: OdooFieldParser.asDouble(dto.expectedRevenue),
      probability: OdooFieldParser.asDouble(dto.probability),
      tagIds: OdooFieldParser.asIdList(dto.tagIds),
    );
  }
}
