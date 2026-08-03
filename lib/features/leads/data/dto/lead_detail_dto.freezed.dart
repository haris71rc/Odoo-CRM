// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeadDetailDto {

 int get id; String? get name;@JsonKey(name: 'partner_name') dynamic get partnerName; dynamic get phone; dynamic get mobile;@JsonKey(name: 'email_from') dynamic get emailFrom; dynamic get street; dynamic get city;@JsonKey(name: 'state_id') dynamic get stateId;@JsonKey(name: 'country_id') dynamic get countryId; dynamic get zip; dynamic get description;@JsonKey(name: 'stage_id') dynamic get stageId;@JsonKey(name: 'user_id') dynamic get userId;@JsonKey(name: 'team_id') dynamic get teamId; dynamic get priority;@JsonKey(name: 'create_date') dynamic get createDate;@JsonKey(name: 'write_date') dynamic get writeDate;@JsonKey(name: 'expected_revenue') dynamic get expectedRevenue; dynamic get probability;@JsonKey(name: 'tag_ids') dynamic get tagIds;
/// Create a copy of LeadDetailDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadDetailDtoCopyWith<LeadDetailDto> get copyWith => _$LeadDetailDtoCopyWithImpl<LeadDetailDto>(this as LeadDetailDto, _$identity);

  /// Serializes this LeadDetailDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeadDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.partnerName, partnerName)&&const DeepCollectionEquality().equals(other.phone, phone)&&const DeepCollectionEquality().equals(other.mobile, mobile)&&const DeepCollectionEquality().equals(other.emailFrom, emailFrom)&&const DeepCollectionEquality().equals(other.street, street)&&const DeepCollectionEquality().equals(other.city, city)&&const DeepCollectionEquality().equals(other.stateId, stateId)&&const DeepCollectionEquality().equals(other.countryId, countryId)&&const DeepCollectionEquality().equals(other.zip, zip)&&const DeepCollectionEquality().equals(other.description, description)&&const DeepCollectionEquality().equals(other.stageId, stageId)&&const DeepCollectionEquality().equals(other.userId, userId)&&const DeepCollectionEquality().equals(other.teamId, teamId)&&const DeepCollectionEquality().equals(other.priority, priority)&&const DeepCollectionEquality().equals(other.createDate, createDate)&&const DeepCollectionEquality().equals(other.writeDate, writeDate)&&const DeepCollectionEquality().equals(other.expectedRevenue, expectedRevenue)&&const DeepCollectionEquality().equals(other.probability, probability)&&const DeepCollectionEquality().equals(other.tagIds, tagIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,const DeepCollectionEquality().hash(partnerName),const DeepCollectionEquality().hash(phone),const DeepCollectionEquality().hash(mobile),const DeepCollectionEquality().hash(emailFrom),const DeepCollectionEquality().hash(street),const DeepCollectionEquality().hash(city),const DeepCollectionEquality().hash(stateId),const DeepCollectionEquality().hash(countryId),const DeepCollectionEquality().hash(zip),const DeepCollectionEquality().hash(description),const DeepCollectionEquality().hash(stageId),const DeepCollectionEquality().hash(userId),const DeepCollectionEquality().hash(teamId),const DeepCollectionEquality().hash(priority),const DeepCollectionEquality().hash(createDate),const DeepCollectionEquality().hash(writeDate),const DeepCollectionEquality().hash(expectedRevenue),const DeepCollectionEquality().hash(probability),const DeepCollectionEquality().hash(tagIds)]);

@override
String toString() {
  return 'LeadDetailDto(id: $id, name: $name, partnerName: $partnerName, phone: $phone, mobile: $mobile, emailFrom: $emailFrom, street: $street, city: $city, stateId: $stateId, countryId: $countryId, zip: $zip, description: $description, stageId: $stageId, userId: $userId, teamId: $teamId, priority: $priority, createDate: $createDate, writeDate: $writeDate, expectedRevenue: $expectedRevenue, probability: $probability, tagIds: $tagIds)';
}


}

