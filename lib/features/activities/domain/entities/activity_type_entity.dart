import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_type_entity.freezed.dart';

@freezed
abstract class ActivityTypeEntity with _$ActivityTypeEntity {
  const factory ActivityTypeEntity({
    required int id,
    required String name,
    String? icon,
    int? delayCount,
    String? delayUnit,
  }) = _ActivityTypeEntity;
}
