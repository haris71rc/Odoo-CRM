// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LeadEntity {

 int get id; String get name; String? get phone; String? get partnerName; NamedRefEntity? get stage; NamedRefEntity? get assignedUser; String? get priority; DateTime? get createdDate; String? get description;
/// Create a copy of LeadEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadEntityCopyWith<LeadEntity> get copyWith => _$LeadEntityCopyWithImpl<LeadEntity>(this as LeadEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeadEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.partnerName, partnerName) || other.partnerName == partnerName)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.assignedUser, assignedUser) || other.assignedUser == assignedUser)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,phone,partnerName,stage,assignedUser,priority,createdDate,description);

@override
String toString() {
  return 'LeadEntity(id: $id, name: $name, phone: $phone, partnerName: $partnerName, stage: $stage, assignedUser: $assignedUser, priority: $priority, createdDate: $createdDate, description: $description)';
}


}

/// @nodoc
abstract mixin class $LeadEntityCopyWith<$Res>  {
  factory $LeadEntityCopyWith(LeadEntity value, $Res Function(LeadEntity) _then) = _$LeadEntityCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? phone, String? partnerName, NamedRefEntity? stage, NamedRefEntity? assignedUser, String? priority, DateTime? createdDate, String? description
});


$NamedRefEntityCopyWith<$Res>? get stage;$NamedRefEntityCopyWith<$Res>? get assignedUser;

}
/// @nodoc
class _$LeadEntityCopyWithImpl<$Res>
    implements $LeadEntityCopyWith<$Res> {
  _$LeadEntityCopyWithImpl(this._self, this._then);

  final LeadEntity _self;
  final $Res Function(LeadEntity) _then;

/// Create a copy of LeadEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = freezed,Object? partnerName = freezed,Object? stage = freezed,Object? assignedUser = freezed,Object? priority = freezed,Object? createdDate = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,partnerName: freezed == partnerName ? _self.partnerName : partnerName // ignore: cast_nullable_to_non_nullable
as String?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,assignedUser: freezed == assignedUser ? _self.assignedUser : assignedUser // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,createdDate: freezed == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of LeadEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get stage {
    if (_self.stage == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.stage!, (value) {
    return _then(_self.copyWith(stage: value));
  });
}/// Create a copy of LeadEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get assignedUser {
    if (_self.assignedUser == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.assignedUser!, (value) {
    return _then(_self.copyWith(assignedUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeadEntity].
extension LeadEntityPatterns on LeadEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeadEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeadEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeadEntity value)  $default,){
final _that = this;
switch (_that) {
case _LeadEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeadEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LeadEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? phone,  String? partnerName,  NamedRefEntity? stage,  NamedRefEntity? assignedUser,  String? priority,  DateTime? createdDate,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeadEntity() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.partnerName,_that.stage,_that.assignedUser,_that.priority,_that.createdDate,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? phone,  String? partnerName,  NamedRefEntity? stage,  NamedRefEntity? assignedUser,  String? priority,  DateTime? createdDate,  String? description)  $default,) {final _that = this;
switch (_that) {
case _LeadEntity():
return $default(_that.id,_that.name,_that.phone,_that.partnerName,_that.stage,_that.assignedUser,_that.priority,_that.createdDate,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? phone,  String? partnerName,  NamedRefEntity? stage,  NamedRefEntity? assignedUser,  String? priority,  DateTime? createdDate,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _LeadEntity() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.partnerName,_that.stage,_that.assignedUser,_that.priority,_that.createdDate,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _LeadEntity implements LeadEntity {
  const _LeadEntity({required this.id, required this.name, this.phone, this.partnerName, this.stage, this.assignedUser, this.priority, this.createdDate, this.description});
  

@override final  int id;
@override final  String name;
@override final  String? phone;
@override final  String? partnerName;
@override final  NamedRefEntity? stage;
@override final  NamedRefEntity? assignedUser;
@override final  String? priority;
@override final  DateTime? createdDate;
@override final  String? description;

/// Create a copy of LeadEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadEntityCopyWith<_LeadEntity> get copyWith => __$LeadEntityCopyWithImpl<_LeadEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeadEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.partnerName, partnerName) || other.partnerName == partnerName)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.assignedUser, assignedUser) || other.assignedUser == assignedUser)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,phone,partnerName,stage,assignedUser,priority,createdDate,description);

@override
String toString() {
  return 'LeadEntity(id: $id, name: $name, phone: $phone, partnerName: $partnerName, stage: $stage, assignedUser: $assignedUser, priority: $priority, createdDate: $createdDate, description: $description)';
}


}

/// @nodoc
abstract mixin class _$LeadEntityCopyWith<$Res> implements $LeadEntityCopyWith<$Res> {
  factory _$LeadEntityCopyWith(_LeadEntity value, $Res Function(_LeadEntity) _then) = __$LeadEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? phone, String? partnerName, NamedRefEntity? stage, NamedRefEntity? assignedUser, String? priority, DateTime? createdDate, String? description
});


@override $NamedRefEntityCopyWith<$Res>? get stage;@override $NamedRefEntityCopyWith<$Res>? get assignedUser;

}
/// @nodoc
class __$LeadEntityCopyWithImpl<$Res>
    implements _$LeadEntityCopyWith<$Res> {
  __$LeadEntityCopyWithImpl(this._self, this._then);

  final _LeadEntity _self;
  final $Res Function(_LeadEntity) _then;

/// Create a copy of LeadEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = freezed,Object? partnerName = freezed,Object? stage = freezed,Object? assignedUser = freezed,Object? priority = freezed,Object? createdDate = freezed,Object? description = freezed,}) {
  return _then(_LeadEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,partnerName: freezed == partnerName ? _self.partnerName : partnerName // ignore: cast_nullable_to_non_nullable
as String?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,assignedUser: freezed == assignedUser ? _self.assignedUser : assignedUser // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,createdDate: freezed == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of LeadEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get stage {
    if (_self.stage == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.stage!, (value) {
    return _then(_self.copyWith(stage: value));
  });
}/// Create a copy of LeadEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get assignedUser {
    if (_self.assignedUser == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.assignedUser!, (value) {
    return _then(_self.copyWith(assignedUser: value));
  });
}
}

// dart format on
