// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_detail_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LeadDetailEntity {

 int get id; String get name; String? get partnerName; String? get phone; String? get mobile; String? get email; String? get street; String? get city; NamedRefEntity? get state; NamedRefEntity? get country; String? get zip; String? get description; NamedRefEntity? get stage; NamedRefEntity? get assignedUser; NamedRefEntity? get team; String? get priority; DateTime? get createdDate; DateTime? get writeDate; double? get expectedRevenue; double? get probability; List<int> get tagIds;
/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadDetailEntityCopyWith<LeadDetailEntity> get copyWith => _$LeadDetailEntityCopyWithImpl<LeadDetailEntity>(this as LeadDetailEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeadDetailEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.partnerName, partnerName) || other.partnerName == partnerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.email, email) || other.email == email)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.description, description) || other.description == description)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.assignedUser, assignedUser) || other.assignedUser == assignedUser)&&(identical(other.team, team) || other.team == team)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.writeDate, writeDate) || other.writeDate == writeDate)&&(identical(other.expectedRevenue, expectedRevenue) || other.expectedRevenue == expectedRevenue)&&(identical(other.probability, probability) || other.probability == probability)&&const DeepCollectionEquality().equals(other.tagIds, tagIds));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,partnerName,phone,mobile,email,street,city,state,country,zip,description,stage,assignedUser,team,priority,createdDate,writeDate,expectedRevenue,probability,const DeepCollectionEquality().hash(tagIds)]);

@override
String toString() {
  return 'LeadDetailEntity(id: $id, name: $name, partnerName: $partnerName, phone: $phone, mobile: $mobile, email: $email, street: $street, city: $city, state: $state, country: $country, zip: $zip, description: $description, stage: $stage, assignedUser: $assignedUser, team: $team, priority: $priority, createdDate: $createdDate, writeDate: $writeDate, expectedRevenue: $expectedRevenue, probability: $probability, tagIds: $tagIds)';
}


}

/// @nodoc
abstract mixin class $LeadDetailEntityCopyWith<$Res>  {
  factory $LeadDetailEntityCopyWith(LeadDetailEntity value, $Res Function(LeadDetailEntity) _then) = _$LeadDetailEntityCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? partnerName, String? phone, String? mobile, String? email, String? street, String? city, NamedRefEntity? state, NamedRefEntity? country, String? zip, String? description, NamedRefEntity? stage, NamedRefEntity? assignedUser, NamedRefEntity? team, String? priority, DateTime? createdDate, DateTime? writeDate, double? expectedRevenue, double? probability, List<int> tagIds
});


