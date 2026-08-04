// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatter_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatterMessageDto _$ChatterMessageDtoFromJson(Map<String, dynamic> json) =>
    _ChatterMessageDto(
      id: (json['id'] as num).toInt(),
      authorId: json['author_id'],
      body: json['body'],
      date: json['date'],
      messageType: json['message_type'],
      subtypeId: json['subtype_id'],
    );

Map<String, dynamic> _$ChatterMessageDtoToJson(_ChatterMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_id': instance.authorId,
      'body': instance.body,
      'date': instance.date,
      'message_type': instance.messageType,
      'subtype_id': instance.subtypeId,
    };
