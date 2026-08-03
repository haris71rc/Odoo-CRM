// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stage_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StageDto {

 int get id; String? get name; dynamic get sequence;@JsonKey(name: 'is_won') dynamic get isWon;
/// Create a copy of StageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StageDtoCopyWith<StageDto> get copyWith => _$StageDtoCopyWithImpl<StageDto>(this as StageDto, _$identity);

  /// Serializes this StageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.sequence, sequence)&&const DeepCollectionEquality().equals(other.isWon, isWon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(sequence),const DeepCollectionEquality().hash(isWon));

@override
String toString() {
  return 'StageDto(id: $id, name: $name, sequence: $sequence, isWon: $isWon)';
}


}

/// @nodoc
abstract mixin class $StageDtoCopyWith<$Res>  {
  factory $StageDtoCopyWith(StageDto value, $Res Function(StageDto) _then) = _$StageDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? name, dynamic sequence,@JsonKey(name: 'is_won') dynamic isWon
});




}
/// @nodoc
class _$StageDtoCopyWithImpl<$Res>
    implements $StageDtoCopyWith<$Res> {
  _$StageDtoCopyWithImpl(this._self, this._then);

  final StageDto _self;
  final $Res Function(StageDto) _then;

/// Create a copy of StageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? sequence = freezed,Object? isWon = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as dynamic,isWon: freezed == isWon ? _self.isWon : isWon // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [StageDto].
extension StageDtoPatterns on StageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StageDto value)  $default,){
final _that = this;
switch (_that) {
case _StageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StageDto value)?  $default,){
final _that = this;
switch (_that) {
case _StageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  dynamic sequence, @JsonKey(name: 'is_won')  dynamic isWon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StageDto() when $default != null:
return $default(_that.id,_that.name,_that.sequence,_that.isWon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  dynamic sequence, @JsonKey(name: 'is_won')  dynamic isWon)  $default,) {final _that = this;
switch (_that) {
case _StageDto():
return $default(_that.id,_that.name,_that.sequence,_that.isWon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  dynamic sequence, @JsonKey(name: 'is_won')  dynamic isWon)?  $default,) {final _that = this;
switch (_that) {
case _StageDto() when $default != null:
return $default(_that.id,_that.name,_that.sequence,_that.isWon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StageDto implements StageDto {
  const _StageDto({required this.id, this.name, this.sequence, @JsonKey(name: 'is_won') this.isWon});
  factory _StageDto.fromJson(Map<String, dynamic> json) => _$StageDtoFromJson(json);

@override final  int id;
@override final  String? name;
@override final  dynamic sequence;
@override@JsonKey(name: 'is_won') final  dynamic isWon;

/// Create a copy of StageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StageDtoCopyWith<_StageDto> get copyWith => __$StageDtoCopyWithImpl<_StageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.sequence, sequence)&&const DeepCollectionEquality().equals(other.isWon, isWon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(sequence),const DeepCollectionEquality().hash(isWon));

@override
String toString() {
  return 'StageDto(id: $id, name: $name, sequence: $sequence, isWon: $isWon)';
}


}

/// @nodoc
abstract mixin class _$StageDtoCopyWith<$Res> implements $StageDtoCopyWith<$Res> {
  factory _$StageDtoCopyWith(_StageDto value, $Res Function(_StageDto) _then) = __$StageDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, dynamic sequence,@JsonKey(name: 'is_won') dynamic isWon
});




}
/// @nodoc
class __$StageDtoCopyWithImpl<$Res>
    implements _$StageDtoCopyWith<$Res> {
  __$StageDtoCopyWithImpl(this._self, this._then);

  final _StageDto _self;
  final $Res Function(_StageDto) _then;

/// Create a copy of StageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? sequence = freezed,Object? isWon = freezed,}) {
  return _then(_StageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as dynamic,isWon: freezed == isWon ? _self.isWon : isWon // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
