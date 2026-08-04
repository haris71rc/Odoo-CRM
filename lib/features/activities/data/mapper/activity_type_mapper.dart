import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/activities/data/dto/activity_type_dto.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_type_entity.dart';

class ActivityTypeMapper {
  const ActivityTypeMapper();

  ActivityTypeEntity toEntity(ActivityTypeDto dto) {
    return ActivityTypeEntity(
      id: dto.id,
      name: OdooFieldParser.asString(dto.name) ?? 'Activity',
      icon: OdooFieldParser.asString(dto.icon),
      delayCount: OdooFieldParser.asInt(dto.delayCount),
      delayUnit: OdooFieldParser.asString(dto.delayUnit),
    );
  }

  List<ActivityTypeEntity> toEntityList(List<ActivityTypeDto> dtos) =>
      dtos.map(toEntity).toList();
}
