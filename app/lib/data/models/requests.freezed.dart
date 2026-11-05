// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requests.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaceInput {

 String get placeId; Priority get priority; int get stayMin;
/// Create a copy of PlaceInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceInputCopyWith<PlaceInput> get copyWith => _$PlaceInputCopyWithImpl<PlaceInput>(this as PlaceInput, _$identity);

  /// Serializes this PlaceInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceInput&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.stayMin, _this.stayMin) || other.stayMin == _this.stayMin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceInput;
  return Object.hash(runtimeType,_this.placeId,_this.priority,_this.stayMin);
}

@override
String toString() {
  final _this = this as PlaceInput;
  return 'PlaceInput(placeId: ${_this.placeId}, priority: ${_this.priority}, stayMin: ${_this.stayMin})';
}


}

/// @nodoc
abstract mixin class $PlaceInputCopyWith<$Res>  {
  factory $PlaceInputCopyWith(PlaceInput value, $Res Function(PlaceInput) _then) = _$PlaceInputCopyWithImpl;
@useResult
$Res call({
 String placeId, Priority priority, int stayMin
});




}
/// @nodoc
class _$PlaceInputCopyWithImpl<$Res>
    implements $PlaceInputCopyWith<$Res> {
  _$PlaceInputCopyWithImpl(this._self, this._then);

  final PlaceInput _self;
  final $Res Function(PlaceInput) _then;

/// Create a copy of PlaceInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? priority = null,Object? stayMin = null,}) {
  return _then(PlaceInput(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,stayMin: null == stayMin ? _self.stayMin : stayMin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceInput].
extension PlaceInputPatterns on PlaceInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceInput value)  $default,){
final _that = this;
switch (_that) {
case _PlaceInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceInput value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  Priority priority,  int stayMin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceInput() when $default != null:
return $default(_that.placeId,_that.priority,_that.stayMin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  Priority priority,  int stayMin)  $default,) {final _that = this;
switch (_that) {
case _PlaceInput():
return $default(_that.placeId,_that.priority,_that.stayMin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  Priority priority,  int stayMin)?  $default,) {final _that = this;
switch (_that) {
case _PlaceInput() when $default != null:
return $default(_that.placeId,_that.priority,_that.stayMin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceInput implements PlaceInput {
  const _PlaceInput({required this.placeId, required this.priority, required this.stayMin});
  factory _PlaceInput.fromJson(Map<String, dynamic> json) => _$PlaceInputFromJson(json);

@override final  String placeId;
@override final  Priority priority;
@override final  int stayMin;

/// Create a copy of PlaceInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceInputCopyWith<_PlaceInput> get copyWith => __$PlaceInputCopyWithImpl<_PlaceInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceInput&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.stayMin, stayMin) || other.stayMin == stayMin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,priority,stayMin);
}

@override
String toString() {
    return 'PlaceInput(placeId: $placeId, priority: $priority, stayMin: $stayMin)';
}


}

/// @nodoc
abstract mixin class _$PlaceInputCopyWith<$Res> implements $PlaceInputCopyWith<$Res> {
  factory _$PlaceInputCopyWith(_PlaceInput value, $Res Function(_PlaceInput) _then) = __$PlaceInputCopyWithImpl;
@override @useResult
$Res call({
 String placeId, Priority priority, int stayMin
});




}
/// @nodoc
class __$PlaceInputCopyWithImpl<$Res>
    implements _$PlaceInputCopyWith<$Res> {
  __$PlaceInputCopyWithImpl(this._self, this._then);

  final _PlaceInput _self;
  final $Res Function(_PlaceInput) _then;

/// Create a copy of PlaceInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? priority = null,Object? stayMin = null,}) {
  return _then(_PlaceInput(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,stayMin: null == stayMin ? _self.stayMin : stayMin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StartInput {

 String get placeId;/// 出発時刻（HH:mm）
 String get departAt;
/// Create a copy of StartInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartInputCopyWith<StartInput> get copyWith => _$StartInputCopyWithImpl<StartInput>(this as StartInput, _$identity);

  /// Serializes this StartInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StartInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartInput&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.departAt, _this.departAt) || other.departAt == _this.departAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StartInput;
  return Object.hash(runtimeType,_this.placeId,_this.departAt);
}

@override
String toString() {
  final _this = this as StartInput;
  return 'StartInput(placeId: ${_this.placeId}, departAt: ${_this.departAt})';
}


}

/// @nodoc
abstract mixin class $StartInputCopyWith<$Res>  {
  factory $StartInputCopyWith(StartInput value, $Res Function(StartInput) _then) = _$StartInputCopyWithImpl;
@useResult
$Res call({
 String placeId, String departAt
});




}
/// @nodoc
class _$StartInputCopyWithImpl<$Res>
    implements $StartInputCopyWith<$Res> {
  _$StartInputCopyWithImpl(this._self, this._then);

  final StartInput _self;
  final $Res Function(StartInput) _then;

/// Create a copy of StartInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? departAt = null,}) {
  return _then(StartInput(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StartInput].
extension StartInputPatterns on StartInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartInput value)  $default,){
final _that = this;
switch (_that) {
case _StartInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartInput value)?  $default,){
final _that = this;
switch (_that) {
case _StartInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String departAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartInput() when $default != null:
return $default(_that.placeId,_that.departAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String departAt)  $default,) {final _that = this;
switch (_that) {
case _StartInput():
return $default(_that.placeId,_that.departAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String departAt)?  $default,) {final _that = this;
switch (_that) {
case _StartInput() when $default != null:
return $default(_that.placeId,_that.departAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StartInput implements StartInput {
  const _StartInput({required this.placeId, required this.departAt});
  factory _StartInput.fromJson(Map<String, dynamic> json) => _$StartInputFromJson(json);

@override final  String placeId;
/// 出発時刻（HH:mm）
@override final  String departAt;

/// Create a copy of StartInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartInputCopyWith<_StartInput> get copyWith => __$StartInputCopyWithImpl<_StartInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StartInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartInput&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.departAt, departAt) || other.departAt == departAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,departAt);
}

@override
String toString() {
    return 'StartInput(placeId: $placeId, departAt: $departAt)';
}


}

/// @nodoc
abstract mixin class _$StartInputCopyWith<$Res> implements $StartInputCopyWith<$Res> {
  factory _$StartInputCopyWith(_StartInput value, $Res Function(_StartInput) _then) = __$StartInputCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String departAt
});




}
/// @nodoc
class __$StartInputCopyWithImpl<$Res>
    implements _$StartInputCopyWith<$Res> {
  __$StartInputCopyWithImpl(this._self, this._then);

  final _StartInput _self;
  final $Res Function(_StartInput) _then;

/// Create a copy of StartInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? departAt = null,}) {
  return _then(_StartInput(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateItineraryRequest {

 String get title;/// 旅行日（YYYY-MM-DD）
 String get date; StartInput get start;/// 終わりたい時刻（HH:mm）
 String get endBy; List<PlaceInput> get places;
/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateItineraryRequestCopyWith<CreateItineraryRequest> get copyWith => _$CreateItineraryRequestCopyWithImpl<CreateItineraryRequest>(this as CreateItineraryRequest, _$identity);

  /// Serializes this CreateItineraryRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateItineraryRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateItineraryRequest&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.endBy, _this.endBy) || other.endBy == _this.endBy)&&const DeepCollectionEquality().equals(other.places, _this.places));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateItineraryRequest;
  return Object.hash(runtimeType,_this.title,_this.date,_this.start,_this.endBy,const DeepCollectionEquality().hash(_this.places));
}

@override
String toString() {
  final _this = this as CreateItineraryRequest;
  return 'CreateItineraryRequest(title: ${_this.title}, date: ${_this.date}, start: ${_this.start}, endBy: ${_this.endBy}, places: ${_this.places})';
}


}

/// @nodoc
abstract mixin class $CreateItineraryRequestCopyWith<$Res>  {
  factory $CreateItineraryRequestCopyWith(CreateItineraryRequest value, $Res Function(CreateItineraryRequest) _then) = _$CreateItineraryRequestCopyWithImpl;
@useResult
$Res call({
 String title, String date, StartInput start, String endBy, List<PlaceInput> places
});


$StartInputCopyWith<$Res> get start;

}
/// @nodoc
class _$CreateItineraryRequestCopyWithImpl<$Res>
    implements $CreateItineraryRequestCopyWith<$Res> {
  _$CreateItineraryRequestCopyWithImpl(this._self, this._then);

  final CreateItineraryRequest _self;
  final $Res Function(CreateItineraryRequest) _then;

/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? date = null,Object? start = null,Object? endBy = null,Object? places = null,}) {
  return _then(CreateItineraryRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as StartInput,endBy: null == endBy ? _self.endBy : endBy // ignore: cast_nullable_to_non_nullable
as String,places: null == places ? _self.places : places // ignore: cast_nullable_to_non_nullable
as List<PlaceInput>,
  ));
}
/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StartInputCopyWith<$Res> get start {
  
  return $StartInputCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateItineraryRequest].
extension CreateItineraryRequestPatterns on CreateItineraryRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateItineraryRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateItineraryRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateItineraryRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateItineraryRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateItineraryRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateItineraryRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String date,  StartInput start,  String endBy,  List<PlaceInput> places)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateItineraryRequest() when $default != null:
return $default(_that.title,_that.date,_that.start,_that.endBy,_that.places);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String date,  StartInput start,  String endBy,  List<PlaceInput> places)  $default,) {final _that = this;
switch (_that) {
case _CreateItineraryRequest():
return $default(_that.title,_that.date,_that.start,_that.endBy,_that.places);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String date,  StartInput start,  String endBy,  List<PlaceInput> places)?  $default,) {final _that = this;
switch (_that) {
case _CreateItineraryRequest() when $default != null:
return $default(_that.title,_that.date,_that.start,_that.endBy,_that.places);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateItineraryRequest implements CreateItineraryRequest {
  const _CreateItineraryRequest({required this.title, required this.date, required this.start, required this.endBy, required  List<PlaceInput> places}): _places = places;
  factory _CreateItineraryRequest.fromJson(Map<String, dynamic> json) => _$CreateItineraryRequestFromJson(json);

@override final  String title;
/// 旅行日（YYYY-MM-DD）
@override final  String date;
@override final  StartInput start;
/// 終わりたい時刻（HH:mm）
@override final  String endBy;
 final  List<PlaceInput> _places;
@override List<PlaceInput> get places {
  if (_places is EqualUnmodifiableListView) return _places;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_places);
}


/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateItineraryRequestCopyWith<_CreateItineraryRequest> get copyWith => __$CreateItineraryRequestCopyWithImpl<_CreateItineraryRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateItineraryRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateItineraryRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.start, start) || other.start == start)&&(identical(other.endBy, endBy) || other.endBy == endBy)&&const DeepCollectionEquality().equals(other.places, _places));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,date,start,endBy,const DeepCollectionEquality().hash(_places));
}

@override
String toString() {
    return 'CreateItineraryRequest(title: $title, date: $date, start: $start, endBy: $endBy, places: $places)';
}


}

/// @nodoc
abstract mixin class _$CreateItineraryRequestCopyWith<$Res> implements $CreateItineraryRequestCopyWith<$Res> {
  factory _$CreateItineraryRequestCopyWith(_CreateItineraryRequest value, $Res Function(_CreateItineraryRequest) _then) = __$CreateItineraryRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, String date, StartInput start, String endBy, List<PlaceInput> places
});


