import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracking_value_entity.freezed.dart';

@freezed
abstract class TrackingValueEntity with _$TrackingValueEntity {
  const factory TrackingValueEntity({
    required String changedField,
    String? oldValue,
    String? newValue,
    String? fieldType,
  }) = _TrackingValueEntity;
}
