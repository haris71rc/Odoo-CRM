// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chatter_message_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatterMessageEntity {

 int get id; NamedRefEntity? get author; String? get emailFrom; String? get body; DateTime? get date; String? get messageType; NamedRefEntity? get subtype; String? get subtypeDescription; bool get isNote; bool get isDiscussion; List<TrackingValueEntity> get trackingValues;
/// Create a copy of ChatterMessageEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatterMessageEntityCopyWith<ChatterMessageEntity> get copyWith => _$ChatterMessageEntityCopyWithImpl<ChatterMessageEntity>(this as ChatterMessageEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatterMessageEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.emailFrom, emailFrom) || other.emailFrom == emailFrom)&&(identical(other.body, body) || other.body == body)&&(identical(other.date, date) || other.date == date)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.subtype, subtype) || other.subtype == subtype)&&(identical(other.subtypeDescription, subtypeDescription) || other.subtypeDescription == subtypeDescription)&&(identical(other.isNote, isNote) || other.isNote == isNote)&&(identical(other.isDiscussion, isDiscussion) || other.isDiscussion == isDiscussion)&&const DeepCollectionEquality().equals(other.trackingValues, trackingValues));
}


@override
int get hashCode => Object.hash(runtimeType,id,author,emailFrom,body,date,messageType,subtype,subtypeDescription,isNote,isDiscussion,const DeepCollectionEquality().hash(trackingValues));

@override
String toString() {
  return 'ChatterMessageEntity(id: $id, author: $author, emailFrom: $emailFrom, body: $body, date: $date, messageType: $messageType, subtype: $subtype, subtypeDescription: $subtypeDescription, isNote: $isNote, isDiscussion: $isDiscussion, trackingValues: $trackingValues)';
}


}

/// @nodoc
abstract mixin class $ChatterMessageEntityCopyWith<$Res>  {
  factory $ChatterMessageEntityCopyWith(ChatterMessageEntity value, $Res Function(ChatterMessageEntity) _then) = _$ChatterMessageEntityCopyWithImpl;
@useResult
$Res call({
 int id, NamedRefEntity? author, String? emailFrom, String? body, DateTime? date, String? messageType, NamedRefEntity? subtype, String? subtypeDescription, bool isNote, bool isDiscussion, List<TrackingValueEntity> trackingValues
});


$NamedRefEntityCopyWith<$Res>? get author;$NamedRefEntityCopyWith<$Res>? get subtype;

}
/// @nodoc
class _$ChatterMessageEntityCopyWithImpl<$Res>
    implements $ChatterMessageEntityCopyWith<$Res> {
  _$ChatterMessageEntityCopyWithImpl(this._self, this._then);

  final ChatterMessageEntity _self;
  final $Res Function(ChatterMessageEntity) _then;

/// Create a copy of ChatterMessageEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = freezed,Object? emailFrom = freezed,Object? body = freezed,Object? date = freezed,Object? messageType = freezed,Object? subtype = freezed,Object? subtypeDescription = freezed,Object? isNote = null,Object? isDiscussion = null,Object? trackingValues = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,emailFrom: freezed == emailFrom ? _self.emailFrom : emailFrom // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,messageType: freezed == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String?,subtype: freezed == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,subtypeDescription: freezed == subtypeDescription ? _self.subtypeDescription : subtypeDescription // ignore: cast_nullable_to_non_nullable
as String?,isNote: null == isNote ? _self.isNote : isNote // ignore: cast_nullable_to_non_nullable
as bool,isDiscussion: null == isDiscussion ? _self.isDiscussion : isDiscussion // ignore: cast_nullable_to_non_nullable
as bool,trackingValues: null == trackingValues ? _self.trackingValues : trackingValues // ignore: cast_nullable_to_non_nullable
as List<TrackingValueEntity>,
  ));
}
/// Create a copy of ChatterMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of ChatterMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get subtype {
    if (_self.subtype == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.subtype!, (value) {
    return _then(_self.copyWith(subtype: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatterMessageEntity].
extension ChatterMessageEntityPatterns on ChatterMessageEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatterMessageEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatterMessageEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatterMessageEntity value)  $default,){
final _that = this;
switch (_that) {
case _ChatterMessageEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatterMessageEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ChatterMessageEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  NamedRefEntity? author,  String? emailFrom,  String? body,  DateTime? date,  String? messageType,  NamedRefEntity? subtype,  String? subtypeDescription,  bool isNote,  bool isDiscussion,  List<TrackingValueEntity> trackingValues)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatterMessageEntity() when $default != null:
return $default(_that.id,_that.author,_that.emailFrom,_that.body,_that.date,_that.messageType,_that.subtype,_that.subtypeDescription,_that.isNote,_that.isDiscussion,_that.trackingValues);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  NamedRefEntity? author,  String? emailFrom,  String? body,  DateTime? date,  String? messageType,  NamedRefEntity? subtype,  String? subtypeDescription,  bool isNote,  bool isDiscussion,  List<TrackingValueEntity> trackingValues)  $default,) {final _that = this;
switch (_that) {
case _ChatterMessageEntity():
return $default(_that.id,_that.author,_that.emailFrom,_that.body,_that.date,_that.messageType,_that.subtype,_that.subtypeDescription,_that.isNote,_that.isDiscussion,_that.trackingValues);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  NamedRefEntity? author,  String? emailFrom,  String? body,  DateTime? date,  String? messageType,  NamedRefEntity? subtype,  String? subtypeDescription,  bool isNote,  bool isDiscussion,  List<TrackingValueEntity> trackingValues)?  $default,) {final _that = this;
switch (_that) {
case _ChatterMessageEntity() when $default != null:
return $default(_that.id,_that.author,_that.emailFrom,_that.body,_that.date,_that.messageType,_that.subtype,_that.subtypeDescription,_that.isNote,_that.isDiscussion,_that.trackingValues);case _:
  return null;

}
}

}

