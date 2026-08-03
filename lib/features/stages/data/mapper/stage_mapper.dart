import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/stages/data/dto/stage_dto.dart';
import 'package:odoocrm/features/stages/domain/entities/stage_entity.dart';

class StageMapper {
  const StageMapper();

  StageEntity toEntity(StageDto dto) {
    return StageEntity(
      id: dto.id,
      name: OdooFieldParser.asString(dto.name) ?? 'Stage',
      sequence: OdooFieldParser.asInt(dto.sequence),
      isWon: OdooFieldParser.asBool(dto.isWon),
    );
  }

  List<StageEntity> toEntityList(List<StageDto> dtos) =>
      dtos.map(toEntity).toList();
}
