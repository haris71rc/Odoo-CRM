// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthSessionDto {

 int get uid; String? get name; String? get username;@JsonKey(name: 'partner_display_name') String? get partnerDisplayName;@JsonKey(name: 'session_id') String? get sessionId;
/// Create a copy of AuthSessionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionDtoCopyWith<AuthSessionDto> get copyWith => _$AuthSessionDtoCopyWithImpl<AuthSessionDto>(this as AuthSessionDto, _$identity);

  /// Serializes this AuthSessionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionDto&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,username,partnerDisplayName,sessionId);

@override
String toString() {
  return 'AuthSessionDto(uid: $uid, name: $name, username: $username, partnerDisplayName: $partnerDisplayName, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $AuthSessionDtoCopyWith<$Res>  {
  factory $AuthSessionDtoCopyWith(AuthSessionDto value, $Res Function(AuthSessionDto) _then) = _$AuthSessionDtoCopyWithImpl;
@useResult
$Res call({
 int uid, String? name, String? username,@JsonKey(name: 'partner_display_name') String? partnerDisplayName,@JsonKey(name: 'session_id') String? sessionId
});




}
/// @nodoc
class _$AuthSessionDtoCopyWithImpl<$Res>
    implements $AuthSessionDtoCopyWith<$Res> {
  _$AuthSessionDtoCopyWithImpl(this._self, this._then);

  final AuthSessionDto _self;
  final $Res Function(AuthSessionDto) _then;

/// Create a copy of AuthSessionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = freezed,Object? username = freezed,Object? partnerDisplayName = freezed,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthSessionDto].
extension AuthSessionDtoPatterns on AuthSessionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSessionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSessionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSessionDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthSessionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSessionDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSessionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int uid,  String? name,  String? username, @JsonKey(name: 'partner_display_name')  String? partnerDisplayName, @JsonKey(name: 'session_id')  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSessionDto() when $default != null:
return $default(_that.uid,_that.name,_that.username,_that.partnerDisplayName,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int uid,  String? name,  String? username, @JsonKey(name: 'partner_display_name')  String? partnerDisplayName, @JsonKey(name: 'session_id')  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _AuthSessionDto():
return $default(_that.uid,_that.name,_that.username,_that.partnerDisplayName,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int uid,  String? name,  String? username, @JsonKey(name: 'partner_display_name')  String? partnerDisplayName, @JsonKey(name: 'session_id')  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _AuthSessionDto() when $default != null:
return $default(_that.uid,_that.name,_that.username,_that.partnerDisplayName,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthSessionDto implements AuthSessionDto {
  const _AuthSessionDto({required this.uid, this.name, this.username, @JsonKey(name: 'partner_display_name') this.partnerDisplayName, @JsonKey(name: 'session_id') this.sessionId});
  factory _AuthSessionDto.fromJson(Map<String, dynamic> json) => _$AuthSessionDtoFromJson(json);

@override final  int uid;
@override final  String? name;
@override final  String? username;
@override@JsonKey(name: 'partner_display_name') final  String? partnerDisplayName;
@override@JsonKey(name: 'session_id') final  String? sessionId;

/// Create a copy of AuthSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionDtoCopyWith<_AuthSessionDto> get copyWith => __$AuthSessionDtoCopyWithImpl<_AuthSessionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthSessionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSessionDto&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,name,username,partnerDisplayName,sessionId);

@override
String toString() {
  return 'AuthSessionDto(uid: $uid, name: $name, username: $username, partnerDisplayName: $partnerDisplayName, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionDtoCopyWith<$Res> implements $AuthSessionDtoCopyWith<$Res> {
  factory _$AuthSessionDtoCopyWith(_AuthSessionDto value, $Res Function(_AuthSessionDto) _then) = __$AuthSessionDtoCopyWithImpl;
@override @useResult
$Res call({
 int uid, String? name, String? username,@JsonKey(name: 'partner_display_name') String? partnerDisplayName,@JsonKey(name: 'session_id') String? sessionId
});




}
/// @nodoc
class __$AuthSessionDtoCopyWithImpl<$Res>
    implements _$AuthSessionDtoCopyWith<$Res> {
  __$AuthSessionDtoCopyWithImpl(this._self, this._then);

  final _AuthSessionDto _self;
  final $Res Function(_AuthSessionDto) _then;

/// Create a copy of AuthSessionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = freezed,Object? username = freezed,Object? partnerDisplayName = freezed,Object? sessionId = freezed,}) {
  return _then(_AuthSessionDto(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
