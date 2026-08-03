// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthSessionDto _$AuthSessionDtoFromJson(Map<String, dynamic> json) =>
    _AuthSessionDto(
      uid: (json['uid'] as num).toInt(),
      name: json['name'] as String?,
      username: json['username'] as String?,
      partnerDisplayName: json['partner_display_name'] as String?,
      sessionId: json['session_id'] as String?,
    );

Map<String, dynamic> _$AuthSessionDtoToJson(_AuthSessionDto instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'username': instance.username,
      'partner_display_name': instance.partnerDisplayName,
      'session_id': instance.sessionId,
    };
