// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivityEntity {

 int get id; String get summary; String? get note; DateTime? get dateDeadline; String? get activityType; String? get state; String? get userName;
/// Create a copy of ActivityEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityEntityCopyWith<ActivityEntity> get copyWith => _$ActivityEntityCopyWithImpl<ActivityEntity>(this as ActivityEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.note, note) || other.note == note)&&(identical(other.dateDeadline, dateDeadline) || other.dateDeadline == dateDeadline)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.state, state) || other.state == state)&&(identical(other.userName, userName) || other.userName == userName));
}


@override
int get hashCode => Object.hash(runtimeType,id,summary,note,dateDeadline,activityType,state,userName);

@override
String toString() {
  return 'ActivityEntity(id: $id, summary: $summary, note: $note, dateDeadline: $dateDeadline, activityType: $activityType, state: $state, userName: $userName)';
}


}

/// @nodoc
abstract mixin class $ActivityEntityCopyWith<$Res>  {
  factory $ActivityEntityCopyWith(ActivityEntity value, $Res Function(ActivityEntity) _then) = _$ActivityEntityCopyWithImpl;
@useResult
$Res call({
 int id, String summary, String? note, DateTime? dateDeadline, String? activityType, String? state, String? userName
});




}
/// @nodoc
class _$ActivityEntityCopyWithImpl<$Res>
    implements $ActivityEntityCopyWith<$Res> {
  _$ActivityEntityCopyWithImpl(this._self, this._then);

  final ActivityEntity _self;
  final $Res Function(ActivityEntity) _then;

/// Create a copy of ActivityEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? summary = null,Object? note = freezed,Object? dateDeadline = freezed,Object? activityType = freezed,Object? state = freezed,Object? userName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,dateDeadline: freezed == dateDeadline ? _self.dateDeadline : dateDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,activityType: freezed == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityEntity].
extension ActivityEntityPatterns on ActivityEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityEntity value)  $default,){
final _that = this;
switch (_that) {
case _ActivityEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String summary,  String? note,  DateTime? dateDeadline,  String? activityType,  String? state,  String? userName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityEntity() when $default != null:
return $default(_that.id,_that.summary,_that.note,_that.dateDeadline,_that.activityType,_that.state,_that.userName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String summary,  String? note,  DateTime? dateDeadline,  String? activityType,  String? state,  String? userName)  $default,) {final _that = this;
switch (_that) {
case _ActivityEntity():
return $default(_that.id,_that.summary,_that.note,_that.dateDeadline,_that.activityType,_that.state,_that.userName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String summary,  String? note,  DateTime? dateDeadline,  String? activityType,  String? state,  String? userName)?  $default,) {final _that = this;
switch (_that) {
case _ActivityEntity() when $default != null:
return $default(_that.id,_that.summary,_that.note,_that.dateDeadline,_that.activityType,_that.state,_that.userName);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityEntity implements ActivityEntity {
  const _ActivityEntity({required this.id, required this.summary, this.note, this.dateDeadline, this.activityType, this.state, this.userName});
  

@override final  int id;
@override final  String summary;
@override final  String? note;
@override final  DateTime? dateDeadline;
@override final  String? activityType;
@override final  String? state;
@override final  String? userName;

/// Create a copy of ActivityEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityEntityCopyWith<_ActivityEntity> get copyWith => __$ActivityEntityCopyWithImpl<_ActivityEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.note, note) || other.note == note)&&(identical(other.dateDeadline, dateDeadline) || other.dateDeadline == dateDeadline)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.state, state) || other.state == state)&&(identical(other.userName, userName) || other.userName == userName));
}


@override
int get hashCode => Object.hash(runtimeType,id,summary,note,dateDeadline,activityType,state,userName);

@override
String toString() {
  return 'ActivityEntity(id: $id, summary: $summary, note: $note, dateDeadline: $dateDeadline, activityType: $activityType, state: $state, userName: $userName)';
}


}

/// @nodoc
abstract mixin class _$ActivityEntityCopyWith<$Res> implements $ActivityEntityCopyWith<$Res> {
  factory _$ActivityEntityCopyWith(_ActivityEntity value, $Res Function(_ActivityEntity) _then) = __$ActivityEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String summary, String? note, DateTime? dateDeadline, String? activityType, String? state, String? userName
});




}
/// @nodoc
class __$ActivityEntityCopyWithImpl<$Res>
    implements _$ActivityEntityCopyWith<$Res> {
  __$ActivityEntityCopyWithImpl(this._self, this._then);

  final _ActivityEntity _self;
  final $Res Function(_ActivityEntity) _then;

/// Create a copy of ActivityEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? summary = null,Object? note = freezed,Object? dateDeadline = freezed,Object? activityType = freezed,Object? state = freezed,Object? userName = freezed,}) {
  return _then(_ActivityEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,dateDeadline: freezed == dateDeadline ? _self.dateDeadline : dateDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,activityType: freezed == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
