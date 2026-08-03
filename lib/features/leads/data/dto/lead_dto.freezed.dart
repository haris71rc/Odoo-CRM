// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeadDto {

 int get id; String? get name; dynamic get phone;@JsonKey(name: 'partner_name') dynamic get partnerName;@JsonKey(name: 'stage_id') dynamic get stageId;@JsonKey(name: 'user_id') dynamic get userId; dynamic get priority;@JsonKey(name: 'create_date') dynamic get createDate;@JsonKey(name: 'write_date') dynamic get writeDate; dynamic get description;
/// Create a copy of LeadDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadDtoCopyWith<LeadDto> get copyWith => _$LeadDtoCopyWithImpl<LeadDto>(this as LeadDto, _$identity);

  /// Serializes this LeadDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeadDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.phone, phone)&&const DeepCollectionEquality().equals(other.partnerName, partnerName)&&const DeepCollectionEquality().equals(other.stageId, stageId)&&const DeepCollectionEquality().equals(other.userId, userId)&&const DeepCollectionEquality().equals(other.priority, priority)&&const DeepCollectionEquality().equals(other.createDate, createDate)&&const DeepCollectionEquality().equals(other.writeDate, writeDate)&&const DeepCollectionEquality().equals(other.description, description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(phone),const DeepCollectionEquality().hash(partnerName),const DeepCollectionEquality().hash(stageId),const DeepCollectionEquality().hash(userId),const DeepCollectionEquality().hash(priority),const DeepCollectionEquality().hash(createDate),const DeepCollectionEquality().hash(writeDate),const DeepCollectionEquality().hash(description));

@override
String toString() {
  return 'LeadDto(id: $id, name: $name, phone: $phone, partnerName: $partnerName, stageId: $stageId, userId: $userId, priority: $priority, createDate: $createDate, writeDate: $writeDate, description: $description)';
}


}