$NamedRefEntityCopyWith<$Res>? get state;$NamedRefEntityCopyWith<$Res>? get country;$NamedRefEntityCopyWith<$Res>? get stage;$NamedRefEntityCopyWith<$Res>? get assignedUser;$NamedRefEntityCopyWith<$Res>? get team;

}
/// @nodoc
class _$LeadDetailEntityCopyWithImpl<$Res>
    implements $LeadDetailEntityCopyWith<$Res> {
  _$LeadDetailEntityCopyWithImpl(this._self, this._then);

  final LeadDetailEntity _self;
  final $Res Function(LeadDetailEntity) _then;

/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? partnerName = freezed,Object? phone = freezed,Object? mobile = freezed,Object? email = freezed,Object? street = freezed,Object? city = freezed,Object? state = freezed,Object? country = freezed,Object? zip = freezed,Object? description = freezed,Object? stage = freezed,Object? assignedUser = freezed,Object? team = freezed,Object? priority = freezed,Object? createdDate = freezed,Object? writeDate = freezed,Object? expectedRevenue = freezed,Object? probability = freezed,Object? tagIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,partnerName: freezed == partnerName ? _self.partnerName : partnerName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,assignedUser: freezed == assignedUser ? _self.assignedUser : assignedUser // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,createdDate: freezed == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime?,writeDate: freezed == writeDate ? _self.writeDate : writeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedRevenue: freezed == expectedRevenue ? _self.expectedRevenue : expectedRevenue // ignore: cast_nullable_to_non_nullable
as double?,probability: freezed == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double?,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}
/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get state {
    if (_self.state == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.state!, (value) {
    return _then(_self.copyWith(state: value));
  });
}/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get country {
    if (_self.country == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.country!, (value) {
    return _then(_self.copyWith(country: value));
  });
}/// Create a copy of LeadDetailEntity
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
}/// Create a copy of LeadDetailEntity
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
}/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get team {
    if (_self.team == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.team!, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeadDetailEntity].
extension LeadDetailEntityPatterns on LeadDetailEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeadDetailEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeadDetailEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeadDetailEntity value)  $default,){
final _that = this;
switch (_that) {
case _LeadDetailEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeadDetailEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LeadDetailEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? partnerName,  String? phone,  String? mobile,  String? email,  String? street,  String? city,  NamedRefEntity? state,  NamedRefEntity? country,  String? zip,  String? description,  NamedRefEntity? stage,  NamedRefEntity? assignedUser,  NamedRefEntity? team,  String? priority,  DateTime? createdDate,  DateTime? writeDate,  double? expectedRevenue,  double? probability,  List<int> tagIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeadDetailEntity() when $default != null:
return $default(_that.id,_that.name,_that.partnerName,_that.phone,_that.mobile,_that.email,_that.street,_that.city,_that.state,_that.country,_that.zip,_that.description,_that.stage,_that.assignedUser,_that.team,_that.priority,_that.createdDate,_that.writeDate,_that.expectedRevenue,_that.probability,_that.tagIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? partnerName,  String? phone,  String? mobile,  String? email,  String? street,  String? city,  NamedRefEntity? state,  NamedRefEntity? country,  String? zip,  String? description,  NamedRefEntity? stage,  NamedRefEntity? assignedUser,  NamedRefEntity? team,  String? priority,  DateTime? createdDate,  DateTime? writeDate,  double? expectedRevenue,  double? probability,  List<int> tagIds)  $default,) {final _that = this;
switch (_that) {
case _LeadDetailEntity():
return $default(_that.id,_that.name,_that.partnerName,_that.phone,_that.mobile,_that.email,_that.street,_that.city,_that.state,_that.country,_that.zip,_that.description,_that.stage,_that.assignedUser,_that.team,_that.priority,_that.createdDate,_that.writeDate,_that.expectedRevenue,_that.probability,_that.tagIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? partnerName,  String? phone,  String? mobile,  String? email,  String? street,  String? city,  NamedRefEntity? state,  NamedRefEntity? country,  String? zip,  String? description,  NamedRefEntity? stage,  NamedRefEntity? assignedUser,  NamedRefEntity? team,  String? priority,  DateTime? createdDate,  DateTime? writeDate,  double? expectedRevenue,  double? probability,  List<int> tagIds)?  $default,) {final _that = this;
switch (_that) {
case _LeadDetailEntity() when $default != null:
return $default(_that.id,_that.name,_that.partnerName,_that.phone,_that.mobile,_that.email,_that.street,_that.city,_that.state,_that.country,_that.zip,_that.description,_that.stage,_that.assignedUser,_that.team,_that.priority,_that.createdDate,_that.writeDate,_that.expectedRevenue,_that.probability,_that.tagIds);case _:
  return null;

}
}

}

/// @nodoc


class _LeadDetailEntity implements LeadDetailEntity {
  const _LeadDetailEntity({required this.id, required this.name, this.partnerName, this.phone, this.mobile, this.email, this.street, this.city, this.state, this.country, this.zip, this.description, this.stage, this.assignedUser, this.team, this.priority, this.createdDate, this.writeDate, this.expectedRevenue, this.probability, final  List<int> tagIds = const []}): _tagIds = tagIds;
  

@override final  int id;
@override final  String name;
@override final  String? partnerName;
@override final  String? phone;
@override final  String? mobile;
@override final  String? email;
@override final  String? street;
@override final  String? city;
@override final  NamedRefEntity? state;
@override final  NamedRefEntity? country;
@override final  String? zip;
@override final  String? description;
@override final  NamedRefEntity? stage;
@override final  NamedRefEntity? assignedUser;
@override final  NamedRefEntity? team;
@override final  String? priority;
@override final  DateTime? createdDate;
@override final  DateTime? writeDate;
@override final  double? expectedRevenue;
@override final  double? probability;
 final  List<int> _tagIds;
@override@JsonKey() List<int> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}


/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadDetailEntityCopyWith<_LeadDetailEntity> get copyWith => __$LeadDetailEntityCopyWithImpl<_LeadDetailEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeadDetailEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.partnerName, partnerName) || other.partnerName == partnerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.email, email) || other.email == email)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.zip, zip) || other.zip == zip)&&(identical(other.description, description) || other.description == description)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.assignedUser, assignedUser) || other.assignedUser == assignedUser)&&(identical(other.team, team) || other.team == team)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.writeDate, writeDate) || other.writeDate == writeDate)&&(identical(other.expectedRevenue, expectedRevenue) || other.expectedRevenue == expectedRevenue)&&(identical(other.probability, probability) || other.probability == probability)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,partnerName,phone,mobile,email,street,city,state,country,zip,description,stage,assignedUser,team,priority,createdDate,writeDate,expectedRevenue,probability,const DeepCollectionEquality().hash(_tagIds)]);

