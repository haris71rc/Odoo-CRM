import 'package:freezed_annotation/freezed_annotation.dart';

part 'stage_entity.freezed.dart';

@freezed
abstract class StageEntity with _$StageEntity {
  const factory StageEntity({
    required int id,
    required String name,
    int? sequence,
    bool? isWon,
  }) = _StageEntity;
}