/// @nodoc
abstract mixin class $LeadDetailDtoCopyWith<$Res>  {
  factory $LeadDetailDtoCopyWith(LeadDetailDto value, $Res Function(LeadDetailDto) _then) = _$LeadDetailDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? name,@JsonKey(name: 'partner_name') dynamic partnerName, dynamic phone, dynamic mobile,@JsonKey(name: 'email_from') dynamic emailFrom, dynamic street, dynamic city,@JsonKey(name: 'state_id') dynamic stateId,@JsonKey(name: 'country_id') dynamic countryId, dynamic zip, dynamic description,@JsonKey(name: 'stage_id') dynamic stageId,@JsonKey(name: 'user_id') dynamic userId,@JsonKey(name: 'team_id') dynamic teamId, dynamic priority,@JsonKey(name: 'create_date') dynamic createDate,@JsonKey(name: 'write_date') dynamic writeDate,@JsonKey(name: 'expected_revenue') dynamic expectedRevenue, dynamic probability,@JsonKey(name: 'tag_ids') dynamic tagIds
});




}
/// @nodoc
class _$LeadDetailDtoCopyWithImpl<$Res>
    implements $LeadDetailDtoCopyWith<$Res> {
  _$LeadDetailDtoCopyWithImpl(this._self, this._then);

  final LeadDetailDto _self;
  final $Res Function(LeadDetailDto) _then;

/// Create a copy of LeadDetailDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? partnerName = freezed,Object? phone = freezed,Object? mobile = freezed,Object? emailFrom = freezed,Object? street = freezed,Object? city = freezed,Object? stateId = freezed,Object? countryId = freezed,Object? zip = freezed,Object? description = freezed,Object? stageId = freezed,Object? userId = freezed,Object? teamId = freezed,Object? priority = freezed,Object? createDate = freezed,Object? writeDate = freezed,Object? expectedRevenue = freezed,Object? probability = freezed,Object? tagIds = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,partnerName: freezed == partnerName ? _self.partnerName : partnerName // ignore: cast_nullable_to_non_nullable
as dynamic,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as dynamic,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as dynamic,emailFrom: freezed == emailFrom ? _self.emailFrom : emailFrom // ignore: cast_nullable_to_non_nullable
as dynamic,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as dynamic,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as dynamic,stateId: freezed == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as dynamic,countryId: freezed == countryId ? _self.countryId : countryId // ignore: cast_nullable_to_non_nullable
as dynamic,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as dynamic,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as dynamic,stageId: freezed == stageId ? _self.stageId : stageId // ignore: cast_nullable_to_non_nullable
as dynamic,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as dynamic,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as dynamic,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as dynamic,createDate: freezed == createDate ? _self.createDate : createDate // ignore: cast_nullable_to_non_nullable
as dynamic,writeDate: freezed == writeDate ? _self.writeDate : writeDate // ignore: cast_nullable_to_non_nullable
as dynamic,expectedRevenue: freezed == expectedRevenue ? _self.expectedRevenue : expectedRevenue // ignore: cast_nullable_to_non_nullable
as dynamic,probability: freezed == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as dynamic,tagIds: freezed == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [LeadDetailDto].
extension LeadDetailDtoPatterns on LeadDetailDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeadDetailDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeadDetailDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeadDetailDto value)  $default,){
final _that = this;
switch (_that) {
case _LeadDetailDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeadDetailDto value)?  $default,){
final _that = this;
switch (_that) {
case _LeadDetailDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? name, @JsonKey(name: 'partner_name')  dynamic partnerName,  dynamic phone,  dynamic mobile, @JsonKey(name: 'email_from')  dynamic emailFrom,  dynamic street,  dynamic city, @JsonKey(name: 'state_id')  dynamic stateId, @JsonKey(name: 'country_id')  dynamic countryId,  dynamic zip,  dynamic description, @JsonKey(name: 'stage_id')  dynamic stageId, @JsonKey(name: 'user_id')  dynamic userId, @JsonKey(name: 'team_id')  dynamic teamId,  dynamic priority, @JsonKey(name: 'create_date')  dynamic createDate, @JsonKey(name: 'write_date')  dynamic writeDate, @JsonKey(name: 'expected_revenue')  dynamic expectedRevenue,  dynamic probability, @JsonKey(name: 'tag_ids')  dynamic tagIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeadDetailDto() when $default != null:
return $default(_that.id,_that.name,_that.partnerName,_that.phone,_that.mobile,_that.emailFrom,_that.street,_that.city,_that.stateId,_that.countryId,_that.zip,_that.description,_that.stageId,_that.userId,_that.teamId,_that.priority,_that.createDate,_that.writeDate,_that.expectedRevenue,_that.probability,_that.tagIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? name, @JsonKey(name: 'partner_name')  dynamic partnerName,  dynamic phone,  dynamic mobile, @JsonKey(name: 'email_from')  dynamic emailFrom,  dynamic street,  dynamic city, @JsonKey(name: 'state_id')  dynamic stateId, @JsonKey(name: 'country_id')  dynamic countryId,  dynamic zip,  dynamic description, @JsonKey(name: 'stage_id')  dynamic stageId, @JsonKey(name: 'user_id')  dynamic userId, @JsonKey(name: 'team_id')  dynamic teamId,  dynamic priority, @JsonKey(name: 'create_date')  dynamic createDate, @JsonKey(name: 'write_date')  dynamic writeDate, @JsonKey(name: 'expected_revenue')  dynamic expectedRevenue,  dynamic probability, @JsonKey(name: 'tag_ids')  dynamic tagIds)  $default,) {final _that = this;
switch (_that) {
case _LeadDetailDto():
return $default(_that.id,_that.name,_that.partnerName,_that.phone,_that.mobile,_that.emailFrom,_that.street,_that.city,_that.stateId,_that.countryId,_that.zip,_that.description,_that.stageId,_that.userId,_that.teamId,_that.priority,_that.createDate,_that.writeDate,_that.expectedRevenue,_that.probability,_that.tagIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? name, @JsonKey(name: 'partner_name')  dynamic partnerName,  dynamic phone,  dynamic mobile, @JsonKey(name: 'email_from')  dynamic emailFrom,  dynamic street,  dynamic city, @JsonKey(name: 'state_id')  dynamic stateId, @JsonKey(name: 'country_id')  dynamic countryId,  dynamic zip,  dynamic description, @JsonKey(name: 'stage_id')  dynamic stageId, @JsonKey(name: 'user_id')  dynamic userId, @JsonKey(name: 'team_id')  dynamic teamId,  dynamic priority, @JsonKey(name: 'create_date')  dynamic createDate, @JsonKey(name: 'write_date')  dynamic writeDate, @JsonKey(name: 'expected_revenue')  dynamic expectedRevenue,  dynamic probability, @JsonKey(name: 'tag_ids')  dynamic tagIds)?  $default,) {final _that = this;
switch (_that) {
case _LeadDetailDto() when $default != null:
return $default(_that.id,_that.name,_that.partnerName,_that.phone,_that.mobile,_that.emailFrom,_that.street,_that.city,_that.stateId,_that.countryId,_that.zip,_that.description,_that.stageId,_that.userId,_that.teamId,_that.priority,_that.createDate,_that.writeDate,_that.expectedRevenue,_that.probability,_that.tagIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeadDetailDto implements LeadDetailDto {
  const _LeadDetailDto({required this.id, this.name, @JsonKey(name: 'partner_name') this.partnerName, this.phone, this.mobile, @JsonKey(name: 'email_from') this.emailFrom, this.street, this.city, @JsonKey(name: 'state_id') this.stateId, @JsonKey(name: 'country_id') this.countryId, this.zip, this.description, @JsonKey(name: 'stage_id') this.stageId, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'team_id') this.teamId, this.priority, @JsonKey(name: 'create_date') this.createDate, @JsonKey(name: 'write_date') this.writeDate, @JsonKey(name: 'expected_revenue') this.expectedRevenue, this.probability, @JsonKey(name: 'tag_ids') this.tagIds});
  factory _LeadDetailDto.fromJson(Map<String, dynamic> json) => _$LeadDetailDtoFromJson(json);

@override final  int id;
@override final  String? name;
@override@JsonKey(name: 'partner_name') final  dynamic partnerName;
@override final  dynamic phone;
@override final  dynamic mobile;
@override@JsonKey(name: 'email_from') final  dynamic emailFrom;
@override final  dynamic street;
@override final  dynamic city;
@override@JsonKey(name: 'state_id') final  dynamic stateId;
@override@JsonKey(name: 'country_id') final  dynamic countryId;
@override final  dynamic zip;
@override final  dynamic description;
@override@JsonKey(name: 'stage_id') final  dynamic stageId;
@override@JsonKey(name: 'user_id') final  dynamic userId;
@override@JsonKey(name: 'team_id') final  dynamic teamId;
@override final  dynamic priority;
@override@JsonKey(name: 'create_date') final  dynamic createDate;
@override@JsonKey(name: 'write_date') final  dynamic writeDate;
@override@JsonKey(name: 'expected_revenue') final  dynamic expectedRevenue;
@override final  dynamic probability;
@override@JsonKey(name: 'tag_ids') final  dynamic tagIds;

/// Create a copy of LeadDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadDetailDtoCopyWith<_LeadDetailDto> get copyWith => __$LeadDetailDtoCopyWithImpl<_LeadDetailDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadDetailDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeadDetailDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.partnerName, partnerName)&&const DeepCollectionEquality().equals(other.phone, phone)&&const DeepCollectionEquality().equals(other.mobile, mobile)&&const DeepCollectionEquality().equals(other.emailFrom, emailFrom)&&const DeepCollectionEquality().equals(other.street, street)&&const DeepCollectionEquality().equals(other.city, city)&&const DeepCollectionEquality().equals(other.stateId, stateId)&&const DeepCollectionEquality().equals(other.countryId, countryId)&&const DeepCollectionEquality().equals(other.zip, zip)&&const DeepCollectionEquality().equals(other.description, description)&&const DeepCollectionEquality().equals(other.stageId, stageId)&&const DeepCollectionEquality().equals(other.userId, userId)&&const DeepCollectionEquality().equals(other.teamId, teamId)&&const DeepCollectionEquality().equals(other.priority, priority)&&const DeepCollectionEquality().equals(other.createDate, createDate)&&const DeepCollectionEquality().equals(other.writeDate, writeDate)&&const DeepCollectionEquality().equals(other.expectedRevenue, expectedRevenue)&&const DeepCollectionEquality().equals(other.probability, probability)&&const DeepCollectionEquality().equals(other.tagIds, tagIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,const DeepCollectionEquality().hash(partnerName),const DeepCollectionEquality().hash(phone),const DeepCollectionEquality().hash(mobile),const DeepCollectionEquality().hash(emailFrom),const DeepCollectionEquality().hash(street),const DeepCollectionEquality().hash(city),const DeepCollectionEquality().hash(stateId),const DeepCollectionEquality().hash(countryId),const DeepCollectionEquality().hash(zip),const DeepCollectionEquality().hash(description),const DeepCollectionEquality().hash(stageId),const DeepCollectionEquality().hash(userId),const DeepCollectionEquality().hash(teamId),const DeepCollectionEquality().hash(priority),const DeepCollectionEquality().hash(createDate),const DeepCollectionEquality().hash(writeDate),const DeepCollectionEquality().hash(expectedRevenue),const DeepCollectionEquality().hash(probability),const DeepCollectionEquality().hash(tagIds)]);

@override
String toString() {
  return 'LeadDetailDto(id: $id, name: $name, partnerName: $partnerName, phone: $phone, mobile: $mobile, emailFrom: $emailFrom, street: $street, city: $city, stateId: $stateId, countryId: $countryId, zip: $zip, description: $description, stageId: $stageId, userId: $userId, teamId: $teamId, priority: $priority, createDate: $createDate, writeDate: $writeDate, expectedRevenue: $expectedRevenue, probability: $probability, tagIds: $tagIds)';
}


}

/// @nodoc
abstract mixin class _$LeadDetailDtoCopyWith<$Res> implements $LeadDetailDtoCopyWith<$Res> {
  factory _$LeadDetailDtoCopyWith(_LeadDetailDto value, $Res Function(_LeadDetailDto) _then) = __$LeadDetailDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? name,@JsonKey(name: 'partner_name') dynamic partnerName, dynamic phone, dynamic mobile,@JsonKey(name: 'email_from') dynamic emailFrom, dynamic street, dynamic city,@JsonKey(name: 'state_id') dynamic stateId,@JsonKey(name: 'country_id') dynamic countryId, dynamic zip, dynamic description,@JsonKey(name: 'stage_id') dynamic stageId,@JsonKey(name: 'user_id') dynamic userId,@JsonKey(name: 'team_id') dynamic teamId, dynamic priority,@JsonKey(name: 'create_date') dynamic createDate,@JsonKey(name: 'write_date') dynamic writeDate,@JsonKey(name: 'expected_revenue') dynamic expectedRevenue, dynamic probability,@JsonKey(name: 'tag_ids') dynamic tagIds
});




}
/// @nodoc
class __$LeadDetailDtoCopyWithImpl<$Res>
    implements _$LeadDetailDtoCopyWith<$Res> {
  __$LeadDetailDtoCopyWithImpl(this._self, this._then);

  final _LeadDetailDto _self;
  final $Res Function(_LeadDetailDto) _then;

/// Create a copy of LeadDetailDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? partnerName = freezed,Object? phone = freezed,Object? mobile = freezed,Object? emailFrom = freezed,Object? street = freezed,Object? city = freezed,Object? stateId = freezed,Object? countryId = freezed,Object? zip = freezed,Object? description = freezed,Object? stageId = freezed,Object? userId = freezed,Object? teamId = freezed,Object? priority = freezed,Object? createDate = freezed,Object? writeDate = freezed,Object? expectedRevenue = freezed,Object? probability = freezed,Object? tagIds = freezed,}) {
  return _then(_LeadDetailDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,partnerName: freezed == partnerName ? _self.partnerName : partnerName // ignore: cast_nullable_to_non_nullable
as dynamic,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as dynamic,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as dynamic,emailFrom: freezed == emailFrom ? _self.emailFrom : emailFrom // ignore: cast_nullable_to_non_nullable
as dynamic,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as dynamic,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as dynamic,stateId: freezed == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as dynamic,countryId: freezed == countryId ? _self.countryId : countryId // ignore: cast_nullable_to_non_nullable
as dynamic,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as dynamic,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as dynamic,stageId: freezed == stageId ? _self.stageId : stageId // ignore: cast_nullable_to_non_nullable
as dynamic,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as dynamic,teamId: freezed == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as dynamic,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as dynamic,createDate: freezed == createDate ? _self.createDate : createDate // ignore: cast_nullable_to_non_nullable
as dynamic,writeDate: freezed == writeDate ? _self.writeDate : writeDate // ignore: cast_nullable_to_non_nullable
as dynamic,expectedRevenue: freezed == expectedRevenue ? _self.expectedRevenue : expectedRevenue // ignore: cast_nullable_to_non_nullable
as dynamic,probability: freezed == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as dynamic,tagIds: freezed == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
