// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StageDto _$StageDtoFromJson(Map<String, dynamic> json) => _StageDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  sequence: json['sequence'],
  isWon: json['is_won'],
);

Map<String, dynamic> _$StageDtoToJson(_StageDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sequence': instance.sequence,
  'is_won': instance.isWon,
};
