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

 String? get placeId; LatLng? get location; String? get name;/// 出発時刻（HH:mm）
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartInput&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.departAt, _this.departAt) || other.departAt == _this.departAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StartInput;
  return Object.hash(runtimeType,_this.placeId,_this.location,_this.name,_this.departAt);
}

@override
String toString() {
  final _this = this as StartInput;
  return 'StartInput(placeId: ${_this.placeId}, location: ${_this.location}, name: ${_this.name}, departAt: ${_this.departAt})';
}


}

/// @nodoc
abstract mixin class $StartInputCopyWith<$Res>  {
  factory $StartInputCopyWith(StartInput value, $Res Function(StartInput) _then) = _$StartInputCopyWithImpl;
@useResult
$Res call({
 String? placeId, LatLng? location, String? name, String departAt
});


$LatLngCopyWith<$Res>? get location;

}
/// @nodoc
class _$StartInputCopyWithImpl<$Res>
    implements $StartInputCopyWith<$Res> {
  _$StartInputCopyWithImpl(this._self, this._then);

  final StartInput _self;
  final $Res Function(StartInput) _then;

/// Create a copy of StartInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = freezed,Object? location = freezed,Object? name = freezed,Object? departAt = null,}) {
  return _then(StartInput(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of StartInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatLngCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LatLngCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? placeId,  LatLng? location,  String? name,  String departAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartInput() when $default != null:
return $default(_that.placeId,_that.location,_that.name,_that.departAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? placeId,  LatLng? location,  String? name,  String departAt)  $default,) {final _that = this;
switch (_that) {
case _StartInput():
return $default(_that.placeId,_that.location,_that.name,_that.departAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? placeId,  LatLng? location,  String? name,  String departAt)?  $default,) {final _that = this;
switch (_that) {
case _StartInput() when $default != null:
return $default(_that.placeId,_that.location,_that.name,_that.departAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StartInput implements StartInput {
  const _StartInput({this.placeId, this.location, this.name, required this.departAt}): assert(placeId != null || (location != null && name != null), 'placeId か location と name のどちらかを指定する');
  factory _StartInput.fromJson(Map<String, dynamic> json) => _$StartInputFromJson(json);

@override final  String? placeId;
@override final  LatLng? location;
@override final  String? name;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartInput&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.location, location) || other.location == location)&&(identical(other.name, name) || other.name == name)&&(identical(other.departAt, departAt) || other.departAt == departAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,location,name,departAt);
}

@override
String toString() {
    return 'StartInput(placeId: $placeId, location: $location, name: $name, departAt: $departAt)';
}


}

/// @nodoc
abstract mixin class _$StartInputCopyWith<$Res> implements $StartInputCopyWith<$Res> {
  factory _$StartInputCopyWith(_StartInput value, $Res Function(_StartInput) _then) = __$StartInputCopyWithImpl;
@override @useResult
$Res call({
 String? placeId, LatLng? location, String? name, String departAt
});


@override $LatLngCopyWith<$Res>? get location;

}
/// @nodoc
class __$StartInputCopyWithImpl<$Res>
    implements _$StartInputCopyWith<$Res> {
  __$StartInputCopyWithImpl(this._self, this._then);

  final _StartInput _self;
  final $Res Function(_StartInput) _then;

/// Create a copy of StartInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = freezed,Object? location = freezed,Object? name = freezed,Object? departAt = null,}) {
  return _then(_StartInput(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of StartInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatLngCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LatLngCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$EndInput {

 String? get placeId; LatLng? get location; String? get name;/// 終わる場所に着きたい時刻（HH:mm）。終わる場所への移動も含めて判定される
 String get arriveBy;
/// Create a copy of EndInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EndInputCopyWith<EndInput> get copyWith => _$EndInputCopyWithImpl<EndInput>(this as EndInput, _$identity);

  /// Serializes this EndInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EndInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EndInput&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.arriveBy, _this.arriveBy) || other.arriveBy == _this.arriveBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EndInput;
  return Object.hash(runtimeType,_this.placeId,_this.location,_this.name,_this.arriveBy);
}

@override
String toString() {
  final _this = this as EndInput;
  return 'EndInput(placeId: ${_this.placeId}, location: ${_this.location}, name: ${_this.name}, arriveBy: ${_this.arriveBy})';
}


}

/// @nodoc
abstract mixin class $EndInputCopyWith<$Res>  {
  factory $EndInputCopyWith(EndInput value, $Res Function(EndInput) _then) = _$EndInputCopyWithImpl;
@useResult
$Res call({
 String? placeId, LatLng? location, String? name, String arriveBy
});


$LatLngCopyWith<$Res>? get location;

}
/// @nodoc
class _$EndInputCopyWithImpl<$Res>
    implements $EndInputCopyWith<$Res> {
  _$EndInputCopyWithImpl(this._self, this._then);

  final EndInput _self;
  final $Res Function(EndInput) _then;

/// Create a copy of EndInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = freezed,Object? location = freezed,Object? name = freezed,Object? arriveBy = null,}) {
  return _then(EndInput(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,arriveBy: null == arriveBy ? _self.arriveBy : arriveBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of EndInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatLngCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LatLngCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [EndInput].
extension EndInputPatterns on EndInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EndInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EndInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EndInput value)  $default,){
final _that = this;
switch (_that) {
case _EndInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EndInput value)?  $default,){
final _that = this;
switch (_that) {
case _EndInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? placeId,  LatLng? location,  String? name,  String arriveBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EndInput() when $default != null:
return $default(_that.placeId,_that.location,_that.name,_that.arriveBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? placeId,  LatLng? location,  String? name,  String arriveBy)  $default,) {final _that = this;
switch (_that) {
case _EndInput():
return $default(_that.placeId,_that.location,_that.name,_that.arriveBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? placeId,  LatLng? location,  String? name,  String arriveBy)?  $default,) {final _that = this;
switch (_that) {
case _EndInput() when $default != null:
return $default(_that.placeId,_that.location,_that.name,_that.arriveBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EndInput implements EndInput {
  const _EndInput({this.placeId, this.location, this.name, required this.arriveBy}): assert(placeId != null || (location != null && name != null), 'placeId か location と name のどちらかを指定する');
  factory _EndInput.fromJson(Map<String, dynamic> json) => _$EndInputFromJson(json);

@override final  String? placeId;
@override final  LatLng? location;
@override final  String? name;
/// 終わる場所に着きたい時刻（HH:mm）。終わる場所への移動も含めて判定される
@override final  String arriveBy;

/// Create a copy of EndInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EndInputCopyWith<_EndInput> get copyWith => __$EndInputCopyWithImpl<_EndInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EndInputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EndInput&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.location, location) || other.location == location)&&(identical(other.name, name) || other.name == name)&&(identical(other.arriveBy, arriveBy) || other.arriveBy == arriveBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,location,name,arriveBy);
}

@override
String toString() {
    return 'EndInput(placeId: $placeId, location: $location, name: $name, arriveBy: $arriveBy)';
}


}

/// @nodoc
abstract mixin class _$EndInputCopyWith<$Res> implements $EndInputCopyWith<$Res> {
  factory _$EndInputCopyWith(_EndInput value, $Res Function(_EndInput) _then) = __$EndInputCopyWithImpl;
@override @useResult
$Res call({
 String? placeId, LatLng? location, String? name, String arriveBy
});


@override $LatLngCopyWith<$Res>? get location;

}
/// @nodoc
class __$EndInputCopyWithImpl<$Res>
    implements _$EndInputCopyWith<$Res> {
  __$EndInputCopyWithImpl(this._self, this._then);

  final _EndInput _self;
  final $Res Function(_EndInput) _then;

/// Create a copy of EndInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = freezed,Object? location = freezed,Object? name = freezed,Object? arriveBy = null,}) {
  return _then(_EndInput(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,arriveBy: null == arriveBy ? _self.arriveBy : arriveBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of EndInput
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatLngCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LatLngCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$CreateItineraryRequest {

 String get title;/// 旅行日（YYYY-MM-DD）
 String get date; StartInput get start; EndInput get end; List<PlaceInput> get places;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateItineraryRequest&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&const DeepCollectionEquality().equals(other.places, _this.places));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateItineraryRequest;
  return Object.hash(runtimeType,_this.title,_this.date,_this.start,_this.end,const DeepCollectionEquality().hash(_this.places));
}

@override
String toString() {
  final _this = this as CreateItineraryRequest;
  return 'CreateItineraryRequest(title: ${_this.title}, date: ${_this.date}, start: ${_this.start}, end: ${_this.end}, places: ${_this.places})';
}


}

/// @nodoc
abstract mixin class $CreateItineraryRequestCopyWith<$Res>  {
  factory $CreateItineraryRequestCopyWith(CreateItineraryRequest value, $Res Function(CreateItineraryRequest) _then) = _$CreateItineraryRequestCopyWithImpl;
@useResult
$Res call({
 String title, String date, StartInput start, EndInput end, List<PlaceInput> places
});


$StartInputCopyWith<$Res> get start;$EndInputCopyWith<$Res> get end;

}
/// @nodoc
class _$CreateItineraryRequestCopyWithImpl<$Res>
    implements $CreateItineraryRequestCopyWith<$Res> {
  _$CreateItineraryRequestCopyWithImpl(this._self, this._then);

  final CreateItineraryRequest _self;
  final $Res Function(CreateItineraryRequest) _then;

/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? date = null,Object? start = null,Object? end = null,Object? places = null,}) {
  return _then(CreateItineraryRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as StartInput,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as EndInput,places: null == places ? _self.places : places // ignore: cast_nullable_to_non_nullable
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
}/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EndInputCopyWith<$Res> get end {
  
  return $EndInputCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String date,  StartInput start,  EndInput end,  List<PlaceInput> places)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateItineraryRequest() when $default != null:
return $default(_that.title,_that.date,_that.start,_that.end,_that.places);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String date,  StartInput start,  EndInput end,  List<PlaceInput> places)  $default,) {final _that = this;
switch (_that) {
case _CreateItineraryRequest():
return $default(_that.title,_that.date,_that.start,_that.end,_that.places);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String date,  StartInput start,  EndInput end,  List<PlaceInput> places)?  $default,) {final _that = this;
switch (_that) {
case _CreateItineraryRequest() when $default != null:
return $default(_that.title,_that.date,_that.start,_that.end,_that.places);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateItineraryRequest implements CreateItineraryRequest {
  const _CreateItineraryRequest({required this.title, required this.date, required this.start, required this.end, required  List<PlaceInput> places}): _places = places;
  factory _CreateItineraryRequest.fromJson(Map<String, dynamic> json) => _$CreateItineraryRequestFromJson(json);

@override final  String title;
/// 旅行日（YYYY-MM-DD）
@override final  String date;
@override final  StartInput start;
@override final  EndInput end;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateItineraryRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.places, _places));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,title,date,start,end,const DeepCollectionEquality().hash(_places));
}

@override
String toString() {
    return 'CreateItineraryRequest(title: $title, date: $date, start: $start, end: $end, places: $places)';
}


}

/// @nodoc
abstract mixin class _$CreateItineraryRequestCopyWith<$Res> implements $CreateItineraryRequestCopyWith<$Res> {
  factory _$CreateItineraryRequestCopyWith(_CreateItineraryRequest value, $Res Function(_CreateItineraryRequest) _then) = __$CreateItineraryRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, String date, StartInput start, EndInput end, List<PlaceInput> places
});


@override $StartInputCopyWith<$Res> get start;@override $EndInputCopyWith<$Res> get end;

}
/// @nodoc
class __$CreateItineraryRequestCopyWithImpl<$Res>
    implements _$CreateItineraryRequestCopyWith<$Res> {
  __$CreateItineraryRequestCopyWithImpl(this._self, this._then);

  final _CreateItineraryRequest _self;
  final $Res Function(_CreateItineraryRequest) _then;

/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? date = null,Object? start = null,Object? end = null,Object? places = null,}) {
  return _then(_CreateItineraryRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as StartInput,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as EndInput,places: null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
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
}/// Create a copy of CreateItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EndInputCopyWith<$Res> get end {
  
  return $EndInputCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}


/// @nodoc
mixin _$UpdatePlacesRequest {

/// 旅行日（YYYY-MM-DD）
 String? get date; StartInput? get start; EndInput? get end; List<PlaceInput> get places;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePlacesRequest&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&const DeepCollectionEquality().equals(other.places, _this.places));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdatePlacesRequest;
  return Object.hash(runtimeType,_this.date,_this.start,_this.end,const DeepCollectionEquality().hash(_this.places));
}

@override
String toString() {
  final _this = this as UpdatePlacesRequest;
  return 'UpdatePlacesRequest(date: ${_this.date}, start: ${_this.start}, end: ${_this.end}, places: ${_this.places})';
}


}

/// @nodoc
abstract mixin class $UpdatePlacesRequestCopyWith<$Res>  {
  factory $UpdatePlacesRequestCopyWith(UpdatePlacesRequest value, $Res Function(UpdatePlacesRequest) _then) = _$UpdatePlacesRequestCopyWithImpl;
@useResult
$Res call({
 String? date, StartInput? start, EndInput? end, List<PlaceInput> places
});


$StartInputCopyWith<$Res>? get start;$EndInputCopyWith<$Res>? get end;

}
/// @nodoc
class _$UpdatePlacesRequestCopyWithImpl<$Res>
    implements $UpdatePlacesRequestCopyWith<$Res> {
  _$UpdatePlacesRequestCopyWithImpl(this._self, this._then);

  final UpdatePlacesRequest _self;
  final $Res Function(UpdatePlacesRequest) _then;

/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = freezed,Object? start = freezed,Object? end = freezed,Object? places = null,}) {
  return _then(UpdatePlacesRequest(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as StartInput?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as EndInput?,places: null == places ? _self.places : places // ignore: cast_nullable_to_non_nullable
as List<PlaceInput>,
  ));
}
/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StartInputCopyWith<$Res>? get start {
    if (_self.start == null) {
    return null;
  }

  return $StartInputCopyWith<$Res>(_self.start!, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EndInputCopyWith<$Res>? get end {
    if (_self.end == null) {
    return null;
  }

  return $EndInputCopyWith<$Res>(_self.end!, (value) {
    return _then(_self.copyWith(end: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? date,  StartInput? start,  EndInput? end,  List<PlaceInput> places)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePlacesRequest() when $default != null:
return $default(_that.date,_that.start,_that.end,_that.places);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? date,  StartInput? start,  EndInput? end,  List<PlaceInput> places)  $default,) {final _that = this;
switch (_that) {
case _UpdatePlacesRequest():
return $default(_that.date,_that.start,_that.end,_that.places);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? date,  StartInput? start,  EndInput? end,  List<PlaceInput> places)?  $default,) {final _that = this;
switch (_that) {
case _UpdatePlacesRequest() when $default != null:
return $default(_that.date,_that.start,_that.end,_that.places);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdatePlacesRequest implements UpdatePlacesRequest {
  const _UpdatePlacesRequest({this.date, this.start, this.end, required  List<PlaceInput> places}): _places = places;
  factory _UpdatePlacesRequest.fromJson(Map<String, dynamic> json) => _$UpdatePlacesRequestFromJson(json);

/// 旅行日（YYYY-MM-DD）
@override final  String? date;
@override final  StartInput? start;
@override final  EndInput? end;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePlacesRequest&&(identical(other.date, date) || other.date == date)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.places, _places));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,start,end,const DeepCollectionEquality().hash(_places));
}

@override
String toString() {
    return 'UpdatePlacesRequest(date: $date, start: $start, end: $end, places: $places)';
}


}

/// @nodoc
abstract mixin class _$UpdatePlacesRequestCopyWith<$Res> implements $UpdatePlacesRequestCopyWith<$Res> {
  factory _$UpdatePlacesRequestCopyWith(_UpdatePlacesRequest value, $Res Function(_UpdatePlacesRequest) _then) = __$UpdatePlacesRequestCopyWithImpl;
@override @useResult
$Res call({
 String? date, StartInput? start, EndInput? end, List<PlaceInput> places
});


@override $StartInputCopyWith<$Res>? get start;@override $EndInputCopyWith<$Res>? get end;

}
/// @nodoc
class __$UpdatePlacesRequestCopyWithImpl<$Res>
    implements _$UpdatePlacesRequestCopyWith<$Res> {
  __$UpdatePlacesRequestCopyWithImpl(this._self, this._then);

  final _UpdatePlacesRequest _self;
  final $Res Function(_UpdatePlacesRequest) _then;

/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = freezed,Object? start = freezed,Object? end = freezed,Object? places = null,}) {
  return _then(_UpdatePlacesRequest(
date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as StartInput?,end: freezed == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as EndInput?,places: null == places ? _self._places : places // ignore: cast_nullable_to_non_nullable
as List<PlaceInput>,
  ));
}

/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StartInputCopyWith<$Res>? get start {
    if (_self.start == null) {
    return null;
  }

  return $StartInputCopyWith<$Res>(_self.start!, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of UpdatePlacesRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EndInputCopyWith<$Res>? get end {
    if (_self.end == null) {
    return null;
  }

  return $EndInputCopyWith<$Res>(_self.end!, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}


/// @nodoc
mixin _$ReplanRequest {

 String? get currentItemId; int? get delayMin;/// 今の時刻。サーバーはタイムゾーン付きの RFC3339 で読む
@Rfc3339Converter() DateTime? get now;
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
 String? currentItemId, int? delayMin,@Rfc3339Converter() DateTime? now
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? currentItemId,  int? delayMin, @Rfc3339Converter()  DateTime? now)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? currentItemId,  int? delayMin, @Rfc3339Converter()  DateTime? now)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? currentItemId,  int? delayMin, @Rfc3339Converter()  DateTime? now)?  $default,) {final _that = this;
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
  const _ReplanRequest({this.currentItemId, this.delayMin, @Rfc3339Converter() this.now}): assert((delayMin == null) != (now == null), 'delayMin か now のどちらか一方を指定する');
  factory _ReplanRequest.fromJson(Map<String, dynamic> json) => _$ReplanRequestFromJson(json);

@override final  String? currentItemId;
@override final  int? delayMin;
/// 今の時刻。サーバーはタイムゾーン付きの RFC3339 で読む
@override@Rfc3339Converter() final  DateTime? now;

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
 String? currentItemId, int? delayMin,@Rfc3339Converter() DateTime? now
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


/// @nodoc
mixin _$CopyItineraryRequest {

/// コピー先の旅行日（YYYY-MM-DD）
 String get date; String? get title;
/// Create a copy of CopyItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CopyItineraryRequestCopyWith<CopyItineraryRequest> get copyWith => _$CopyItineraryRequestCopyWithImpl<CopyItineraryRequest>(this as CopyItineraryRequest, _$identity);

  /// Serializes this CopyItineraryRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CopyItineraryRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CopyItineraryRequest&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.title, _this.title) || other.title == _this.title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CopyItineraryRequest;
  return Object.hash(runtimeType,_this.date,_this.title);
}

@override
String toString() {
  final _this = this as CopyItineraryRequest;
  return 'CopyItineraryRequest(date: ${_this.date}, title: ${_this.title})';
}


}

/// @nodoc
abstract mixin class $CopyItineraryRequestCopyWith<$Res>  {
  factory $CopyItineraryRequestCopyWith(CopyItineraryRequest value, $Res Function(CopyItineraryRequest) _then) = _$CopyItineraryRequestCopyWithImpl;
@useResult
$Res call({
 String date, String? title
});




}
/// @nodoc
class _$CopyItineraryRequestCopyWithImpl<$Res>
    implements $CopyItineraryRequestCopyWith<$Res> {
  _$CopyItineraryRequestCopyWithImpl(this._self, this._then);

  final CopyItineraryRequest _self;
  final $Res Function(CopyItineraryRequest) _then;

/// Create a copy of CopyItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? title = freezed,}) {
  return _then(CopyItineraryRequest(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CopyItineraryRequest].
extension CopyItineraryRequestPatterns on CopyItineraryRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CopyItineraryRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CopyItineraryRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CopyItineraryRequest value)  $default,){
final _that = this;
switch (_that) {
case _CopyItineraryRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CopyItineraryRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CopyItineraryRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String? title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CopyItineraryRequest() when $default != null:
return $default(_that.date,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String? title)  $default,) {final _that = this;
switch (_that) {
case _CopyItineraryRequest():
return $default(_that.date,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String? title)?  $default,) {final _that = this;
switch (_that) {
case _CopyItineraryRequest() when $default != null:
return $default(_that.date,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CopyItineraryRequest implements CopyItineraryRequest {
  const _CopyItineraryRequest({required this.date, this.title});
  factory _CopyItineraryRequest.fromJson(Map<String, dynamic> json) => _$CopyItineraryRequestFromJson(json);

/// コピー先の旅行日（YYYY-MM-DD）
@override final  String date;
@override final  String? title;

/// Create a copy of CopyItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CopyItineraryRequestCopyWith<_CopyItineraryRequest> get copyWith => __$CopyItineraryRequestCopyWithImpl<_CopyItineraryRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CopyItineraryRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CopyItineraryRequest&&(identical(other.date, date) || other.date == date)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,title);
}

@override
String toString() {
    return 'CopyItineraryRequest(date: $date, title: $title)';
}


}

/// @nodoc
abstract mixin class _$CopyItineraryRequestCopyWith<$Res> implements $CopyItineraryRequestCopyWith<$Res> {
  factory _$CopyItineraryRequestCopyWith(_CopyItineraryRequest value, $Res Function(_CopyItineraryRequest) _then) = __$CopyItineraryRequestCopyWithImpl;
@override @useResult
$Res call({
 String date, String? title
});




}
/// @nodoc
class __$CopyItineraryRequestCopyWithImpl<$Res>
    implements _$CopyItineraryRequestCopyWith<$Res> {
  __$CopyItineraryRequestCopyWithImpl(this._self, this._then);

  final _CopyItineraryRequest _self;
  final $Res Function(_CopyItineraryRequest) _then;

/// Create a copy of CopyItineraryRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? title = freezed,}) {
  return _then(_CopyItineraryRequest(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
