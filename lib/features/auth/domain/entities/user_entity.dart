import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required int id,
    required String name,
    String? login,
    String? email,
    String? partnerName,
    String? imageUrl,
  }) = _UserEntity;
}
