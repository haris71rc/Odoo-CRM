import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_entity.freezed.dart';

@freezed
abstract class ActivityEntity with _$ActivityEntity {
  const factory ActivityEntity({
    required int id,
    required String summary,
    String? note,
    DateTime? dateDeadline,
    String? activityType,
    String? state,
    String? userName,
  }) = _ActivityEntity;
}
