// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityDto _$ActivityDtoFromJson(Map<String, dynamic> json) => _ActivityDto(
  id: (json['id'] as num).toInt(),
  summary: json['summary'],
  note: json['note'],
  dateDeadline: json['date_deadline'],
  activityTypeId: json['activity_type_id'],
  state: json['state'],
  userId: json['user_id'],
);

Map<String, dynamic> _$ActivityDtoToJson(_ActivityDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary': instance.summary,
      'note': instance.note,
      'date_deadline': instance.dateDeadline,
      'activity_type_id': instance.activityTypeId,
      'state': instance.state,
      'user_id': instance.userId,
    };