@override $StartInputCopyWith<$Res> get start;

}
/// @nodoc
class __$CreateItineraryRequestCopyWithImpl<$Res>
    implements _$CreateItineraryRequestCopyWith<$Res> {
  __$CreateItineraryRequestCopyWithImpl(this._self, this._then);

  final _CreateItineraryRequest _self;
  final $Res Function(_CreateItineraryRequest) _then;

/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? date = null,Object? start = null,Object? endBy = null,Object? places = null,}) {
  return _then(_CreateItineraryRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as StartInput,endBy: null == endBy ? _self.endBy : endBy // ignore: cast_nullable_to_non_nullable
as String,places: null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
as List<PlaceInput>,
  ));
}

/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StartInputCopyWith<$Res> get start {
  
  return $StartInputCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}
}


/// @nodoc
mixin _$UpdatePlacesRequest {

 String? get endBy; List<PlaceInput> get places;
/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePlacesRequestCopyWith<UpdatePlacesRequest> get copyWith => _$UpdatePlacesRequestCopyWithImpl<UpdatePlacesRequest>(this as UpdatePlacesRequest, _$identity);

  /// Serializes this UpdatePlacesRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdatePlacesRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePlacesRequest&&(identical(other.endBy, _this.endBy) || other.endBy == _this.endBy)&&const DeepCollectionEquality().equals(other.places, _this.places));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdatePlacesRequest;
  return Object.hash(runtimeType,_this.endBy,const DeepCollectionEquality().hash(_this.places));
}

