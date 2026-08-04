import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_type_dto.freezed.dart';
part 'activity_type_dto.g.dart';

@freezed
abstract class ActivityTypeDto with _$ActivityTypeDto {
  const factory ActivityTypeDto({
    required int id,
    String? name,
    dynamic icon,
    @JsonKey(name: 'delay_count') dynamic delayCount,
    @JsonKey(name: 'delay_unit') dynamic delayUnit,
  }) = _ActivityTypeDto;

  factory ActivityTypeDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityTypeDtoFromJson(json);
}
