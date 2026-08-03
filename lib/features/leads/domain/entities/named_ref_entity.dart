import 'package:freezed_annotation/freezed_annotation.dart';

part 'named_ref_entity.freezed.dart';

@freezed
abstract class NamedRefEntity with _$NamedRefEntity {
  const factory NamedRefEntity({
    required int id,
    required String name,
  }) = _NamedRefEntity;
}