@override
String toString() {
  final _this = this as UpdatePlacesRequest;
  return 'UpdatePlacesRequest(endBy: ${_this.endBy}, places: ${_this.places})';
}


}

/// @nodoc
abstract mixin class $UpdatePlacesRequestCopyWith<$Res>  {
  factory $UpdatePlacesRequestCopyWith(UpdatePlacesRequest value, $Res Function(UpdatePlacesRequest) _then) = _$UpdatePlacesRequestCopyWithImpl;
@useResult
$Res call({
 String? endBy, List<PlaceInput> places
});




}
/// @nodoc
class _$UpdatePlacesRequestCopyWithImpl<$Res>
    implements $UpdatePlacesRequestCopyWith<$Res> {
  _$UpdatePlacesRequestCopyWithImpl(this._self, this._then);

  final UpdatePlacesRequest _self;
  final $Res Function(UpdatePlacesRequest) _then;

/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? endBy = freezed,Object? places = null,}) {
  return _then(UpdatePlacesRequest(
endBy: freezed == endBy ? _self.endBy : endBy // ignore: cast_nullable_to_non_nullable
as String?,places: null == places ? _self.places : places // ignore: cast_nullable_to_non_nullable
as List<PlaceInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdatePlacesRequest].
extension UpdatePlacesRequestPatterns on UpdatePlacesRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePlacesRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePlacesRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePlacesRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePlacesRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePlacesRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePlacesRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? endBy,  List<PlaceInput> places)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePlacesRequest() when $default != null:
return $default(_that.endBy,_that.places);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? endBy,  List<PlaceInput> places)  $default,) {final _that = this;
switch (_that) {
case _UpdatePlacesRequest():
return $default(_that.endBy,_that.places);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? endBy,  List<PlaceInput> places)?  $default,) {final _that = this;
switch (_that) {
case _UpdatePlacesRequest() when $default != null:
return $default(_that.endBy,_that.places);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdatePlacesRequest implements UpdatePlacesRequest {
  const _UpdatePlacesRequest({this.endBy, required  List<PlaceInput> places}): _places = places;
  factory _UpdatePlacesRequest.fromJson(Map<String, dynamic> json) => _$UpdatePlacesRequestFromJson(json);

@override final  String? endBy;
 final  List<PlaceInput> _places;
@override List<PlaceInput> get places {
  if (_places is EqualUnmodifiableListView) return _places;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_places);
}


/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePlacesRequestCopyWith<_UpdatePlacesRequest> get copyWith => __$UpdatePlacesRequestCopyWithImpl<_UpdatePlacesRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdatePlacesRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePlacesRequest&&(identical(other.endBy, endBy) || other.endBy == endBy)&&const DeepCollectionEquality().equals(other.places, _places));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,endBy,const DeepCollectionEquality().hash(_places));
}

