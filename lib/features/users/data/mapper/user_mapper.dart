import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/users/data/dto/user_dto.dart';
import 'package:odoocrm/features/users/domain/entities/user_entity.dart';

class UserMapper {
  const UserMapper();

  UserEntity toEntity(UserDto dto) {
    return UserEntity(
      id: dto.id,
      name: OdooFieldParser.asString(dto.name) ?? 'User',
      login: OdooFieldParser.asString(dto.login),
      email: OdooFieldParser.asString(dto.email),
      imageBase64: OdooFieldParser.asString(dto.image1920),
    );
  }

  List<UserEntity> toEntityList(List<UserDto> dtos) =>
      dtos.map(toEntity).toList();
}
