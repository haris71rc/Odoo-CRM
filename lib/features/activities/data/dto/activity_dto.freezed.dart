// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityDto {

 int get id; dynamic get summary; dynamic get note;@JsonKey(name: 'date_deadline') dynamic get dateDeadline;@JsonKey(name: 'activity_type_id') dynamic get activityTypeId; dynamic get state;@JsonKey(name: 'user_id') dynamic get userId;
/// Create a copy of ActivityDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityDtoCopyWith<ActivityDto> get copyWith => _$ActivityDtoCopyWithImpl<ActivityDto>(this as ActivityDto, _$identity);

  /// Serializes this ActivityDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityDto&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.summary, summary)&&const DeepCollectionEquality().equals(other.note, note)&&const DeepCollectionEquality().equals(other.dateDeadline, dateDeadline)&&const DeepCollectionEquality().equals(other.activityTypeId, activityTypeId)&&const DeepCollectionEquality().equals(other.state, state)&&const DeepCollectionEquality().equals(other.userId, userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(summary),const DeepCollectionEquality().hash(note),const DeepCollectionEquality().hash(dateDeadline),const DeepCollectionEquality().hash(activityTypeId),const DeepCollectionEquality().hash(state),const DeepCollectionEquality().hash(userId));

@override
String toString() {
  return 'ActivityDto(id: $id, summary: $summary, note: $note, dateDeadline: $dateDeadline, activityTypeId: $activityTypeId, state: $state, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $ActivityDtoCopyWith<$Res>  {
  factory $ActivityDtoCopyWith(ActivityDto value, $Res Function(ActivityDto) _then) = _$ActivityDtoCopyWithImpl;
@useResult
$Res call({
 int id, dynamic summary, dynamic note,@JsonKey(name: 'date_deadline') dynamic dateDeadline,@JsonKey(name: 'activity_type_id') dynamic activityTypeId, dynamic state,@JsonKey(name: 'user_id') dynamic userId
});




}
/// @nodoc
class _$ActivityDtoCopyWithImpl<$Res>
    implements $ActivityDtoCopyWith<$Res> {
  _$ActivityDtoCopyWithImpl(this._self, this._then);

  final ActivityDto _self;
  final $Res Function(ActivityDto) _then;

/// Create a copy of ActivityDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? summary = freezed,Object? note = freezed,Object? dateDeadline = freezed,Object? activityTypeId = freezed,Object? state = freezed,Object? userId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as dynamic,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as dynamic,dateDeadline: freezed == dateDeadline ? _self.dateDeadline : dateDeadline // ignore: cast_nullable_to_non_nullable
as dynamic,activityTypeId: freezed == activityTypeId ? _self.activityTypeId : activityTypeId // ignore: cast_nullable_to_non_nullable
as dynamic,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as dynamic,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityDto].
extension ActivityDtoPatterns on ActivityDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityDto value)  $default,){
final _that = this;
switch (_that) {
case _ActivityDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityDto value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  dynamic summary,  dynamic note, @JsonKey(name: 'date_deadline')  dynamic dateDeadline, @JsonKey(name: 'activity_type_id')  dynamic activityTypeId,  dynamic state, @JsonKey(name: 'user_id')  dynamic userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityDto() when $default != null:
return $default(_that.id,_that.summary,_that.note,_that.dateDeadline,_that.activityTypeId,_that.state,_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  dynamic summary,  dynamic note, @JsonKey(name: 'date_deadline')  dynamic dateDeadline, @JsonKey(name: 'activity_type_id')  dynamic activityTypeId,  dynamic state, @JsonKey(name: 'user_id')  dynamic userId)  $default,) {final _that = this;
switch (_that) {
case _ActivityDto():
return $default(_that.id,_that.summary,_that.note,_that.dateDeadline,_that.activityTypeId,_that.state,_that.userId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  dynamic summary,  dynamic note, @JsonKey(name: 'date_deadline')  dynamic dateDeadline, @JsonKey(name: 'activity_type_id')  dynamic activityTypeId,  dynamic state, @JsonKey(name: 'user_id')  dynamic userId)?  $default,) {final _that = this;
switch (_that) {
case _ActivityDto() when $default != null:
return $default(_that.id,_that.summary,_that.note,_that.dateDeadline,_that.activityTypeId,_that.state,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityDto implements ActivityDto {
  const _ActivityDto({required this.id, this.summary, this.note, @JsonKey(name: 'date_deadline') this.dateDeadline, @JsonKey(name: 'activity_type_id') this.activityTypeId, this.state, @JsonKey(name: 'user_id') this.userId});
  factory _ActivityDto.fromJson(Map<String, dynamic> json) => _$ActivityDtoFromJson(json);

@override final  int id;
@override final  dynamic summary;
@override final  dynamic note;
@override@JsonKey(name: 'date_deadline') final  dynamic dateDeadline;
@override@JsonKey(name: 'activity_type_id') final  dynamic activityTypeId;
@override final  dynamic state;
@override@JsonKey(name: 'user_id') final  dynamic userId;

/// Create a copy of ActivityDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityDtoCopyWith<_ActivityDto> get copyWith => __$ActivityDtoCopyWithImpl<_ActivityDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityDto&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.summary, summary)&&const DeepCollectionEquality().equals(other.note, note)&&const DeepCollectionEquality().equals(other.dateDeadline, dateDeadline)&&const DeepCollectionEquality().equals(other.activityTypeId, activityTypeId)&&const DeepCollectionEquality().equals(other.state, state)&&const DeepCollectionEquality().equals(other.userId, userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(summary),const DeepCollectionEquality().hash(note),const DeepCollectionEquality().hash(dateDeadline),const DeepCollectionEquality().hash(activityTypeId),const DeepCollectionEquality().hash(state),const DeepCollectionEquality().hash(userId));

@override
String toString() {
  return 'ActivityDto(id: $id, summary: $summary, note: $note, dateDeadline: $dateDeadline, activityTypeId: $activityTypeId, state: $state, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$ActivityDtoCopyWith<$Res> implements $ActivityDtoCopyWith<$Res> {
  factory _$ActivityDtoCopyWith(_ActivityDto value, $Res Function(_ActivityDto) _then) = __$ActivityDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, dynamic summary, dynamic note,@JsonKey(name: 'date_deadline') dynamic dateDeadline,@JsonKey(name: 'activity_type_id') dynamic activityTypeId, dynamic state,@JsonKey(name: 'user_id') dynamic userId
});




}
/// @nodoc
class __$ActivityDtoCopyWithImpl<$Res>
    implements _$ActivityDtoCopyWith<$Res> {
  __$ActivityDtoCopyWithImpl(this._self, this._then);

  final _ActivityDto _self;
  final $Res Function(_ActivityDto) _then;

/// Create a copy of ActivityDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? summary = freezed,Object? note = freezed,Object? dateDeadline = freezed,Object? activityTypeId = freezed,Object? state = freezed,Object? userId = freezed,}) {
  return _then(_ActivityDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as dynamic,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as dynamic,dateDeadline: freezed == dateDeadline ? _self.dateDeadline : dateDeadline // ignore: cast_nullable_to_non_nullable
as dynamic,activityTypeId: freezed == activityTypeId ? _self.activityTypeId : activityTypeId // ignore: cast_nullable_to_non_nullable
as dynamic,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as dynamic,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
