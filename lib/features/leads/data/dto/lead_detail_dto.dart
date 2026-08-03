import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_detail_dto.freezed.dart';
part 'lead_detail_dto.g.dart';

@freezed
abstract class LeadDetailDto with _$LeadDetailDto {
  const factory LeadDetailDto({
    required int id,
    String? name,
    @JsonKey(name: 'partner_name') dynamic partnerName,
    dynamic phone,
    dynamic mobile,
    @JsonKey(name: 'email_from') dynamic emailFrom,
    dynamic street,
    dynamic city,
    @JsonKey(name: 'state_id') dynamic stateId,
    @JsonKey(name: 'country_id') dynamic countryId,
    dynamic zip,
    dynamic description,
    @JsonKey(name: 'stage_id') dynamic stageId,
    @JsonKey(name: 'user_id') dynamic userId,
    @JsonKey(name: 'team_id') dynamic teamId,
    dynamic priority,
    @JsonKey(name: 'create_date') dynamic createDate,
    @JsonKey(name: 'write_date') dynamic writeDate,
    @JsonKey(name: 'expected_revenue') dynamic expectedRevenue,
    dynamic probability,
    @JsonKey(name: 'tag_ids') dynamic tagIds,
  }) = _LeadDetailDto;

  factory LeadDetailDto.fromJson(Map<String, dynamic> json) =>
      _$LeadDetailDtoFromJson(json);
}
