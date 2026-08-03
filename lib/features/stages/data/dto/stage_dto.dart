import 'package:freezed_annotation/freezed_annotation.dart';

part 'stage_dto.freezed.dart';
part 'stage_dto.g.dart';

@freezed
abstract class StageDto with _$StageDto {
  const factory StageDto({
    required int id,
    String? name,
    dynamic sequence,
    @JsonKey(name: 'is_won') dynamic isWon,
  }) = _StageDto;

  factory StageDto.fromJson(Map<String, dynamic> json) =>
      _$StageDtoFromJson(json);
}
