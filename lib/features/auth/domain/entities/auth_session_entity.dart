import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session_entity.freezed.dart';

@freezed
abstract class AuthSessionEntity with _$AuthSessionEntity {
  const factory AuthSessionEntity({
    required int uid,
    required String sessionId,
    required String login,
    String? name,
    String? partnerDisplayName,
  }) = _AuthSessionEntity;
}
