// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_type_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityTypeDto {

 int get id; String? get name; dynamic get icon;@JsonKey(name: 'delay_count') dynamic get delayCount;@JsonKey(name: 'delay_unit') dynamic get delayUnit;
/// Create a copy of ActivityTypeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityTypeDtoCopyWith<ActivityTypeDto> get copyWith => _$ActivityTypeDtoCopyWithImpl<ActivityTypeDto>(this as ActivityTypeDto, _$identity);

  /// Serializes this ActivityTypeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityTypeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.icon, icon)&&const DeepCollectionEquality().equals(other.delayCount, delayCount)&&const DeepCollectionEquality().equals(other.delayUnit, delayUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(icon),const DeepCollectionEquality().hash(delayCount),const DeepCollectionEquality().hash(delayUnit));

@override
String toString() {
  return 'ActivityTypeDto(id: $id, name: $name, icon: $icon, delayCount: $delayCount, delayUnit: $delayUnit)';
}


}

/// @nodoc
abstract mixin class $ActivityTypeDtoCopyWith<$Res>  {
  factory $ActivityTypeDtoCopyWith(ActivityTypeDto value, $Res Function(ActivityTypeDto) _then) = _$ActivityTypeDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? name, dynamic icon,@JsonKey(name: 'delay_count') dynamic delayCount,@JsonKey(name: 'delay_unit') dynamic delayUnit
});




}
/// @nodoc
class _$ActivityTypeDtoCopyWithImpl<$Res>
    implements $ActivityTypeDtoCopyWith<$Res> {
  _$ActivityTypeDtoCopyWithImpl(this._self, this._then);

  final ActivityTypeDto _self;
  final $Res Function(ActivityTypeDto) _then;

/// Create a copy of ActivityTypeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? icon = freezed,Object? delayCount = freezed,Object? delayUnit = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as dynamic,delayCount: freezed == delayCount ? _self.delayCount : delayCount // ignore: cast_nullable_to_non_nullable
as dynamic,delayUnit: freezed == delayUnit ? _self.delayUnit : delayUnit // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityTypeDto].
extension ActivityTypeDtoPatterns on ActivityTypeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityTypeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityTypeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityTypeDto value)  $default,){
final _that = this;
switch (_that) {
case _ActivityTypeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityTypeDto value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityTypeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  dynamic icon, @JsonKey(name: 'delay_count')  dynamic delayCount, @JsonKey(name: 'delay_unit')  dynamic delayUnit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityTypeDto() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.delayCount,_that.delayUnit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  dynamic icon, @JsonKey(name: 'delay_count')  dynamic delayCount, @JsonKey(name: 'delay_unit')  dynamic delayUnit)  $default,) {final _that = this;
switch (_that) {
case _ActivityTypeDto():
return $default(_that.id,_that.name,_that.icon,_that.delayCount,_that.delayUnit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  dynamic icon, @JsonKey(name: 'delay_count')  dynamic delayCount, @JsonKey(name: 'delay_unit')  dynamic delayUnit)?  $default,) {final _that = this;
switch (_that) {
case _ActivityTypeDto() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.delayCount,_that.delayUnit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityTypeDto implements ActivityTypeDto {
  const _ActivityTypeDto({required this.id, this.name, this.icon, @JsonKey(name: 'delay_count') this.delayCount, @JsonKey(name: 'delay_unit') this.delayUnit});
  factory _ActivityTypeDto.fromJson(Map<String, dynamic> json) => _$ActivityTypeDtoFromJson(json);

@override final  int id;
@override final  String? name;
@override final  dynamic icon;
@override@JsonKey(name: 'delay_count') final  dynamic delayCount;
@override@JsonKey(name: 'delay_unit') final  dynamic delayUnit;

/// Create a copy of ActivityTypeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityTypeDtoCopyWith<_ActivityTypeDto> get copyWith => __$ActivityTypeDtoCopyWithImpl<_ActivityTypeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityTypeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityTypeDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.icon, icon)&&const DeepCollectionEquality().equals(other.delayCount, delayCount)&&const DeepCollectionEquality().equals(other.delayUnit, delayUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(icon),const DeepCollectionEquality().hash(delayCount),const DeepCollectionEquality().hash(delayUnit));

@override
String toString() {
  return 'ActivityTypeDto(id: $id, name: $name, icon: $icon, delayCount: $delayCount, delayUnit: $delayUnit)';
}


}

/// @nodoc
abstract mixin class _$ActivityTypeDtoCopyWith<$Res> implements $ActivityTypeDtoCopyWith<$Res> {
  factory _$ActivityTypeDtoCopyWith(_ActivityTypeDto value, $Res Function(_ActivityTypeDto) _then) = __$ActivityTypeDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, dynamic icon,@JsonKey(name: 'delay_count') dynamic delayCount,@JsonKey(name: 'delay_unit') dynamic delayUnit
});




}
/// @nodoc
class __$ActivityTypeDtoCopyWithImpl<$Res>
    implements _$ActivityTypeDtoCopyWith<$Res> {
  __$ActivityTypeDtoCopyWithImpl(this._self, this._then);

  final _ActivityTypeDto _self;
  final $Res Function(_ActivityTypeDto) _then;

/// Create a copy of ActivityTypeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? icon = freezed,Object? delayCount = freezed,Object? delayUnit = freezed,}) {
  return _then(_ActivityTypeDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as dynamic,delayCount: freezed == delayCount ? _self.delayCount : delayCount // ignore: cast_nullable_to_non_nullable
as dynamic,delayUnit: freezed == delayUnit ? _self.delayUnit : delayUnit // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