/// @nodoc


class _ChatterMessageEntity extends ChatterMessageEntity {
  const _ChatterMessageEntity({required this.id, this.author, this.emailFrom, this.body, this.date, this.messageType, this.subtype, this.subtypeDescription, this.isNote = false, this.isDiscussion = false, final  List<TrackingValueEntity> trackingValues = const []}): _trackingValues = trackingValues,super._();
  

@override final  int id;
@override final  NamedRefEntity? author;
@override final  String? emailFrom;
@override final  String? body;
@override final  DateTime? date;
@override final  String? messageType;
@override final  NamedRefEntity? subtype;
@override final  String? subtypeDescription;
@override@JsonKey() final  bool isNote;
@override@JsonKey() final  bool isDiscussion;
 final  List<TrackingValueEntity> _trackingValues;
@override@JsonKey() List<TrackingValueEntity> get trackingValues {
  if (_trackingValues is EqualUnmodifiableListView) return _trackingValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trackingValues);
}


/// Create a copy of ChatterMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatterMessageEntityCopyWith<_ChatterMessageEntity> get copyWith => __$ChatterMessageEntityCopyWithImpl<_ChatterMessageEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatterMessageEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.emailFrom, emailFrom) || other.emailFrom == emailFrom)&&(identical(other.body, body) || other.body == body)&&(identical(other.date, date) || other.date == date)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.subtype, subtype) || other.subtype == subtype)&&(identical(other.subtypeDescription, subtypeDescription) || other.subtypeDescription == subtypeDescription)&&(identical(other.isNote, isNote) || other.isNote == isNote)&&(identical(other.isDiscussion, isDiscussion) || other.isDiscussion == isDiscussion)&&const DeepCollectionEquality().equals(other._trackingValues, _trackingValues));
}


@override
int get hashCode => Object.hash(runtimeType,id,author,emailFrom,body,date,messageType,subtype,subtypeDescription,isNote,isDiscussion,const DeepCollectionEquality().hash(_trackingValues));

@override
String toString() {
  return 'ChatterMessageEntity(id: $id, author: $author, emailFrom: $emailFrom, body: $body, date: $date, messageType: $messageType, subtype: $subtype, subtypeDescription: $subtypeDescription, isNote: $isNote, isDiscussion: $isDiscussion, trackingValues: $trackingValues)';
}


}

/// @nodoc
abstract mixin class _$ChatterMessageEntityCopyWith<$Res> implements $ChatterMessageEntityCopyWith<$Res> {
  factory _$ChatterMessageEntityCopyWith(_ChatterMessageEntity value, $Res Function(_ChatterMessageEntity) _then) = __$ChatterMessageEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, NamedRefEntity? author, String? emailFrom, String? body, DateTime? date, String? messageType, NamedRefEntity? subtype, String? subtypeDescription, bool isNote, bool isDiscussion, List<TrackingValueEntity> trackingValues
});


@override $NamedRefEntityCopyWith<$Res>? get author;@override $NamedRefEntityCopyWith<$Res>? get subtype;

}
/// @nodoc
class __$ChatterMessageEntityCopyWithImpl<$Res>
    implements _$ChatterMessageEntityCopyWith<$Res> {
  __$ChatterMessageEntityCopyWithImpl(this._self, this._then);

  final _ChatterMessageEntity _self;
  final $Res Function(_ChatterMessageEntity) _then;

/// Create a copy of ChatterMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = freezed,Object? emailFrom = freezed,Object? body = freezed,Object? date = freezed,Object? messageType = freezed,Object? subtype = freezed,Object? subtypeDescription = freezed,Object? isNote = null,Object? isDiscussion = null,Object? trackingValues = null,}) {
  return _then(_ChatterMessageEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,emailFrom: freezed == emailFrom ? _self.emailFrom : emailFrom // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,messageType: freezed == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String?,subtype: freezed == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as NamedRefEntity?,subtypeDescription: freezed == subtypeDescription ? _self.subtypeDescription : subtypeDescription // ignore: cast_nullable_to_non_nullable
as String?,isNote: null == isNote ? _self.isNote : isNote // ignore: cast_nullable_to_non_nullable
as bool,isDiscussion: null == isDiscussion ? _self.isDiscussion : isDiscussion // ignore: cast_nullable_to_non_nullable
as bool,trackingValues: null == trackingValues ? _self._trackingValues : trackingValues // ignore: cast_nullable_to_non_nullable
as List<TrackingValueEntity>,
  ));
}

/// Create a copy of ChatterMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of ChatterMessageEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NamedRefEntityCopyWith<$Res>? get subtype {
    if (_self.subtype == null) {
    return null;
  }

  return $NamedRefEntityCopyWith<$Res>(_self.subtype!, (value) {
    return _then(_self.copyWith(subtype: value));
  });
}
}

// dart format on
