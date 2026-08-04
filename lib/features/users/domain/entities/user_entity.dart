import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required int id,
    required String name,
    String? login,
    String? email,
    /// Raw base64 from Odoo `image_1920` (may include data-uri prefix).
    String? imageBase64,
  }) = _UserEntity;
}
