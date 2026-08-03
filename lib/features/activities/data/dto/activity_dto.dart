import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_dto.freezed.dart';
part 'activity_dto.g.dart';

@freezed
abstract class ActivityDto with _$ActivityDto {
  const factory ActivityDto({
    required int id,
    dynamic summary,
    dynamic note,
    @JsonKey(name: 'date_deadline') dynamic dateDeadline,
    @JsonKey(name: 'activity_type_id') dynamic activityTypeId,
    dynamic state,
    @JsonKey(name: 'user_id') dynamic userId,
  }) = _ActivityDto;

  factory ActivityDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityDtoFromJson(json);
}
