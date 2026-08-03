// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeadDetailDto _$LeadDetailDtoFromJson(Map<String, dynamic> json) =>
    _LeadDetailDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      partnerName: json['partner_name'],
      phone: json['phone'],
      mobile: json['mobile'],
      emailFrom: json['email_from'],
      street: json['street'],
      city: json['city'],
      stateId: json['state_id'],
      countryId: json['country_id'],
      zip: json['zip'],
      description: json['description'],
      stageId: json['stage_id'],
      userId: json['user_id'],
      teamId: json['team_id'],
      priority: json['priority'],
      createDate: json['create_date'],
      writeDate: json['write_date'],
      expectedRevenue: json['expected_revenue'],
      probability: json['probability'],
      tagIds: json['tag_ids'],
    );

Map<String, dynamic> _$LeadDetailDtoToJson(_LeadDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'partner_name': instance.partnerName,
      'phone': instance.phone,
      'mobile': instance.mobile,
      'email_from': instance.emailFrom,
      'street': instance.street,
      'city': instance.city,
      'state_id': instance.stateId,
      'country_id': instance.countryId,
      'zip': instance.zip,
      'description': instance.description,
      'stage_id': instance.stageId,
      'user_id': instance.userId,
      'team_id': instance.teamId,
      'priority': instance.priority,
      'create_date': instance.createDate,
      'write_date': instance.writeDate,
      'expected_revenue': instance.expectedRevenue,
      'probability': instance.probability,
      'tag_ids': instance.tagIds,
    };
