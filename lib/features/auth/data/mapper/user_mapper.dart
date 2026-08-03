import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/auth/data/dto/user_dto.dart';
import 'package:odoocrm/features/auth/domain/entities/user_entity.dart';

class UserMapper {
  const UserMapper();

  UserEntity toEntity(UserDto dto) {
    final partner = OdooFieldParser.asMany2One(dto.partnerId);
    return UserEntity(
      id: dto.id,
      name: OdooFieldParser.asString(dto.name) ?? 'User',
      login: OdooFieldParser.asString(dto.login),
      email: OdooFieldParser.asString(dto.email),
      partnerName: partner?.name,
    );
  }
}