@override
String toString() {
    return 'UpdatePlacesRequest(endBy: $endBy, places: $places)';
}


}

/// @nodoc
abstract mixin class _$UpdatePlacesRequestCopyWith<$Res> implements $UpdatePlacesRequestCopyWith<$Res> {
  factory _$UpdatePlacesRequestCopyWith(_UpdatePlacesRequest value, $Res Function(_UpdatePlacesRequest) _then) = __$UpdatePlacesRequestCopyWithImpl;
@override @useResult
$Res call({
 String? endBy, List<PlaceInput> places
});




}
/// @nodoc
class __$UpdatePlacesRequestCopyWithImpl<$Res>
    implements _$UpdatePlacesRequestCopyWith<$Res> {
  __$UpdatePlacesRequestCopyWithImpl(this._self, this._then);

  final _UpdatePlacesRequest _self;
  final $Res Function(_UpdatePlacesRequest) _then;

/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? endBy = freezed,Object? places = null,}) {
  return _then(_UpdatePlacesRequest(
endBy: freezed == endBy ? _self.endBy : endBy // ignore: cast_nullable_to_non_nullable
as String?,places: null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
as List<PlaceInput>,
  ));
}


}


/// @nodoc
mixin _$ReplanRequest {

 String? get currentItemId; int? get delayMin; DateTime? get now;
/// Create a copy of ReplanRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplanRequestCopyWith<ReplanRequest> get copyWith => _$ReplanRequestCopyWithImpl<ReplanRequest>(this as ReplanRequest, _$identity);

  /// Serializes this ReplanRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReplanRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplanRequest&&(identical(other.currentItemId, _this.currentItemId) || other.currentItemId == _this.currentItemId)&&(identical(other.delayMin, _this.delayMin) || other.delayMin == _this.delayMin)&&(identical(other.now, _this.now) || other.now == _this.now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReplanRequest;
  return Object.hash(runtimeType,_this.currentItemId,_this.delayMin,_this.now);
}

