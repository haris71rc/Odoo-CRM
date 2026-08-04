// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_type_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivityTypeEntity {

 int get id; String get name; String? get icon; int? get delayCount; String? get delayUnit;
/// Create a copy of ActivityTypeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityTypeEntityCopyWith<ActivityTypeEntity> get copyWith => _$ActivityTypeEntityCopyWithImpl<ActivityTypeEntity>(this as ActivityTypeEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityTypeEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.delayCount, delayCount) || other.delayCount == delayCount)&&(identical(other.delayUnit, delayUnit) || other.delayUnit == delayUnit));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,icon,delayCount,delayUnit);

@override
String toString() {
  return 'ActivityTypeEntity(id: $id, name: $name, icon: $icon, delayCount: $delayCount, delayUnit: $delayUnit)';
}


}

/// @nodoc
abstract mixin class $ActivityTypeEntityCopyWith<$Res>  {
  factory $ActivityTypeEntityCopyWith(ActivityTypeEntity value, $Res Function(ActivityTypeEntity) _then) = _$ActivityTypeEntityCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? icon, int? delayCount, String? delayUnit
});




}
/// @nodoc
class _$ActivityTypeEntityCopyWithImpl<$Res>
    implements $ActivityTypeEntityCopyWith<$Res> {
  _$ActivityTypeEntityCopyWithImpl(this._self, this._then);

  final ActivityTypeEntity _self;
  final $Res Function(ActivityTypeEntity) _then;

/// Create a copy of ActivityTypeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? delayCount = freezed,Object? delayUnit = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,delayCount: freezed == delayCount ? _self.delayCount : delayCount // ignore: cast_nullable_to_non_nullable
as int?,delayUnit: freezed == delayUnit ? _self.delayUnit : delayUnit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityTypeEntity].
extension ActivityTypeEntityPatterns on ActivityTypeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityTypeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityTypeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityTypeEntity value)  $default,){
final _that = this;
switch (_that) {
case _ActivityTypeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityTypeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityTypeEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? icon,  int? delayCount,  String? delayUnit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityTypeEntity() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? icon,  int? delayCount,  String? delayUnit)  $default,) {final _that = this;
switch (_that) {
case _ActivityTypeEntity():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? icon,  int? delayCount,  String? delayUnit)?  $default,) {final _that = this;
switch (_that) {
case _ActivityTypeEntity() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.delayCount,_that.delayUnit);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityTypeEntity implements ActivityTypeEntity {
  const _ActivityTypeEntity({required this.id, required this.name, this.icon, this.delayCount, this.delayUnit});
  

@override final  int id;
@override final  String name;
@override final  String? icon;
@override final  int? delayCount;
@override final  String? delayUnit;

/// Create a copy of ActivityTypeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityTypeEntityCopyWith<_ActivityTypeEntity> get copyWith => __$ActivityTypeEntityCopyWithImpl<_ActivityTypeEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityTypeEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.delayCount, delayCount) || other.delayCount == delayCount)&&(identical(other.delayUnit, delayUnit) || other.delayUnit == delayUnit));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,icon,delayCount,delayUnit);

@override
String toString() {
  return 'ActivityTypeEntity(id: $id, name: $name, icon: $icon, delayCount: $delayCount, delayUnit: $delayUnit)';
}


}

/// @nodoc
abstract mixin class _$ActivityTypeEntityCopyWith<$Res> implements $ActivityTypeEntityCopyWith<$Res> {
  factory _$ActivityTypeEntityCopyWith(_ActivityTypeEntity value, $Res Function(_ActivityTypeEntity) _then) = __$ActivityTypeEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? icon, int? delayCount, String? delayUnit
});




}
/// @nodoc
class __$ActivityTypeEntityCopyWithImpl<$Res>
    implements _$ActivityTypeEntityCopyWith<$Res> {
  __$ActivityTypeEntityCopyWithImpl(this._self, this._then);

  final _ActivityTypeEntity _self;
  final $Res Function(_ActivityTypeEntity) _then;

/// Create a copy of ActivityTypeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = freezed,Object? delayCount = freezed,Object? delayUnit = freezed,}) {
  return _then(_ActivityTypeEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,delayCount: freezed == delayCount ? _self.delayCount : delayCount // ignore: cast_nullable_to_non_nullable
as int?,delayUnit: freezed == delayUnit ? _self.delayUnit : delayUnit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
