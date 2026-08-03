import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_dto.freezed.dart';
part 'lead_dto.g.dart';

@freezed
abstract class LeadDto with _$LeadDto {
  const factory LeadDto({
    required int id,
    String? name,
    dynamic phone,
    @JsonKey(name: 'partner_name') dynamic partnerName,
    @JsonKey(name: 'stage_id') dynamic stageId,
    @JsonKey(name: 'user_id') dynamic userId,
    dynamic priority,
    @JsonKey(name: 'create_date') dynamic createDate,
    @JsonKey(name: 'write_date') dynamic writeDate,
    dynamic description,
  }) = _LeadDto;

  factory LeadDto.fromJson(Map<String, dynamic> json) =>
      _$LeadDtoFromJson(json);
}
