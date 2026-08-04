import 'package:freezed_annotation/freezed_annotation.dart';

part 'chatter_message_dto.freezed.dart';
part 'chatter_message_dto.g.dart';

@freezed
abstract class ChatterMessageDto with _$ChatterMessageDto {
  const factory ChatterMessageDto({
    required int id,
    @JsonKey(name: 'author_id') dynamic authorId,
    dynamic body,
    dynamic date,
    @JsonKey(name: 'message_type') dynamic messageType,
    @JsonKey(name: 'subtype_id') dynamic subtypeId,
  }) = _ChatterMessageDto;

  factory ChatterMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatterMessageDtoFromJson(json);
}