/// @nodoc
abstract mixin class $LeadDtoCopyWith<$Res>  {
  factory $LeadDtoCopyWith(LeadDto value, $Res Function(LeadDto) _then) = _$LeadDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? name, dynamic phone,@JsonKey(name: 'partner_name') dynamic partnerName,@JsonKey(name: 'stage_id') dynamic stageId,@JsonKey(name: 'user_id') dynamic userId, dynamic priority,@JsonKey(name: 'create_date') dynamic createDate,@JsonKey(name: 'write_date') dynamic writeDate, dynamic description
});




}
/// @nodoc
class _$LeadDtoCopyWithImpl<$Res>
    implements $LeadDtoCopyWith<$Res> {
  _$LeadDtoCopyWithImpl(this._self, this._then);

  final LeadDto _self;
  final $Res Function(LeadDto) _then;

/// Create a copy of LeadDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? phone = freezed,Object? partnerName = freezed,Object? stageId = freezed,Object? userId = freezed,Object? priority = freezed,Object? createDate = freezed,Object? writeDate = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as dynamic,partnerName: freezed == partnerName ? _self.partnerName : partnerName // ignore: cast_nullable_to_non_nullable
as dynamic,stageId: freezed == stageId ? _self.stageId : stageId // ignore: cast_nullable_to_non_nullable
as dynamic,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as dynamic,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as dynamic,createDate: freezed == createDate ? _self.createDate : createDate // ignore: cast_nullable_to_non_nullable
as dynamic,writeDate: freezed == writeDate ? _self.writeDate : writeDate // ignore: cast_nullable_to_non_nullable
as dynamic,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [LeadDto].
extension LeadDtoPatterns on LeadDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeadDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeadDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeadDto value)  $default,){
final _that = this;
switch (_that) {
case _LeadDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeadDto value)?  $default,){
final _that = this;
switch (_that) {
case _LeadDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name,  dynamic phone, @JsonKey(name: 'partner_name')  dynamic partnerName, @JsonKey(name: 'stage_id')  dynamic stageId, @JsonKey(name: 'user_id')  dynamic userId,  dynamic priority, @JsonKey(name: 'create_date')  dynamic createDate, @JsonKey(name: 'write_date')  dynamic writeDate,  dynamic description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeadDto() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.partnerName,_that.stageId,_that.userId,_that.priority,_that.createDate,_that.writeDate,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name,  dynamic phone, @JsonKey(name: 'partner_name')  dynamic partnerName, @JsonKey(name: 'stage_id')  dynamic stageId, @JsonKey(name: 'user_id')  dynamic userId,  dynamic priority, @JsonKey(name: 'create_date')  dynamic createDate, @JsonKey(name: 'write_date')  dynamic writeDate,  dynamic description)  $default,) {final _that = this;
switch (_that) {
case _LeadDto():
return $default(_that.id,_that.name,_that.phone,_that.partnerName,_that.stageId,_that.userId,_that.priority,_that.createDate,_that.writeDate,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name,  dynamic phone, @JsonKey(name: 'partner_name')  dynamic partnerName, @JsonKey(name: 'stage_id')  dynamic stageId, @JsonKey(name: 'user_id')  dynamic userId,  dynamic priority, @JsonKey(name: 'create_date')  dynamic createDate, @JsonKey(name: 'write_date')  dynamic writeDate,  dynamic description)?  $default,) {final _that = this;
switch (_that) {
case _LeadDto() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.partnerName,_that.stageId,_that.userId,_that.priority,_that.createDate,_that.writeDate,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeadDto implements LeadDto {
  const _LeadDto({required this.id, this.name, this.phone, @JsonKey(name: 'partner_name') this.partnerName, @JsonKey(name: 'stage_id') this.stageId, @JsonKey(name: 'user_id') this.userId, this.priority, @JsonKey(name: 'create_date') this.createDate, @JsonKey(name: 'write_date') this.writeDate, this.description});
  factory _LeadDto.fromJson(Map<String, dynamic> json) => _$LeadDtoFromJson(json);

@override final  int id;
@override final  String? name;
@override final  dynamic phone;
@override@JsonKey(name: 'partner_name') final  dynamic partnerName;
@override@JsonKey(name: 'stage_id') final  dynamic stageId;
@override@JsonKey(name: 'user_id') final  dynamic userId;
@override final  dynamic priority;
@override@JsonKey(name: 'create_date') final  dynamic createDate;
@override@JsonKey(name: 'write_date') final  dynamic writeDate;
@override final  dynamic description;

/// Create a copy of LeadDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadDtoCopyWith<_LeadDto> get copyWith => __$LeadDtoCopyWithImpl<_LeadDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeadDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.phone, phone)&&const DeepCollectionEquality().equals(other.partnerName, partnerName)&&const DeepCollectionEquality().equals(other.stageId, stageId)&&const DeepCollectionEquality().equals(other.userId, userId)&&const DeepCollectionEquality().equals(other.priority, priority)&&const DeepCollectionEquality().equals(other.createDate, createDate)&&const DeepCollectionEquality().equals(other.writeDate, writeDate)&&const DeepCollectionEquality().equals(other.description, description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(phone),const DeepCollectionEquality().hash(partnerName),const DeepCollectionEquality().hash(stageId),const DeepCollectionEquality().hash(userId),const DeepCollectionEquality().hash(priority),const DeepCollectionEquality().hash(createDate),const DeepCollectionEquality().hash(writeDate),const DeepCollectionEquality().hash(description));

@override
String toString() {
  return 'LeadDto(id: $id, name: $name, phone: $phone, partnerName: $partnerName, stageId: $stageId, userId: $userId, priority: $priority, createDate: $createDate, writeDate: $writeDate, description: $description)';
}


}

/// @nodoc
abstract mixin class _$LeadDtoCopyWith<$Res> implements $LeadDtoCopyWith<$Res> {
  factory _$LeadDtoCopyWith(_LeadDto value, $Res Function(_LeadDto) _then) = __$LeadDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name, dynamic phone,@JsonKey(name: 'partner_name') dynamic partnerName,@JsonKey(name: 'stage_id') dynamic stageId,@JsonKey(name: 'user_id') dynamic userId, dynamic priority,@JsonKey(name: 'create_date') dynamic createDate,@JsonKey(name: 'write_date') dynamic writeDate, dynamic description
});




}
/// @nodoc
class __$LeadDtoCopyWithImpl<$Res>
    implements _$LeadDtoCopyWith<$Res> {
  __$LeadDtoCopyWithImpl(this._self, this._then);

  final _LeadDto _self;
  final $Res Function(_LeadDto) _then;

/// Create a copy of LeadDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? phone = freezed,Object? partnerName = freezed,Object? stageId = freezed,Object? userId = freezed,Object? priority = freezed,Object? createDate = freezed,Object? writeDate = freezed,Object? description = freezed,}) {
  return _then(_LeadDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as dynamic,partnerName: freezed == partnerName ? _self.partnerName : partnerName // ignore: cast_nullable_to_non_nullable
as dynamic,stageId: freezed == stageId ? _self.stageId : stageId // ignore: cast_nullable_to_non_nullable
as dynamic,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as dynamic,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as dynamic,createDate: freezed == createDate ? _self.createDate : createDate // ignore: cast_nullable_to_non_nullable
as dynamic,writeDate: freezed == writeDate ? _self.writeDate : writeDate // ignore: cast_nullable_to_non_nullable
as dynamic,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
