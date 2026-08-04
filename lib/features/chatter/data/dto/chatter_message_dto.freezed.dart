// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chatter_message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatterMessageDto {

 int get id;@JsonKey(name: 'author_id') dynamic get authorId; dynamic get body; dynamic get date;@JsonKey(name: 'message_type') dynamic get messageType;@JsonKey(name: 'subtype_id') dynamic get subtypeId;
/// Create a copy of ChatterMessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatterMessageDtoCopyWith<ChatterMessageDto> get copyWith => _$ChatterMessageDtoCopyWithImpl<ChatterMessageDto>(this as ChatterMessageDto, _$identity);

  /// Serializes this ChatterMessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatterMessageDto&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.authorId, authorId)&&const DeepCollectionEquality().equals(other.body, body)&&const DeepCollectionEquality().equals(other.date, date)&&const DeepCollectionEquality().equals(other.messageType, messageType)&&const DeepCollectionEquality().equals(other.subtypeId, subtypeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(authorId),const DeepCollectionEquality().hash(body),const DeepCollectionEquality().hash(date),const DeepCollectionEquality().hash(messageType),const DeepCollectionEquality().hash(subtypeId));

@override
String toString() {
  return 'ChatterMessageDto(id: $id, authorId: $authorId, body: $body, date: $date, messageType: $messageType, subtypeId: $subtypeId)';
}


}

/// @nodoc
abstract mixin class $ChatterMessageDtoCopyWith<$Res>  {
  factory $ChatterMessageDtoCopyWith(ChatterMessageDto value, $Res Function(ChatterMessageDto) _then) = _$ChatterMessageDtoCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'author_id') dynamic authorId, dynamic body, dynamic date,@JsonKey(name: 'message_type') dynamic messageType,@JsonKey(name: 'subtype_id') dynamic subtypeId
});




}
/// @nodoc
class _$ChatterMessageDtoCopyWithImpl<$Res>
    implements $ChatterMessageDtoCopyWith<$Res> {
  _$ChatterMessageDtoCopyWithImpl(this._self, this._then);

  final ChatterMessageDto _self;
  final $Res Function(ChatterMessageDto) _then;

/// Create a copy of ChatterMessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = freezed,Object? body = freezed,Object? date = freezed,Object? messageType = freezed,Object? subtypeId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as dynamic,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as dynamic,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as dynamic,messageType: freezed == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as dynamic,subtypeId: freezed == subtypeId ? _self.subtypeId : subtypeId // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatterMessageDto].
extension ChatterMessageDtoPatterns on ChatterMessageDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatterMessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatterMessageDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatterMessageDto value)  $default,){
final _that = this;
switch (_that) {
case _ChatterMessageDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatterMessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ChatterMessageDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'author_id')  dynamic authorId,  dynamic body,  dynamic date, @JsonKey(name: 'message_type')  dynamic messageType, @JsonKey(name: 'subtype_id')  dynamic subtypeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatterMessageDto() when $default != null:
return $default(_that.id,_that.authorId,_that.body,_that.date,_that.messageType,_that.subtypeId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'author_id')  dynamic authorId,  dynamic body,  dynamic date, @JsonKey(name: 'message_type')  dynamic messageType, @JsonKey(name: 'subtype_id')  dynamic subtypeId)  $default,) {final _that = this;
switch (_that) {
case _ChatterMessageDto():
return $default(_that.id,_that.authorId,_that.body,_that.date,_that.messageType,_that.subtypeId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'author_id')  dynamic authorId,  dynamic body,  dynamic date, @JsonKey(name: 'message_type')  dynamic messageType, @JsonKey(name: 'subtype_id')  dynamic subtypeId)?  $default,) {final _that = this;
switch (_that) {
case _ChatterMessageDto() when $default != null:
return $default(_that.id,_that.authorId,_that.body,_that.date,_that.messageType,_that.subtypeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatterMessageDto implements ChatterMessageDto {
  const _ChatterMessageDto({required this.id, @JsonKey(name: 'author_id') this.authorId, this.body, this.date, @JsonKey(name: 'message_type') this.messageType, @JsonKey(name: 'subtype_id') this.subtypeId});
  factory _ChatterMessageDto.fromJson(Map<String, dynamic> json) => _$ChatterMessageDtoFromJson(json);

@override final  int id;
@override@JsonKey(name: 'author_id') final  dynamic authorId;
@override final  dynamic body;
@override final  dynamic date;
@override@JsonKey(name: 'message_type') final  dynamic messageType;
@override@JsonKey(name: 'subtype_id') final  dynamic subtypeId;

/// Create a copy of ChatterMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatterMessageDtoCopyWith<_ChatterMessageDto> get copyWith => __$ChatterMessageDtoCopyWithImpl<_ChatterMessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatterMessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatterMessageDto&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.authorId, authorId)&&const DeepCollectionEquality().equals(other.body, body)&&const DeepCollectionEquality().equals(other.date, date)&&const DeepCollectionEquality().equals(other.messageType, messageType)&&const DeepCollectionEquality().equals(other.subtypeId, subtypeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(authorId),const DeepCollectionEquality().hash(body),const DeepCollectionEquality().hash(date),const DeepCollectionEquality().hash(messageType),const DeepCollectionEquality().hash(subtypeId));

@override
String toString() {
  return 'ChatterMessageDto(id: $id, authorId: $authorId, body: $body, date: $date, messageType: $messageType, subtypeId: $subtypeId)';
}


}

/// @nodoc
abstract mixin class _$ChatterMessageDtoCopyWith<$Res> implements $ChatterMessageDtoCopyWith<$Res> {
  factory _$ChatterMessageDtoCopyWith(_ChatterMessageDto value, $Res Function(_ChatterMessageDto) _then) = __$ChatterMessageDtoCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'author_id') dynamic authorId, dynamic body, dynamic date,@JsonKey(name: 'message_type') dynamic messageType,@JsonKey(name: 'subtype_id') dynamic subtypeId
});




}
/// @nodoc
class __$ChatterMessageDtoCopyWithImpl<$Res>
    implements _$ChatterMessageDtoCopyWith<$Res> {
  __$ChatterMessageDtoCopyWithImpl(this._self, this._then);

  final _ChatterMessageDto _self;
  final $Res Function(_ChatterMessageDto) _then;

/// Create a copy of ChatterMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = freezed,Object? body = freezed,Object? date = freezed,Object? messageType = freezed,Object? subtypeId = freezed,}) {
  return _then(_ChatterMessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as dynamic,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as dynamic,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as dynamic,messageType: freezed == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as dynamic,subtypeId: freezed == subtypeId ? _self.subtypeId : subtypeId // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
