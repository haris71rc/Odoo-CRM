import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/activities/data/dto/activity_dto.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';

class ActivityMapper {
  const ActivityMapper();

  ActivityEntity toEntity(ActivityDto dto) {
    final type = OdooFieldParser.asMany2One(dto.activityTypeId);
    final user = OdooFieldParser.asMany2One(dto.userId);

    return ActivityEntity(
      id: dto.id,
      summary: OdooFieldParser.asString(dto.summary) ?? 'Activity',
      note: OdooFieldParser.asString(dto.note),
      dateDeadline: OdooFieldParser.asDateTime(dto.dateDeadline),
      activityType: type?.name,
      state: OdooFieldParser.asString(dto.state),
      userName: user?.name,
    );
  }

  List<ActivityEntity> toEntityList(List<ActivityDto> dtos) =>
      dtos.map(toEntity).toList();
}
