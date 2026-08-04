// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tracking_value_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrackingValueEntity {

 String get changedField; String? get oldValue; String? get newValue; String? get fieldType;
/// Create a copy of TrackingValueEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingValueEntityCopyWith<TrackingValueEntity> get copyWith => _$TrackingValueEntityCopyWithImpl<TrackingValueEntity>(this as TrackingValueEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingValueEntity&&(identical(other.changedField, changedField) || other.changedField == changedField)&&(identical(other.oldValue, oldValue) || other.oldValue == oldValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.fieldType, fieldType) || other.fieldType == fieldType));
}


@override
int get hashCode => Object.hash(runtimeType,changedField,oldValue,newValue,fieldType);

@override
String toString() {
  return 'TrackingValueEntity(changedField: $changedField, oldValue: $oldValue, newValue: $newValue, fieldType: $fieldType)';
}


}

/// @nodoc
abstract mixin class $TrackingValueEntityCopyWith<$Res>  {
  factory $TrackingValueEntityCopyWith(TrackingValueEntity value, $Res Function(TrackingValueEntity) _then) = _$TrackingValueEntityCopyWithImpl;
@useResult
$Res call({
 String changedField, String? oldValue, String? newValue, String? fieldType
});




}
/// @nodoc
class _$TrackingValueEntityCopyWithImpl<$Res>
    implements $TrackingValueEntityCopyWith<$Res> {
  _$TrackingValueEntityCopyWithImpl(this._self, this._then);

  final TrackingValueEntity _self;
  final $Res Function(TrackingValueEntity) _then;

/// Create a copy of TrackingValueEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? changedField = null,Object? oldValue = freezed,Object? newValue = freezed,Object? fieldType = freezed,}) {
  return _then(_self.copyWith(
changedField: null == changedField ? _self.changedField : changedField // ignore: cast_nullable_to_non_nullable
as String,oldValue: freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as String?,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String?,fieldType: freezed == fieldType ? _self.fieldType : fieldType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingValueEntity].
extension TrackingValueEntityPatterns on TrackingValueEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingValueEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingValueEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingValueEntity value)  $default,){
final _that = this;
switch (_that) {
case _TrackingValueEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingValueEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingValueEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String changedField,  String? oldValue,  String? newValue,  String? fieldType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingValueEntity() when $default != null:
return $default(_that.changedField,_that.oldValue,_that.newValue,_that.fieldType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String changedField,  String? oldValue,  String? newValue,  String? fieldType)  $default,) {final _that = this;
switch (_that) {
case _TrackingValueEntity():
return $default(_that.changedField,_that.oldValue,_that.newValue,_that.fieldType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String changedField,  String? oldValue,  String? newValue,  String? fieldType)?  $default,) {final _that = this;
switch (_that) {
case _TrackingValueEntity() when $default != null:
return $default(_that.changedField,_that.oldValue,_that.newValue,_that.fieldType);case _:
  return null;

}
}

}

/// @nodoc


class _TrackingValueEntity implements TrackingValueEntity {
  const _TrackingValueEntity({required this.changedField, this.oldValue, this.newValue, this.fieldType});
  

@override final  String changedField;
@override final  String? oldValue;
@override final  String? newValue;
@override final  String? fieldType;

/// Create a copy of TrackingValueEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingValueEntityCopyWith<_TrackingValueEntity> get copyWith => __$TrackingValueEntityCopyWithImpl<_TrackingValueEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingValueEntity&&(identical(other.changedField, changedField) || other.changedField == changedField)&&(identical(other.oldValue, oldValue) || other.oldValue == oldValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.fieldType, fieldType) || other.fieldType == fieldType));
}


@override
int get hashCode => Object.hash(runtimeType,changedField,oldValue,newValue,fieldType);

@override
String toString() {
  return 'TrackingValueEntity(changedField: $changedField, oldValue: $oldValue, newValue: $newValue, fieldType: $fieldType)';
}


}

/// @nodoc
abstract mixin class _$TrackingValueEntityCopyWith<$Res> implements $TrackingValueEntityCopyWith<$Res> {
  factory _$TrackingValueEntityCopyWith(_TrackingValueEntity value, $Res Function(_TrackingValueEntity) _then) = __$TrackingValueEntityCopyWithImpl;
@override @useResult
$Res call({
 String changedField, String? oldValue, String? newValue, String? fieldType
});




}
/// @nodoc
class __$TrackingValueEntityCopyWithImpl<$Res>
    implements _$TrackingValueEntityCopyWith<$Res> {
  __$TrackingValueEntityCopyWithImpl(this._self, this._then);

  final _TrackingValueEntity _self;
  final $Res Function(_TrackingValueEntity) _then;

/// Create a copy of TrackingValueEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? changedField = null,Object? oldValue = freezed,Object? newValue = freezed,Object? fieldType = freezed,}) {
  return _then(_TrackingValueEntity(
changedField: null == changedField ? _self.changedField : changedField // ignore: cast_nullable_to_non_nullable
as String,oldValue: freezed == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as String?,newValue: freezed == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String?,fieldType: freezed == fieldType ? _self.fieldType : fieldType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