@override
String toString() {
  return 'LeadDetailEntity(id: $id, name: $name, partnerName: $partnerName, phone: $phone, mobile: $mobile, email: $email, street: $street, city: $city, state: $state, country: $country, zip: $zip, description: $description, stage: $stage, assignedUser: $assignedUser, team: $team, priority: $priority, createdDate: $createdDate, writeDate: $writeDate, expectedRevenue: $expectedRevenue, probability: $probability, tagIds: $tagIds)';
}


}

/// @nodoc
abstract mixin class _$LeadDetailEntityCopyWith<$Res> implements $LeadDetailEntityCopyWith<$Res> {
  factory _$LeadDetailEntityCopyWith(_LeadDetailEntity value, $Res Function(_LeadDetailEntity) _then) = __$LeadDetailEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? partnerName, String? phone, String? mobile, String? email, String? street, String? city, NamedRefEntity? state, NamedRefEntity? country, String? zip, String? description, NamedRefEntity? stage, NamedRefEntity? assignedUser, NamedRefEntity? team, String? priority, DateTime? createdDate, DateTime? writeDate, double? expectedRevenue, double? probability, List<int> tagIds
});


@override $NamedRefEntityCopyWith<$Res>? get state;@override $NamedRefEntityCopyWith<$Res>? get country;@override $NamedRefEntityCopyWith<$Res>? get stage;@override $NamedRefEntityCopyWith<$Res>? get assignedUser;@override $NamedRefEntityCopyWith<$Res>? get team;

}
/// @nodoc
class __$LeadDetailEntityCopyWithImpl<$Res>
    implements _$LeadDetailEntityCopyWith<$Res> {
  __$LeadDetailEntityCopyWithImpl(this._self, this._then);

  final _LeadDetailEntity _self;
  final $Res Function(_LeadDetailEntity) _then;

/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? partnerName = freezed,Object? phone = freezed,Object? mobile = freezed,Object? email = freezed,Object? street = freezed,Object? city = freezed,Object? state = freezed,Object? country = freezed,Object? zip = freezed,Object? description = freezed,Object? stage = freezed,Object? assignedUser = freezed,Object? team = freezed,Object? priority = freezed,Object? createdDate = freezed,Object? writeDate = freezed,Object? expectedRevenue = freezed,Object? probability = freezed,Object? tagIds = null,}) {
  return _then(_LeadDetailEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,partnerName: freezed == partnerName ? _self.partnerName : partnerName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,zip: freezed == zip ? _self.zip : zip // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,assignedUser: freezed == assignedUser ? _self.assignedUser : assignedUser // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,team: freezed == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,createdDate: freezed == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as DateTime?,writeDate: freezed == writeDate ? _self.writeDate : writeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedRevenue: freezed == expectedRevenue ? _self.expectedRevenue : expectedRevenue // ignore: cast_nullable_to_non_nullable
as double?,probability: freezed == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double?,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get state {
    if (_self.state == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.state!, (value) {
    return _then(_self.copyWith(state: value));
  });
}/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get country {
    if (_self.country == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.country!, (value) {
    return _then(_self.copyWith(country: value));
  });
}/// Create a copy of LeadDetailEntity
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
}/// Create a copy of LeadDetailEntity
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
}/// Create a copy of LeadDetailEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get team {
    if (_self.team == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.team!, (value) {
    return _then(_self.copyWith(team: value));
  });
}
}

// dart format on
