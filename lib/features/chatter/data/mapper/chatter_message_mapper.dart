import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/chatter/data/dto/chatter_message_dto.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/named_ref_entity.dart';

class ChatterMessageMapper {
  const ChatterMessageMapper();

  ChatterMessageEntity toEntity(ChatterMessageDto dto) {
    NamedRefEntity? mapRef(dynamic value) {
      final ref = OdooFieldParser.asMany2One(value);
      if (ref == null) return null;
      return NamedRefEntity(id: ref.id, name: ref.name);
    }

    return ChatterMessageEntity(
      id: dto.id,
      author: mapRef(dto.authorId),
      body: OdooFieldParser.asString(dto.body),
      date: OdooFieldParser.asDateTime(dto.date),
      messageType: OdooFieldParser.asString(dto.messageType),
      subtype: mapRef(dto.subtypeId),
    );
  }

  List<ChatterMessageEntity> toEntityList(List<ChatterMessageDto> dtos) =>
      dtos.map(toEntity).toList();
}
