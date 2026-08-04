// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_type_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityTypeDto _$ActivityTypeDtoFromJson(Map<String, dynamic> json) =>
    _ActivityTypeDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      icon: json['icon'],
      delayCount: json['delay_count'],
      delayUnit: json['delay_unit'],
    );

Map<String, dynamic> _$ActivityTypeDtoToJson(_ActivityTypeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'delay_count': instance.delayCount,
      'delay_unit': instance.delayUnit,
    };
