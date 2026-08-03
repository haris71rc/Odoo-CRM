import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/auth/data/dto/auth_session_dto.dart';
import 'package:odoocrm/features/auth/domain/entities/auth_session_entity.dart';

class AuthSessionMapper {
  const AuthSessionMapper();

  AuthSessionEntity toEntity(AuthSessionDto dto, {required String sessionId}) {
    return AuthSessionEntity(
      uid: dto.uid,
      sessionId: sessionId,
      login: dto.username ?? '',
      name: OdooFieldParser.asString(dto.name),
      partnerDisplayName: OdooFieldParser.asString(dto.partnerDisplayName),
    );
  }
}
