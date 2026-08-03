// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stage_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StageEntity {

 int get id; String get name; int? get sequence; bool? get isWon;
/// Create a copy of StageEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StageEntityCopyWith<StageEntity> get copyWith => _$StageEntityCopyWithImpl<StageEntity>(this as StageEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StageEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.isWon, isWon) || other.isWon == isWon));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,sequence,isWon);

@override
String toString() {
  return 'StageEntity(id: $id, name: $name, sequence: $sequence, isWon: $isWon)';
}


}

/// @nodoc
abstract mixin class $StageEntityCopyWith<$Res>  {
  factory $StageEntityCopyWith(StageEntity value, $Res Function(StageEntity) _then) = _$StageEntityCopyWithImpl;
@useResult
$Res call({
 int id, String name, int? sequence, bool? isWon
});




}
/// @nodoc
class _$StageEntityCopyWithImpl<$Res>
    implements $StageEntityCopyWith<$Res> {
  _$StageEntityCopyWithImpl(this._self, this._then);

  final StageEntity _self;
  final $Res Function(StageEntity) _then;

/// Create a copy of StageEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sequence = freezed,Object? isWon = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int?,isWon: freezed == isWon ? _self.isWon : isWon // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [StageEntity].
extension StageEntityPatterns on StageEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StageEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StageEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StageEntity value)  $default,){
final _that = this;
switch (_that) {
case _StageEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StageEntity value)?  $default,){
final _that = this;
switch (_that) {
case _StageEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int? sequence,  bool? isWon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StageEntity() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int? sequence,  bool? isWon)  $default,) {final _that = this;
switch (_that) {
case _StageEntity():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int? sequence,  bool? isWon)?  $default,) {final _that = this;
switch (_that) {
case _StageEntity() when $default != null:
return $default(_that.id,_that.name,_that.sequence,_that.isWon);case _:
  return null;

}
}

}

/// @nodoc


class _StageEntity implements StageEntity {
  const _StageEntity({required this.id, required this.name, this.sequence, this.isWon});
  

@override final  int id;
@override final  String name;
@override final  int? sequence;
@override final  bool? isWon;

/// Create a copy of StageEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StageEntityCopyWith<_StageEntity> get copyWith => __$StageEntityCopyWithImpl<_StageEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StageEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.isWon, isWon) || other.isWon == isWon));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,sequence,isWon);

@override
String toString() {
  return 'StageEntity(id: $id, name: $name, sequence: $sequence, isWon: $isWon)';
}


}

/// @nodoc
abstract mixin class _$StageEntityCopyWith<$Res> implements $StageEntityCopyWith<$Res> {
  factory _$StageEntityCopyWith(_StageEntity value, $Res Function(_StageEntity) _then) = __$StageEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int? sequence, bool? isWon
});




}
/// @nodoc
class __$StageEntityCopyWithImpl<$Res>
    implements _$StageEntityCopyWith<$Res> {
  __$StageEntityCopyWithImpl(this._self, this._then);

  final _StageEntity _self;
  final $Res Function(_StageEntity) _then;

/// Create a copy of StageEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sequence = freezed,Object? isWon = freezed,}) {
  return _then(_StageEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int?,isWon: freezed == isWon ? _self.isWon : isWon // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
