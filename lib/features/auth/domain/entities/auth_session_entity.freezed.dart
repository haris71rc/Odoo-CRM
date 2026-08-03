// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthSessionEntity {

 int get uid; String get sessionId; String get login; String? get name; String? get partnerDisplayName;
/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionEntityCopyWith<AuthSessionEntity> get copyWith => _$AuthSessionEntityCopyWithImpl<AuthSessionEntity>(this as AuthSessionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionEntity&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.login, login) || other.login == login)&&(identical(other.name, name) || other.name == name)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName));
}


@override
int get hashCode => Object.hash(runtimeType,uid,sessionId,login,name,partnerDisplayName);

@override
String toString() {
  return 'AuthSessionEntity(uid: $uid, sessionId: $sessionId, login: $login, name: $name, partnerDisplayName: $partnerDisplayName)';
}


}

/// @nodoc
abstract mixin class $AuthSessionEntityCopyWith<$Res>  {
  factory $AuthSessionEntityCopyWith(AuthSessionEntity value, $Res Function(AuthSessionEntity) _then) = _$AuthSessionEntityCopyWithImpl;
@useResult
$Res call({
 int uid, String sessionId, String login, String? name, String? partnerDisplayName
});




}
/// @nodoc
class _$AuthSessionEntityCopyWithImpl<$Res>
    implements $AuthSessionEntityCopyWith<$Res> {
  _$AuthSessionEntityCopyWithImpl(this._self, this._then);

  final AuthSessionEntity _self;
  final $Res Function(AuthSessionEntity) _then;

/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? sessionId = null,Object? login = null,Object? name = freezed,Object? partnerDisplayName = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthSessionEntity].
extension AuthSessionEntityPatterns on AuthSessionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSessionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSessionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSessionEntity value)  $default,){
final _that = this;
switch (_that) {
case _AuthSessionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSessionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSessionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int uid,  String sessionId,  String login,  String? name,  String? partnerDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSessionEntity() when $default != null:
return $default(_that.uid,_that.sessionId,_that.login,_that.name,_that.partnerDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int uid,  String sessionId,  String login,  String? name,  String? partnerDisplayName)  $default,) {final _that = this;
switch (_that) {
case _AuthSessionEntity():
return $default(_that.uid,_that.sessionId,_that.login,_that.name,_that.partnerDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int uid,  String sessionId,  String login,  String? name,  String? partnerDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _AuthSessionEntity() when $default != null:
return $default(_that.uid,_that.sessionId,_that.login,_that.name,_that.partnerDisplayName);case _:
  return null;

}
}

}

/// @nodoc


class _AuthSessionEntity implements AuthSessionEntity {
  const _AuthSessionEntity({required this.uid, required this.sessionId, required this.login, this.name, this.partnerDisplayName});
  

@override final  int uid;
@override final  String sessionId;
@override final  String login;
@override final  String? name;
@override final  String? partnerDisplayName;

/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionEntityCopyWith<_AuthSessionEntity> get copyWith => __$AuthSessionEntityCopyWithImpl<_AuthSessionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSessionEntity&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.login, login) || other.login == login)&&(identical(other.name, name) || other.name == name)&&(identical(other.partnerDisplayName, partnerDisplayName) || other.partnerDisplayName == partnerDisplayName));
}


@override
int get hashCode => Object.hash(runtimeType,uid,sessionId,login,name,partnerDisplayName);

@override
String toString() {
  return 'AuthSessionEntity(uid: $uid, sessionId: $sessionId, login: $login, name: $name, partnerDisplayName: $partnerDisplayName)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionEntityCopyWith<$Res> implements $AuthSessionEntityCopyWith<$Res> {
  factory _$AuthSessionEntityCopyWith(_AuthSessionEntity value, $Res Function(_AuthSessionEntity) _then) = __$AuthSessionEntityCopyWithImpl;
@override @useResult
$Res call({
 int uid, String sessionId, String login, String? name, String? partnerDisplayName
});




}
/// @nodoc
class __$AuthSessionEntityCopyWithImpl<$Res>
    implements _$AuthSessionEntityCopyWith<$Res> {
  __$AuthSessionEntityCopyWithImpl(this._self, this._then);

  final _AuthSessionEntity _self;
  final $Res Function(_AuthSessionEntity) _then;

/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? sessionId = null,Object? login = null,Object? name = freezed,Object? partnerDisplayName = freezed,}) {
  return _then(_AuthSessionEntity(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,partnerDisplayName: freezed == partnerDisplayName ? _self.partnerDisplayName : partnerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