@override
String toString() {
  final _this = this as ReplanRequest;
  return 'ReplanRequest(currentItemId: ${_this.currentItemId}, delayMin: ${_this.delayMin}, now: ${_this.now})';
}


}

/// @nodoc
abstract mixin class $ReplanRequestCopyWith<$Res>  {
  factory $ReplanRequestCopyWith(ReplanRequest value, $Res Function(ReplanRequest) _then) = _$ReplanRequestCopyWithImpl;
@useResult
$Res call({
 String? currentItemId, int? delayMin, DateTime? now
});




}
/// @nodoc
class _$ReplanRequestCopyWithImpl<$Res>
    implements $ReplanRequestCopyWith<$Res> {
  _$ReplanRequestCopyWithImpl(this._self, this._then);

  final ReplanRequest _self;
  final $Res Function(ReplanRequest) _then;

/// Create a copy of ReplanRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentItemId = freezed,Object? delayMin = freezed,Object? now = freezed,}) {
  return _then(ReplanRequest(
currentItemId: freezed == currentItemId ? _self.currentItemId : currentItemId // ignore: cast_nullable_to_non_nullable
as String?,delayMin: freezed == delayMin ? _self.delayMin : delayMin // ignore: cast_nullable_to_non_nullable
as int?,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplanRequest].
extension ReplanRequestPatterns on ReplanRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplanRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplanRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplanRequest value)  $default,){
final _that = this;
switch (_that) {
case _ReplanRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplanRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ReplanRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? currentItemId,  int? delayMin,  DateTime? now)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplanRequest() when $default != null:
return $default(_that.currentItemId,_that.delayMin,_that.now);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? currentItemId,  int? delayMin,  DateTime? now)  $default,) {final _that = this;
switch (_that) {
case _ReplanRequest():
return $default(_that.currentItemId,_that.delayMin,_that.now);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? currentItemId,  int? delayMin,  DateTime? now)?  $default,) {final _that = this;
switch (_that) {
case _ReplanRequest() when $default != null:
return $default(_that.currentItemId,_that.delayMin,_that.now);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplanRequest implements ReplanRequest {
  const _ReplanRequest({this.currentItemId, this.delayMin, this.now}): assert((delayMin == null) != (now == null), 'delayMin か now のどちらか一方を指定する');
  factory _ReplanRequest.fromJson(Map<String, dynamic> json) => _$ReplanRequestFromJson(json);

@override final  String? currentItemId;
@override final  int? delayMin;
@override final  DateTime? now;

/// Create a copy of ReplanRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplanRequestCopyWith<_ReplanRequest> get copyWith => __$ReplanRequestCopyWithImpl<_ReplanRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplanRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplanRequest&&(identical(other.currentItemId, currentItemId) || other.currentItemId == currentItemId)&&(identical(other.delayMin, delayMin) || other.delayMin == delayMin)&&(identical(other.now, now) || other.now == now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currentItemId,delayMin,now);
}

@override
String toString() {
    return 'ReplanRequest(currentItemId: $currentItemId, delayMin: $delayMin, now: $now)';
}


}

/// @nodoc
abstract mixin class _$ReplanRequestCopyWith<$Res> implements $ReplanRequestCopyWith<$Res> {
  factory _$ReplanRequestCopyWith(_ReplanRequest value, $Res Function(_ReplanRequest) _then) = __$ReplanRequestCopyWithImpl;
@override @useResult
$Res call({
 String? currentItemId, int? delayMin, DateTime? now
});




}
/// @nodoc
class __$ReplanRequestCopyWithImpl<$Res>
    implements _$ReplanRequestCopyWith<$Res> {
  __$ReplanRequestCopyWithImpl(this._self, this._then);

  final _ReplanRequest _self;
  final $Res Function(_ReplanRequest) _then;

/// Create a copy of ReplanRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentItemId = freezed,Object? delayMin = freezed,Object? now = freezed,}) {
  return _then(_ReplanRequest(
currentItemId: freezed == currentItemId ? _self.currentItemId : currentItemId // ignore: cast_nullable_to_non_nullable
as String?,delayMin: freezed == delayMin ? _self.delayMin : delayMin // ignore: cast_nullable_to_non_nullable
as int?,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$AddItemRequest {

 String get placeId; int get stayMin; Priority get priority; String? get insertAfterItemId;
/// Create a copy of AddItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddItemRequestCopyWith<AddItemRequest> get copyWith => _$AddItemRequestCopyWithImpl<AddItemRequest>(this as AddItemRequest, _$identity);

  /// Serializes this AddItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AddItemRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddItemRequest&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.stayMin, _this.stayMin) || other.stayMin == _this.stayMin)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.insertAfterItemId, _this.insertAfterItemId) || other.insertAfterItemId == _this.insertAfterItemId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AddItemRequest;
  return Object.hash(runtimeType,_this.placeId,_this.stayMin,_this.priority,_this.insertAfterItemId);
}

@override
String toString() {
  final _this = this as AddItemRequest;
  return 'AddItemRequest(placeId: ${_this.placeId}, stayMin: ${_this.stayMin}, priority: ${_this.priority}, insertAfterItemId: ${_this.insertAfterItemId})';
}


}

/// @nodoc
abstract mixin class $AddItemRequestCopyWith<$Res>  {
  factory $AddItemRequestCopyWith(AddItemRequest value, $Res Function(AddItemRequest) _then) = _$AddItemRequestCopyWithImpl;
@useResult
$Res call({
 String placeId, int stayMin, Priority priority, String? insertAfterItemId
});




}
/// @nodoc
class _$AddItemRequestCopyWithImpl<$Res>
    implements $AddItemRequestCopyWith<$Res> {
  _$AddItemRequestCopyWithImpl(this._self, this._then);

  final AddItemRequest _self;
  final $Res Function(AddItemRequest) _then;

/// Create a copy of AddItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? stayMin = null,Object? priority = null,Object? insertAfterItemId = freezed,}) {
  return _then(AddItemRequest(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,stayMin: null == stayMin ? _self.stayMin : stayMin // ignore: cast_nullable_to_non_nullable
as int,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,insertAfterItemId: freezed == insertAfterItemId ? _self.insertAfterItemId : insertAfterItemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddItemRequest].
extension AddItemRequestPatterns on AddItemRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddItemRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _AddItemRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AddItemRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  int stayMin,  Priority priority,  String? insertAfterItemId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddItemRequest() when $default != null:
return $default(_that.placeId,_that.stayMin,_that.priority,_that.insertAfterItemId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  int stayMin,  Priority priority,  String? insertAfterItemId)  $default,) {final _that = this;
switch (_that) {
case _AddItemRequest():
return $default(_that.placeId,_that.stayMin,_that.priority,_that.insertAfterItemId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  int stayMin,  Priority priority,  String? insertAfterItemId)?  $default,) {final _that = this;
switch (_that) {
case _AddItemRequest() when $default != null:
return $default(_that.placeId,_that.stayMin,_that.priority,_that.insertAfterItemId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddItemRequest implements AddItemRequest {
  const _AddItemRequest({required this.placeId, required this.stayMin, this.priority = Priority.optional, this.insertAfterItemId});
  factory _AddItemRequest.fromJson(Map<String, dynamic> json) => _$AddItemRequestFromJson(json);

@override final  String placeId;
@override final  int stayMin;
@override@JsonKey() final  Priority priority;
@override final  String? insertAfterItemId;

/// Create a copy of AddItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddItemRequestCopyWith<_AddItemRequest> get copyWith => __$AddItemRequestCopyWithImpl<_AddItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddItemRequest&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.stayMin, stayMin) || other.stayMin == stayMin)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.insertAfterItemId, insertAfterItemId) || other.insertAfterItemId == insertAfterItemId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,stayMin,priority,insertAfterItemId);
}

@override
String toString() {
    return 'AddItemRequest(placeId: $placeId, stayMin: $stayMin, priority: $priority, insertAfterItemId: $insertAfterItemId)';
}


}

/// @nodoc
abstract mixin class _$AddItemRequestCopyWith<$Res> implements $AddItemRequestCopyWith<$Res> {
  factory _$AddItemRequestCopyWith(_AddItemRequest value, $Res Function(_AddItemRequest) _then) = __$AddItemRequestCopyWithImpl;
@override @useResult
$Res call({
 String placeId, int stayMin, Priority priority, String? insertAfterItemId
});




}
/// @nodoc
class __$AddItemRequestCopyWithImpl<$Res>
    implements _$AddItemRequestCopyWith<$Res> {
  __$AddItemRequestCopyWithImpl(this._self, this._then);

  final _AddItemRequest _self;
  final $Res Function(_AddItemRequest) _then;

/// Create a copy of AddItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? stayMin = null,Object? priority = null,Object? insertAfterItemId = freezed,}) {
  return _then(_AddItemRequest(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,stayMin: null == stayMin ? _self.stayMin : stayMin // ignore: cast_nullable_to_non_nullable
as int,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,insertAfterItemId: freezed == insertAfterItemId ? _self.insertAfterItemId : insertAfterItemId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
