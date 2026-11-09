// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NearbyPlace {

 String get placeId; String get name; String get address; LatLng get location;/// 画面に出す施設の種類（駅、温泉、飲食店街など）
 String get typeLabel;
/// Create a copy of NearbyPlace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NearbyPlaceCopyWith<NearbyPlace> get copyWith => _$NearbyPlaceCopyWithImpl<NearbyPlace>(this as NearbyPlace, _$identity);

  /// Serializes this NearbyPlace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NearbyPlace;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NearbyPlace&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.typeLabel, _this.typeLabel) || other.typeLabel == _this.typeLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NearbyPlace;
  return Object.hash(runtimeType,_this.placeId,_this.name,_this.address,_this.location,_this.typeLabel);
}

@override
String toString() {
  final _this = this as NearbyPlace;
  return 'NearbyPlace(placeId: ${_this.placeId}, name: ${_this.name}, address: ${_this.address}, location: ${_this.location}, typeLabel: ${_this.typeLabel})';
}


}

/// @nodoc
abstract mixin class $NearbyPlaceCopyWith<$Res>  {
  factory $NearbyPlaceCopyWith(NearbyPlace value, $Res Function(NearbyPlace) _then) = _$NearbyPlaceCopyWithImpl;
@useResult
$Res call({
 String placeId, String name, String address, LatLng location, String typeLabel
});


$LatLngCopyWith<$Res> get location;

}
/// @nodoc
class _$NearbyPlaceCopyWithImpl<$Res>
    implements $NearbyPlaceCopyWith<$Res> {
  _$NearbyPlaceCopyWithImpl(this._self, this._then);

  final NearbyPlace _self;
  final $Res Function(NearbyPlace) _then;

/// Create a copy of NearbyPlace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? name = null,Object? address = null,Object? location = null,Object? typeLabel = null,}) {
  return _then(NearbyPlace(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of NearbyPlace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatLngCopyWith<$Res> get location {
  
  return $LatLngCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [NearbyPlace].
extension NearbyPlacePatterns on NearbyPlace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NearbyPlace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NearbyPlace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NearbyPlace value)  $default,){
final _that = this;
switch (_that) {
case _NearbyPlace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NearbyPlace value)?  $default,){
final _that = this;
switch (_that) {
case _NearbyPlace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String name,  String address,  LatLng location,  String typeLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NearbyPlace() when $default != null:
return $default(_that.placeId,_that.name,_that.address,_that.location,_that.typeLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String name,  String address,  LatLng location,  String typeLabel)  $default,) {final _that = this;
switch (_that) {
case _NearbyPlace():
return $default(_that.placeId,_that.name,_that.address,_that.location,_that.typeLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String name,  String address,  LatLng location,  String typeLabel)?  $default,) {final _that = this;
switch (_that) {
case _NearbyPlace() when $default != null:
return $default(_that.placeId,_that.name,_that.address,_that.location,_that.typeLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NearbyPlace extends NearbyPlace {
  const _NearbyPlace({required this.placeId, required this.name, this.address = '', required this.location, this.typeLabel = ''}): super._();
  factory _NearbyPlace.fromJson(Map<String, dynamic> json) => _$NearbyPlaceFromJson(json);

@override final  String placeId;
@override final  String name;
@override@JsonKey() final  String address;
@override final  LatLng location;
/// 画面に出す施設の種類（駅、温泉、飲食店街など）
@override@JsonKey() final  String typeLabel;

/// Create a copy of NearbyPlace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NearbyPlaceCopyWith<_NearbyPlace> get copyWith => __$NearbyPlaceCopyWithImpl<_NearbyPlace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NearbyPlaceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NearbyPlace&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.location, location) || other.location == location)&&(identical(other.typeLabel, typeLabel) || other.typeLabel == typeLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,name,address,location,typeLabel);
}

@override
String toString() {
    return 'NearbyPlace(placeId: $placeId, name: $name, address: $address, location: $location, typeLabel: $typeLabel)';
}


}

/// @nodoc
abstract mixin class _$NearbyPlaceCopyWith<$Res> implements $NearbyPlaceCopyWith<$Res> {
  factory _$NearbyPlaceCopyWith(_NearbyPlace value, $Res Function(_NearbyPlace) _then) = __$NearbyPlaceCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String name, String address, LatLng location, String typeLabel
});


@override $LatLngCopyWith<$Res> get location;

}
/// @nodoc
class __$NearbyPlaceCopyWithImpl<$Res>
    implements _$NearbyPlaceCopyWith<$Res> {
  __$NearbyPlaceCopyWithImpl(this._self, this._then);

  final _NearbyPlace _self;
  final $Res Function(_NearbyPlace) _then;

/// Create a copy of NearbyPlace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? name = null,Object? address = null,Object? location = null,Object? typeLabel = null,}) {
  return _then(_NearbyPlace(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of NearbyPlace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatLngCopyWith<$Res> get location {
  
  return $LatLngCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$PlaceDetail {

 Place get place; String get typeLabel;/// その日の営業時間。休みなら null
 OpeningHours? get openingHours; Price get price;
/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceDetailCopyWith<PlaceDetail> get copyWith => _$PlaceDetailCopyWithImpl<PlaceDetail>(this as PlaceDetail, _$identity);

  /// Serializes this PlaceDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlaceDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceDetail&&(identical(other.place, _this.place) || other.place == _this.place)&&(identical(other.typeLabel, _this.typeLabel) || other.typeLabel == _this.typeLabel)&&(identical(other.openingHours, _this.openingHours) || other.openingHours == _this.openingHours)&&(identical(other.price, _this.price) || other.price == _this.price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlaceDetail;
  return Object.hash(runtimeType,_this.place,_this.typeLabel,_this.openingHours,_this.price);
}

@override
String toString() {
  final _this = this as PlaceDetail;
  return 'PlaceDetail(place: ${_this.place}, typeLabel: ${_this.typeLabel}, openingHours: ${_this.openingHours}, price: ${_this.price})';
}


}

/// @nodoc
abstract mixin class $PlaceDetailCopyWith<$Res>  {
  factory $PlaceDetailCopyWith(PlaceDetail value, $Res Function(PlaceDetail) _then) = _$PlaceDetailCopyWithImpl;
@useResult
$Res call({
 Place place, String typeLabel, OpeningHours? openingHours, Price price
});


$PlaceCopyWith<$Res> get place;$OpeningHoursCopyWith<$Res>? get openingHours;$PriceCopyWith<$Res> get price;

}
/// @nodoc
class _$PlaceDetailCopyWithImpl<$Res>
    implements $PlaceDetailCopyWith<$Res> {
  _$PlaceDetailCopyWithImpl(this._self, this._then);

  final PlaceDetail _self;
  final $Res Function(PlaceDetail) _then;

/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? place = null,Object? typeLabel = null,Object? openingHours = freezed,Object? price = null,}) {
  return _then(PlaceDetail(
place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as Place,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as OpeningHours?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}
/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get place {
  
  return $PlaceCopyWith<$Res>(_self.place, (value) {
    return _then(_self.copyWith(place: value));
  });
}/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpeningHoursCopyWith<$Res>? get openingHours {
    if (_self.openingHours == null) {
    return null;
  }

  return $OpeningHoursCopyWith<$Res>(_self.openingHours!, (value) {
    return _then(_self.copyWith(openingHours: value));
  });
}/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaceDetail].
extension PlaceDetailPatterns on PlaceDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceDetail value)  $default,){
final _that = this;
switch (_that) {
case _PlaceDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceDetail value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Place place,  String typeLabel,  OpeningHours? openingHours,  Price price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceDetail() when $default != null:
return $default(_that.place,_that.typeLabel,_that.openingHours,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Place place,  String typeLabel,  OpeningHours? openingHours,  Price price)  $default,) {final _that = this;
switch (_that) {
case _PlaceDetail():
return $default(_that.place,_that.typeLabel,_that.openingHours,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Place place,  String typeLabel,  OpeningHours? openingHours,  Price price)?  $default,) {final _that = this;
switch (_that) {
case _PlaceDetail() when $default != null:
return $default(_that.place,_that.typeLabel,_that.openingHours,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceDetail implements PlaceDetail {
  const _PlaceDetail({required this.place, this.typeLabel = '', this.openingHours, this.price = const Price()});
  factory _PlaceDetail.fromJson(Map<String, dynamic> json) => _$PlaceDetailFromJson(json);

@override final  Place place;
@override@JsonKey() final  String typeLabel;
/// その日の営業時間。休みなら null
@override final  OpeningHours? openingHours;
@override@JsonKey() final  Price price;

/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceDetailCopyWith<_PlaceDetail> get copyWith => __$PlaceDetailCopyWithImpl<_PlaceDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceDetail&&(identical(other.place, place) || other.place == place)&&(identical(other.typeLabel, typeLabel) || other.typeLabel == typeLabel)&&(identical(other.openingHours, openingHours) || other.openingHours == openingHours)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,place,typeLabel,openingHours,price);
}

@override
String toString() {
    return 'PlaceDetail(place: $place, typeLabel: $typeLabel, openingHours: $openingHours, price: $price)';
}


}

/// @nodoc
abstract mixin class _$PlaceDetailCopyWith<$Res> implements $PlaceDetailCopyWith<$Res> {
  factory _$PlaceDetailCopyWith(_PlaceDetail value, $Res Function(_PlaceDetail) _then) = __$PlaceDetailCopyWithImpl;
@override @useResult
$Res call({
 Place place, String typeLabel, OpeningHours? openingHours, Price price
});


@override $PlaceCopyWith<$Res> get place;@override $OpeningHoursCopyWith<$Res>? get openingHours;@override $PriceCopyWith<$Res> get price;

}
/// @nodoc
class __$PlaceDetailCopyWithImpl<$Res>
    implements _$PlaceDetailCopyWith<$Res> {
  __$PlaceDetailCopyWithImpl(this._self, this._then);

  final _PlaceDetail _self;
  final $Res Function(_PlaceDetail) _then;

/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? place = null,Object? typeLabel = null,Object? openingHours = freezed,Object? price = null,}) {
  return _then(_PlaceDetail(
place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as Place,typeLabel: null == typeLabel ? _self.typeLabel : typeLabel // ignore: cast_nullable_to_non_nullable
as String,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as OpeningHours?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,
  ));
}

/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get place {
  
  return $PlaceCopyWith<$Res>(_self.place, (value) {
    return _then(_self.copyWith(place: value));
  });
}/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpeningHoursCopyWith<$Res>? get openingHours {
    if (_self.openingHours == null) {
    return null;
  }

  return $OpeningHoursCopyWith<$Res>(_self.openingHours!, (value) {
    return _then(_self.copyWith(openingHours: value));
  });
}/// Create a copy of PlaceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}

// dart format on
