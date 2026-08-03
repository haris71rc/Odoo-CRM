import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session_dto.freezed.dart';
part 'auth_session_dto.g.dart';

@freezed
abstract class AuthSessionDto with _$AuthSessionDto {
  const factory AuthSessionDto({
    required int uid,
    String? name,
    String? username,
    @JsonKey(name: 'partner_display_name') String? partnerDisplayName,
    @JsonKey(name: 'session_id') String? sessionId,
  }) = _AuthSessionDto;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionDtoFromJson(json);
}
