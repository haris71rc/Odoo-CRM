// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeadDto _$LeadDtoFromJson(Map<String, dynamic> json) => _LeadDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  phone: json['phone'],
  partnerName: json['partner_name'],
  stageId: json['stage_id'],
  userId: json['user_id'],
  priority: json['priority'],
  createDate: json['create_date'],
  writeDate: json['write_date'],
  description: json['description'],
);

Map<String, dynamic> _$LeadDtoToJson(_LeadDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'partner_name': instance.partnerName,
  'stage_id': instance.stageId,
  'user_id': instance.userId,
  'priority': instance.priority,
  'create_date': instance.createDate,
  'write_date': instance.writeDate,
  'description': instance.description,
};
