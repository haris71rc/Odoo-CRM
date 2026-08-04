// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  login: json['login'] as String?,
  email: json['email'],
  image1920: json['image_1920'],
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'login': instance.login,
  'email': instance.email,
  'image_1920': instance.image1920,
};
