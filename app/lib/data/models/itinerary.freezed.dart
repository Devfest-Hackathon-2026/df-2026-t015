// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'itinerary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OpeningHours {

 String get opensAt; String get closesAt;
/// Create a copy of OpeningHours
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpeningHoursCopyWith<OpeningHours> get copyWith => _$OpeningHoursCopyWithImpl<OpeningHours>(this as OpeningHours, _$identity);

  /// Serializes this OpeningHours to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OpeningHours;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpeningHours&&(identical(other.opensAt, _this.opensAt) || other.opensAt == _this.opensAt)&&(identical(other.closesAt, _this.closesAt) || other.closesAt == _this.closesAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OpeningHours;
  return Object.hash(runtimeType,_this.opensAt,_this.closesAt);
}

@override
String toString() {
  final _this = this as OpeningHours;
  return 'OpeningHours(opensAt: ${_this.opensAt}, closesAt: ${_this.closesAt})';
}


}

/// @nodoc
abstract mixin class $OpeningHoursCopyWith<$Res>  {
  factory $OpeningHoursCopyWith(OpeningHours value, $Res Function(OpeningHours) _then) = _$OpeningHoursCopyWithImpl;
@useResult
$Res call({
 String opensAt, String closesAt
});




}
/// @nodoc
class _$OpeningHoursCopyWithImpl<$Res>
    implements $OpeningHoursCopyWith<$Res> {
  _$OpeningHoursCopyWithImpl(this._self, this._then);

  final OpeningHours _self;
  final $Res Function(OpeningHours) _then;

/// Create a copy of OpeningHours
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? opensAt = null,Object? closesAt = null,}) {
  return _then(OpeningHours(
opensAt: null == opensAt ? _self.opensAt : opensAt // ignore: cast_nullable_to_non_nullable
as String,closesAt: null == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OpeningHours].
extension OpeningHoursPatterns on OpeningHours {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpeningHours value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpeningHours() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpeningHours value)  $default,){
final _that = this;
switch (_that) {
case _OpeningHours():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpeningHours value)?  $default,){
final _that = this;
switch (_that) {
case _OpeningHours() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String opensAt,  String closesAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpeningHours() when $default != null:
return $default(_that.opensAt,_that.closesAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String opensAt,  String closesAt)  $default,) {final _that = this;
switch (_that) {
case _OpeningHours():
return $default(_that.opensAt,_that.closesAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String opensAt,  String closesAt)?  $default,) {final _that = this;
switch (_that) {
case _OpeningHours() when $default != null:
return $default(_that.opensAt,_that.closesAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OpeningHours implements OpeningHours {
  const _OpeningHours({required this.opensAt, required this.closesAt});
  factory _OpeningHours.fromJson(Map<String, dynamic> json) => _$OpeningHoursFromJson(json);

@override final  String opensAt;
@override final  String closesAt;

/// Create a copy of OpeningHours
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpeningHoursCopyWith<_OpeningHours> get copyWith => __$OpeningHoursCopyWithImpl<_OpeningHours>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpeningHoursToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpeningHours&&(identical(other.opensAt, opensAt) || other.opensAt == opensAt)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,opensAt,closesAt);
}

@override
String toString() {
    return 'OpeningHours(opensAt: $opensAt, closesAt: $closesAt)';
}


}

/// @nodoc
abstract mixin class _$OpeningHoursCopyWith<$Res> implements $OpeningHoursCopyWith<$Res> {
  factory _$OpeningHoursCopyWith(_OpeningHours value, $Res Function(_OpeningHours) _then) = __$OpeningHoursCopyWithImpl;
@override @useResult
$Res call({
 String opensAt, String closesAt
});




}
/// @nodoc
class __$OpeningHoursCopyWithImpl<$Res>
    implements _$OpeningHoursCopyWith<$Res> {
  __$OpeningHoursCopyWithImpl(this._self, this._then);

  final _OpeningHours _self;
  final $Res Function(_OpeningHours) _then;

/// Create a copy of OpeningHours
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? opensAt = null,Object? closesAt = null,}) {
  return _then(_OpeningHours(
opensAt: null == opensAt ? _self.opensAt : opensAt // ignore: cast_nullable_to_non_nullable
as String,closesAt: null == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Item {

 String get itemId; String get placeId; String get name; Priority get priority; int get stayMin; DateTime get startAt; DateTime get endAt; Price get price; OpeningHours? get openingHours;@JsonKey(unknownEnumValue: ItemStatus.upcoming) ItemStatus get status;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Item;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.stayMin, _this.stayMin) || other.stayMin == _this.stayMin)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.openingHours, _this.openingHours) || other.openingHours == _this.openingHours)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Item;
  return Object.hash(runtimeType,_this.itemId,_this.placeId,_this.name,_this.priority,_this.stayMin,_this.startAt,_this.endAt,_this.price,_this.openingHours,_this.status);
}

@override
String toString() {
  final _this = this as Item;
  return 'Item(itemId: ${_this.itemId}, placeId: ${_this.placeId}, name: ${_this.name}, priority: ${_this.priority}, stayMin: ${_this.stayMin}, startAt: ${_this.startAt}, endAt: ${_this.endAt}, price: ${_this.price}, openingHours: ${_this.openingHours}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 String itemId, String placeId, String name, Priority priority, int stayMin, DateTime startAt, DateTime endAt, Price price, OpeningHours? openingHours,@JsonKey(unknownEnumValue: ItemStatus.upcoming) ItemStatus status
});


$PriceCopyWith<$Res> get price;$OpeningHoursCopyWith<$Res>? get openingHours;

}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? placeId = null,Object? name = null,Object? priority = null,Object? stayMin = null,Object? startAt = null,Object? endAt = null,Object? price = null,Object? openingHours = freezed,Object? status = null,}) {
  return _then(Item(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,stayMin: null == stayMin ? _self.stayMin : stayMin // ignore: cast_nullable_to_non_nullable
as int,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as OpeningHours?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,
  ));
}
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Item
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
}
}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemId,  String placeId,  String name,  Priority priority,  int stayMin,  DateTime startAt,  DateTime endAt,  Price price,  OpeningHours? openingHours, @JsonKey(unknownEnumValue: ItemStatus.upcoming)  ItemStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.itemId,_that.placeId,_that.name,_that.priority,_that.stayMin,_that.startAt,_that.endAt,_that.price,_that.openingHours,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemId,  String placeId,  String name,  Priority priority,  int stayMin,  DateTime startAt,  DateTime endAt,  Price price,  OpeningHours? openingHours, @JsonKey(unknownEnumValue: ItemStatus.upcoming)  ItemStatus status)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.itemId,_that.placeId,_that.name,_that.priority,_that.stayMin,_that.startAt,_that.endAt,_that.price,_that.openingHours,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemId,  String placeId,  String name,  Priority priority,  int stayMin,  DateTime startAt,  DateTime endAt,  Price price,  OpeningHours? openingHours, @JsonKey(unknownEnumValue: ItemStatus.upcoming)  ItemStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.itemId,_that.placeId,_that.name,_that.priority,_that.stayMin,_that.startAt,_that.endAt,_that.price,_that.openingHours,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Item implements Item {
  const _Item({required this.itemId, required this.placeId, required this.name, required this.priority, required this.stayMin, required this.startAt, required this.endAt, this.price = const Price(), this.openingHours, @JsonKey(unknownEnumValue: ItemStatus.upcoming) this.status = ItemStatus.upcoming});
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override final  String itemId;
@override final  String placeId;
@override final  String name;
@override final  Priority priority;
@override final  int stayMin;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override@JsonKey() final  Price price;
@override final  OpeningHours? openingHours;
@override@JsonKey(unknownEnumValue: ItemStatus.upcoming) final  ItemStatus status;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.stayMin, stayMin) || other.stayMin == stayMin)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.price, price) || other.price == price)&&(identical(other.openingHours, openingHours) || other.openingHours == openingHours)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,itemId,placeId,name,priority,stayMin,startAt,endAt,price,openingHours,status);
}

@override
String toString() {
    return 'Item(itemId: $itemId, placeId: $placeId, name: $name, priority: $priority, stayMin: $stayMin, startAt: $startAt, endAt: $endAt, price: $price, openingHours: $openingHours, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 String itemId, String placeId, String name, Priority priority, int stayMin, DateTime startAt, DateTime endAt, Price price, OpeningHours? openingHours,@JsonKey(unknownEnumValue: ItemStatus.upcoming) ItemStatus status
});


@override $PriceCopyWith<$Res> get price;@override $OpeningHoursCopyWith<$Res>? get openingHours;

}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? placeId = null,Object? name = null,Object? priority = null,Object? stayMin = null,Object? startAt = null,Object? endAt = null,Object? price = null,Object? openingHours = freezed,Object? status = null,}) {
  return _then(_Item(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,stayMin: null == stayMin ? _self.stayMin : stayMin // ignore: cast_nullable_to_non_nullable
as int,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as OpeningHours?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,
  ));
}

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Item
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
}
}


/// @nodoc
mixin _$Leg {

 String get fromItemId; String get toItemId; TransitMode get mode; int get durationMin; DateTime get departAt; DateTime get arriveAt; String? get lineName;
/// Create a copy of Leg
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegCopyWith<Leg> get copyWith => _$LegCopyWithImpl<Leg>(this as Leg, _$identity);

  /// Serializes this Leg to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Leg;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Leg&&(identical(other.fromItemId, _this.fromItemId) || other.fromItemId == _this.fromItemId)&&(identical(other.toItemId, _this.toItemId) || other.toItemId == _this.toItemId)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.durationMin, _this.durationMin) || other.durationMin == _this.durationMin)&&(identical(other.departAt, _this.departAt) || other.departAt == _this.departAt)&&(identical(other.arriveAt, _this.arriveAt) || other.arriveAt == _this.arriveAt)&&(identical(other.lineName, _this.lineName) || other.lineName == _this.lineName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Leg;
  return Object.hash(runtimeType,_this.fromItemId,_this.toItemId,_this.mode,_this.durationMin,_this.departAt,_this.arriveAt,_this.lineName);
}

@override
String toString() {
  final _this = this as Leg;
  return 'Leg(fromItemId: ${_this.fromItemId}, toItemId: ${_this.toItemId}, mode: ${_this.mode}, durationMin: ${_this.durationMin}, departAt: ${_this.departAt}, arriveAt: ${_this.arriveAt}, lineName: ${_this.lineName})';
}


}

/// @nodoc
abstract mixin class $LegCopyWith<$Res>  {
  factory $LegCopyWith(Leg value, $Res Function(Leg) _then) = _$LegCopyWithImpl;
@useResult
$Res call({
 String fromItemId, String toItemId, TransitMode mode, int durationMin, DateTime departAt, DateTime arriveAt, String? lineName
});




}
/// @nodoc
class _$LegCopyWithImpl<$Res>
    implements $LegCopyWith<$Res> {
  _$LegCopyWithImpl(this._self, this._then);

  final Leg _self;
  final $Res Function(Leg) _then;

/// Create a copy of Leg
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromItemId = null,Object? toItemId = null,Object? mode = null,Object? durationMin = null,Object? departAt = null,Object? arriveAt = null,Object? lineName = freezed,}) {
  return _then(Leg(
fromItemId: null == fromItemId ? _self.fromItemId : fromItemId // ignore: cast_nullable_to_non_nullable
as String,toItemId: null == toItemId ? _self.toItemId : toItemId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as TransitMode,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as DateTime,arriveAt: null == arriveAt ? _self.arriveAt : arriveAt // ignore: cast_nullable_to_non_nullable
as DateTime,lineName: freezed == lineName ? _self.lineName : lineName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Leg].
extension LegPatterns on Leg {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Leg value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Leg() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Leg value)  $default,){
final _that = this;
switch (_that) {
case _Leg():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Leg value)?  $default,){
final _that = this;
switch (_that) {
case _Leg() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromItemId,  String toItemId,  TransitMode mode,  int durationMin,  DateTime departAt,  DateTime arriveAt,  String? lineName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Leg() when $default != null:
return $default(_that.fromItemId,_that.toItemId,_that.mode,_that.durationMin,_that.departAt,_that.arriveAt,_that.lineName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromItemId,  String toItemId,  TransitMode mode,  int durationMin,  DateTime departAt,  DateTime arriveAt,  String? lineName)  $default,) {final _that = this;
switch (_that) {
case _Leg():
return $default(_that.fromItemId,_that.toItemId,_that.mode,_that.durationMin,_that.departAt,_that.arriveAt,_that.lineName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromItemId,  String toItemId,  TransitMode mode,  int durationMin,  DateTime departAt,  DateTime arriveAt,  String? lineName)?  $default,) {final _that = this;
switch (_that) {
case _Leg() when $default != null:
return $default(_that.fromItemId,_that.toItemId,_that.mode,_that.durationMin,_that.departAt,_that.arriveAt,_that.lineName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Leg implements Leg {
  const _Leg({required this.fromItemId, required this.toItemId, required this.mode, required this.durationMin, required this.departAt, required this.arriveAt, this.lineName});
  factory _Leg.fromJson(Map<String, dynamic> json) => _$LegFromJson(json);

@override final  String fromItemId;
@override final  String toItemId;
@override final  TransitMode mode;
@override final  int durationMin;
@override final  DateTime departAt;
@override final  DateTime arriveAt;
@override final  String? lineName;

/// Create a copy of Leg
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LegCopyWith<_Leg> get copyWith => __$LegCopyWithImpl<_Leg>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LegToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Leg&&(identical(other.fromItemId, fromItemId) || other.fromItemId == fromItemId)&&(identical(other.toItemId, toItemId) || other.toItemId == toItemId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.durationMin, durationMin) || other.durationMin == durationMin)&&(identical(other.departAt, departAt) || other.departAt == departAt)&&(identical(other.arriveAt, arriveAt) || other.arriveAt == arriveAt)&&(identical(other.lineName, lineName) || other.lineName == lineName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fromItemId,toItemId,mode,durationMin,departAt,arriveAt,lineName);
}

@override
String toString() {
    return 'Leg(fromItemId: $fromItemId, toItemId: $toItemId, mode: $mode, durationMin: $durationMin, departAt: $departAt, arriveAt: $arriveAt, lineName: $lineName)';
}


}

/// @nodoc
abstract mixin class _$LegCopyWith<$Res> implements $LegCopyWith<$Res> {
  factory _$LegCopyWith(_Leg value, $Res Function(_Leg) _then) = __$LegCopyWithImpl;
@override @useResult
$Res call({
 String fromItemId, String toItemId, TransitMode mode, int durationMin, DateTime departAt, DateTime arriveAt, String? lineName
});




}
/// @nodoc
class __$LegCopyWithImpl<$Res>
    implements _$LegCopyWith<$Res> {
  __$LegCopyWithImpl(this._self, this._then);

  final _Leg _self;
  final $Res Function(_Leg) _then;

/// Create a copy of Leg
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromItemId = null,Object? toItemId = null,Object? mode = null,Object? durationMin = null,Object? departAt = null,Object? arriveAt = null,Object? lineName = freezed,}) {
  return _then(_Leg(
fromItemId: null == fromItemId ? _self.fromItemId : fromItemId // ignore: cast_nullable_to_non_nullable
as String,toItemId: null == toItemId ? _self.toItemId : toItemId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as TransitMode,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as DateTime,arriveAt: null == arriveAt ? _self.arriveAt : arriveAt // ignore: cast_nullable_to_non_nullable
as DateTime,lineName: freezed == lineName ? _self.lineName : lineName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PriceTotal {

 int get amount; bool get hasEstimate;
/// Create a copy of PriceTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceTotalCopyWith<PriceTotal> get copyWith => _$PriceTotalCopyWithImpl<PriceTotal>(this as PriceTotal, _$identity);

  /// Serializes this PriceTotal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PriceTotal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceTotal&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.hasEstimate, _this.hasEstimate) || other.hasEstimate == _this.hasEstimate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PriceTotal;
  return Object.hash(runtimeType,_this.amount,_this.hasEstimate);
}

@override
String toString() {
  final _this = this as PriceTotal;
  return 'PriceTotal(amount: ${_this.amount}, hasEstimate: ${_this.hasEstimate})';
}


}

/// @nodoc
abstract mixin class $PriceTotalCopyWith<$Res>  {
  factory $PriceTotalCopyWith(PriceTotal value, $Res Function(PriceTotal) _then) = _$PriceTotalCopyWithImpl;
@useResult
$Res call({
 int amount, bool hasEstimate
});




}
/// @nodoc
class _$PriceTotalCopyWithImpl<$Res>
    implements $PriceTotalCopyWith<$Res> {
  _$PriceTotalCopyWithImpl(this._self, this._then);

  final PriceTotal _self;
  final $Res Function(PriceTotal) _then;

/// Create a copy of PriceTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? hasEstimate = null,}) {
  return _then(PriceTotal(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,hasEstimate: null == hasEstimate ? _self.hasEstimate : hasEstimate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceTotal].
extension PriceTotalPatterns on PriceTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceTotal value)  $default,){
final _that = this;
switch (_that) {
case _PriceTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceTotal value)?  $default,){
final _that = this;
switch (_that) {
case _PriceTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int amount,  bool hasEstimate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceTotal() when $default != null:
return $default(_that.amount,_that.hasEstimate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int amount,  bool hasEstimate)  $default,) {final _that = this;
switch (_that) {
case _PriceTotal():
return $default(_that.amount,_that.hasEstimate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int amount,  bool hasEstimate)?  $default,) {final _that = this;
switch (_that) {
case _PriceTotal() when $default != null:
return $default(_that.amount,_that.hasEstimate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceTotal implements PriceTotal {
  const _PriceTotal({required this.amount, required this.hasEstimate});
  factory _PriceTotal.fromJson(Map<String, dynamic> json) => _$PriceTotalFromJson(json);

@override final  int amount;
@override final  bool hasEstimate;

/// Create a copy of PriceTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceTotalCopyWith<_PriceTotal> get copyWith => __$PriceTotalCopyWithImpl<_PriceTotal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceTotalToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceTotal&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.hasEstimate, hasEstimate) || other.hasEstimate == hasEstimate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,amount,hasEstimate);
}

@override
String toString() {
    return 'PriceTotal(amount: $amount, hasEstimate: $hasEstimate)';
}


}

/// @nodoc
abstract mixin class _$PriceTotalCopyWith<$Res> implements $PriceTotalCopyWith<$Res> {
  factory _$PriceTotalCopyWith(_PriceTotal value, $Res Function(_PriceTotal) _then) = __$PriceTotalCopyWithImpl;
@override @useResult
$Res call({
 int amount, bool hasEstimate
});




}
/// @nodoc
class __$PriceTotalCopyWithImpl<$Res>
    implements _$PriceTotalCopyWith<$Res> {
  __$PriceTotalCopyWithImpl(this._self, this._then);

  final _PriceTotal _self;
  final $Res Function(_PriceTotal) _then;

/// Create a copy of PriceTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? hasEstimate = null,}) {
  return _then(_PriceTotal(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,hasEstimate: null == hasEstimate ? _self.hasEstimate : hasEstimate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Summary {

 int get moveMin; PriceTotal get priceTotal;/// 終わる場所に着く時刻
 DateTime get endAt;
/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryCopyWith<Summary> get copyWith => _$SummaryCopyWithImpl<Summary>(this as Summary, _$identity);

  /// Serializes this Summary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Summary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Summary&&(identical(other.moveMin, _this.moveMin) || other.moveMin == _this.moveMin)&&(identical(other.priceTotal, _this.priceTotal) || other.priceTotal == _this.priceTotal)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Summary;
  return Object.hash(runtimeType,_this.moveMin,_this.priceTotal,_this.endAt);
}

@override
String toString() {
  final _this = this as Summary;
  return 'Summary(moveMin: ${_this.moveMin}, priceTotal: ${_this.priceTotal}, endAt: ${_this.endAt})';
}


}

/// @nodoc
abstract mixin class $SummaryCopyWith<$Res>  {
  factory $SummaryCopyWith(Summary value, $Res Function(Summary) _then) = _$SummaryCopyWithImpl;
@useResult
$Res call({
 int moveMin, PriceTotal priceTotal, DateTime endAt
});


$PriceTotalCopyWith<$Res> get priceTotal;

}
/// @nodoc
class _$SummaryCopyWithImpl<$Res>
    implements $SummaryCopyWith<$Res> {
  _$SummaryCopyWithImpl(this._self, this._then);

  final Summary _self;
  final $Res Function(Summary) _then;

/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? moveMin = null,Object? priceTotal = null,Object? endAt = null,}) {
  return _then(Summary(
moveMin: null == moveMin ? _self.moveMin : moveMin // ignore: cast_nullable_to_non_nullable
as int,priceTotal: null == priceTotal ? _self.priceTotal : priceTotal // ignore: cast_nullable_to_non_nullable
as PriceTotal,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceTotalCopyWith<$Res> get priceTotal {
  
  return $PriceTotalCopyWith<$Res>(_self.priceTotal, (value) {
    return _then(_self.copyWith(priceTotal: value));
  });
}
}


/// Adds pattern-matching-related methods to [Summary].
extension SummaryPatterns on Summary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Summary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Summary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Summary value)  $default,){
final _that = this;
switch (_that) {
case _Summary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Summary value)?  $default,){
final _that = this;
switch (_that) {
case _Summary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int moveMin,  PriceTotal priceTotal,  DateTime endAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Summary() when $default != null:
return $default(_that.moveMin,_that.priceTotal,_that.endAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int moveMin,  PriceTotal priceTotal,  DateTime endAt)  $default,) {final _that = this;
switch (_that) {
case _Summary():
return $default(_that.moveMin,_that.priceTotal,_that.endAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int moveMin,  PriceTotal priceTotal,  DateTime endAt)?  $default,) {final _that = this;
switch (_that) {
case _Summary() when $default != null:
return $default(_that.moveMin,_that.priceTotal,_that.endAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Summary implements Summary {
  const _Summary({required this.moveMin, required this.priceTotal, required this.endAt});
  factory _Summary.fromJson(Map<String, dynamic> json) => _$SummaryFromJson(json);

@override final  int moveMin;
@override final  PriceTotal priceTotal;
/// 終わる場所に着く時刻
@override final  DateTime endAt;

/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryCopyWith<_Summary> get copyWith => __$SummaryCopyWithImpl<_Summary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Summary&&(identical(other.moveMin, moveMin) || other.moveMin == moveMin)&&(identical(other.priceTotal, priceTotal) || other.priceTotal == priceTotal)&&(identical(other.endAt, endAt) || other.endAt == endAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,moveMin,priceTotal,endAt);
}

@override
String toString() {
    return 'Summary(moveMin: $moveMin, priceTotal: $priceTotal, endAt: $endAt)';
}


}

/// @nodoc
abstract mixin class _$SummaryCopyWith<$Res> implements $SummaryCopyWith<$Res> {
  factory _$SummaryCopyWith(_Summary value, $Res Function(_Summary) _then) = __$SummaryCopyWithImpl;
@override @useResult
$Res call({
 int moveMin, PriceTotal priceTotal, DateTime endAt
});


@override $PriceTotalCopyWith<$Res> get priceTotal;

}
/// @nodoc
class __$SummaryCopyWithImpl<$Res>
    implements _$SummaryCopyWith<$Res> {
  __$SummaryCopyWithImpl(this._self, this._then);

  final _Summary _self;
  final $Res Function(_Summary) _then;

/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? moveMin = null,Object? priceTotal = null,Object? endAt = null,}) {
  return _then(_Summary(
moveMin: null == moveMin ? _self.moveMin : moveMin // ignore: cast_nullable_to_non_nullable
as int,priceTotal: null == priceTotal ? _self.priceTotal : priceTotal // ignore: cast_nullable_to_non_nullable
as PriceTotal,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Summary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceTotalCopyWith<$Res> get priceTotal {
  
  return $PriceTotalCopyWith<$Res>(_self.priceTotal, (value) {
    return _then(_self.copyWith(priceTotal: value));
  });
}
}


/// @nodoc
mixin _$ItineraryStart {

 String? get placeId; String get name; LatLng? get location; DateTime get departAt;
/// Create a copy of ItineraryStart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryStartCopyWith<ItineraryStart> get copyWith => _$ItineraryStartCopyWithImpl<ItineraryStart>(this as ItineraryStart, _$identity);

  /// Serializes this ItineraryStart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ItineraryStart;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryStart&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.departAt, _this.departAt) || other.departAt == _this.departAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ItineraryStart;
  return Object.hash(runtimeType,_this.placeId,_this.name,_this.location,_this.departAt);
}

@override
String toString() {
  final _this = this as ItineraryStart;
  return 'ItineraryStart(placeId: ${_this.placeId}, name: ${_this.name}, location: ${_this.location}, departAt: ${_this.departAt})';
}


}

/// @nodoc
abstract mixin class $ItineraryStartCopyWith<$Res>  {
  factory $ItineraryStartCopyWith(ItineraryStart value, $Res Function(ItineraryStart) _then) = _$ItineraryStartCopyWithImpl;
@useResult
$Res call({
 String? placeId, String name, LatLng? location, DateTime departAt
});


$LatLngCopyWith<$Res>? get location;

}
/// @nodoc
class _$ItineraryStartCopyWithImpl<$Res>
    implements $ItineraryStartCopyWith<$Res> {
  _$ItineraryStartCopyWithImpl(this._self, this._then);

  final ItineraryStart _self;
  final $Res Function(ItineraryStart) _then;

/// Create a copy of ItineraryStart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = freezed,Object? name = null,Object? location = freezed,Object? departAt = null,}) {
  return _then(ItineraryStart(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ItineraryStart
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


/// Adds pattern-matching-related methods to [ItineraryStart].
extension ItineraryStartPatterns on ItineraryStart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryStart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryStart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryStart value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryStart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryStart value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryStart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? placeId,  String name,  LatLng? location,  DateTime departAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryStart() when $default != null:
return $default(_that.placeId,_that.name,_that.location,_that.departAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? placeId,  String name,  LatLng? location,  DateTime departAt)  $default,) {final _that = this;
switch (_that) {
case _ItineraryStart():
return $default(_that.placeId,_that.name,_that.location,_that.departAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? placeId,  String name,  LatLng? location,  DateTime departAt)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryStart() when $default != null:
return $default(_that.placeId,_that.name,_that.location,_that.departAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryStart implements ItineraryStart {
  const _ItineraryStart({this.placeId, required this.name, this.location, required this.departAt});
  factory _ItineraryStart.fromJson(Map<String, dynamic> json) => _$ItineraryStartFromJson(json);

@override final  String? placeId;
@override final  String name;
@override final  LatLng? location;
@override final  DateTime departAt;

/// Create a copy of ItineraryStart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryStartCopyWith<_ItineraryStart> get copyWith => __$ItineraryStartCopyWithImpl<_ItineraryStart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryStartToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryStart&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.departAt, departAt) || other.departAt == departAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,name,location,departAt);
}

@override
String toString() {
    return 'ItineraryStart(placeId: $placeId, name: $name, location: $location, departAt: $departAt)';
}


}

/// @nodoc
abstract mixin class _$ItineraryStartCopyWith<$Res> implements $ItineraryStartCopyWith<$Res> {
  factory _$ItineraryStartCopyWith(_ItineraryStart value, $Res Function(_ItineraryStart) _then) = __$ItineraryStartCopyWithImpl;
@override @useResult
$Res call({
 String? placeId, String name, LatLng? location, DateTime departAt
});


@override $LatLngCopyWith<$Res>? get location;

}
/// @nodoc
class __$ItineraryStartCopyWithImpl<$Res>
    implements _$ItineraryStartCopyWith<$Res> {
  __$ItineraryStartCopyWithImpl(this._self, this._then);

  final _ItineraryStart _self;
  final $Res Function(_ItineraryStart) _then;

/// Create a copy of ItineraryStart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = freezed,Object? name = null,Object? location = freezed,Object? departAt = null,}) {
  return _then(_ItineraryStart(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ItineraryStart
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
mixin _$ItineraryEnd {

 String? get placeId; String get name; LatLng? get location; String? get date;/// 着きたい時刻（HH:mm）
 String get arriveBy;/// 着く予定の時刻
 DateTime get arriveAt;
/// Create a copy of ItineraryEnd
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryEndCopyWith<ItineraryEnd> get copyWith => _$ItineraryEndCopyWithImpl<ItineraryEnd>(this as ItineraryEnd, _$identity);

  /// Serializes this ItineraryEnd to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ItineraryEnd;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryEnd&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.arriveBy, _this.arriveBy) || other.arriveBy == _this.arriveBy)&&(identical(other.arriveAt, _this.arriveAt) || other.arriveAt == _this.arriveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ItineraryEnd;
  return Object.hash(runtimeType,_this.placeId,_this.name,_this.location,_this.date,_this.arriveBy,_this.arriveAt);
}

@override
String toString() {
  final _this = this as ItineraryEnd;
  return 'ItineraryEnd(placeId: ${_this.placeId}, name: ${_this.name}, location: ${_this.location}, date: ${_this.date}, arriveBy: ${_this.arriveBy}, arriveAt: ${_this.arriveAt})';
}


}

/// @nodoc
abstract mixin class $ItineraryEndCopyWith<$Res>  {
  factory $ItineraryEndCopyWith(ItineraryEnd value, $Res Function(ItineraryEnd) _then) = _$ItineraryEndCopyWithImpl;
@useResult
$Res call({
 String? placeId, String name, LatLng? location, String? date, String arriveBy, DateTime arriveAt
});


$LatLngCopyWith<$Res>? get location;

}
/// @nodoc
class _$ItineraryEndCopyWithImpl<$Res>
    implements $ItineraryEndCopyWith<$Res> {
  _$ItineraryEndCopyWithImpl(this._self, this._then);

  final ItineraryEnd _self;
  final $Res Function(ItineraryEnd) _then;

/// Create a copy of ItineraryEnd
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = freezed,Object? name = null,Object? location = freezed,Object? date = freezed,Object? arriveBy = null,Object? arriveAt = null,}) {
  return _then(ItineraryEnd(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,arriveBy: null == arriveBy ? _self.arriveBy : arriveBy // ignore: cast_nullable_to_non_nullable
as String,arriveAt: null == arriveAt ? _self.arriveAt : arriveAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ItineraryEnd
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


/// Adds pattern-matching-related methods to [ItineraryEnd].
extension ItineraryEndPatterns on ItineraryEnd {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryEnd value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryEnd() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryEnd value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryEnd():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryEnd value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryEnd() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? placeId,  String name,  LatLng? location,  String? date,  String arriveBy,  DateTime arriveAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryEnd() when $default != null:
return $default(_that.placeId,_that.name,_that.location,_that.date,_that.arriveBy,_that.arriveAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? placeId,  String name,  LatLng? location,  String? date,  String arriveBy,  DateTime arriveAt)  $default,) {final _that = this;
switch (_that) {
case _ItineraryEnd():
return $default(_that.placeId,_that.name,_that.location,_that.date,_that.arriveBy,_that.arriveAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? placeId,  String name,  LatLng? location,  String? date,  String arriveBy,  DateTime arriveAt)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryEnd() when $default != null:
return $default(_that.placeId,_that.name,_that.location,_that.date,_that.arriveBy,_that.arriveAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryEnd implements ItineraryEnd {
  const _ItineraryEnd({this.placeId, required this.name, this.location, this.date, required this.arriveBy, required this.arriveAt});
  factory _ItineraryEnd.fromJson(Map<String, dynamic> json) => _$ItineraryEndFromJson(json);

@override final  String? placeId;
@override final  String name;
@override final  LatLng? location;
@override final  String? date;
/// 着きたい時刻（HH:mm）
@override final  String arriveBy;
/// 着く予定の時刻
@override final  DateTime arriveAt;

/// Create a copy of ItineraryEnd
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryEndCopyWith<_ItineraryEnd> get copyWith => __$ItineraryEndCopyWithImpl<_ItineraryEnd>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryEndToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryEnd&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.date, date) || other.date == date)&&(identical(other.arriveBy, arriveBy) || other.arriveBy == arriveBy)&&(identical(other.arriveAt, arriveAt) || other.arriveAt == arriveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,name,location,date,arriveBy,arriveAt);
}

@override
String toString() {
    return 'ItineraryEnd(placeId: $placeId, name: $name, location: $location, date: $date, arriveBy: $arriveBy, arriveAt: $arriveAt)';
}


}

/// @nodoc
abstract mixin class _$ItineraryEndCopyWith<$Res> implements $ItineraryEndCopyWith<$Res> {
  factory _$ItineraryEndCopyWith(_ItineraryEnd value, $Res Function(_ItineraryEnd) _then) = __$ItineraryEndCopyWithImpl;
@override @useResult
$Res call({
 String? placeId, String name, LatLng? location, String? date, String arriveBy, DateTime arriveAt
});


@override $LatLngCopyWith<$Res>? get location;

}
/// @nodoc
class __$ItineraryEndCopyWithImpl<$Res>
    implements _$ItineraryEndCopyWith<$Res> {
  __$ItineraryEndCopyWithImpl(this._self, this._then);

  final _ItineraryEnd _self;
  final $Res Function(_ItineraryEnd) _then;

/// Create a copy of ItineraryEnd
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = freezed,Object? name = null,Object? location = freezed,Object? date = freezed,Object? arriveBy = null,Object? arriveAt = null,}) {
  return _then(_ItineraryEnd(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,arriveBy: null == arriveBy ? _self.arriveBy : arriveBy // ignore: cast_nullable_to_non_nullable
as String,arriveAt: null == arriveAt ? _self.arriveAt : arriveAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ItineraryEnd
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
mixin _$DroppedPlace {

 String get placeId; String get name; String get reason;
/// Create a copy of DroppedPlace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DroppedPlaceCopyWith<DroppedPlace> get copyWith => _$DroppedPlaceCopyWithImpl<DroppedPlace>(this as DroppedPlace, _$identity);

  /// Serializes this DroppedPlace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DroppedPlace;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DroppedPlace&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DroppedPlace;
  return Object.hash(runtimeType,_this.placeId,_this.name,_this.reason);
}

@override
String toString() {
  final _this = this as DroppedPlace;
  return 'DroppedPlace(placeId: ${_this.placeId}, name: ${_this.name}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $DroppedPlaceCopyWith<$Res>  {
  factory $DroppedPlaceCopyWith(DroppedPlace value, $Res Function(DroppedPlace) _then) = _$DroppedPlaceCopyWithImpl;
@useResult
$Res call({
 String placeId, String name, String reason
});




}
/// @nodoc
class _$DroppedPlaceCopyWithImpl<$Res>
    implements $DroppedPlaceCopyWith<$Res> {
  _$DroppedPlaceCopyWithImpl(this._self, this._then);

  final DroppedPlace _self;
  final $Res Function(DroppedPlace) _then;

/// Create a copy of DroppedPlace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? name = null,Object? reason = null,}) {
  return _then(DroppedPlace(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DroppedPlace].
extension DroppedPlacePatterns on DroppedPlace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DroppedPlace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DroppedPlace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DroppedPlace value)  $default,){
final _that = this;
switch (_that) {
case _DroppedPlace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DroppedPlace value)?  $default,){
final _that = this;
switch (_that) {
case _DroppedPlace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String name,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DroppedPlace() when $default != null:
return $default(_that.placeId,_that.name,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String name,  String reason)  $default,) {final _that = this;
switch (_that) {
case _DroppedPlace():
return $default(_that.placeId,_that.name,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String name,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _DroppedPlace() when $default != null:
return $default(_that.placeId,_that.name,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DroppedPlace implements DroppedPlace {
  const _DroppedPlace({required this.placeId, required this.name, required this.reason});
  factory _DroppedPlace.fromJson(Map<String, dynamic> json) => _$DroppedPlaceFromJson(json);

@override final  String placeId;
@override final  String name;
@override final  String reason;

/// Create a copy of DroppedPlace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DroppedPlaceCopyWith<_DroppedPlace> get copyWith => __$DroppedPlaceCopyWithImpl<_DroppedPlace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DroppedPlaceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DroppedPlace&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,name,reason);
}

@override
String toString() {
    return 'DroppedPlace(placeId: $placeId, name: $name, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$DroppedPlaceCopyWith<$Res> implements $DroppedPlaceCopyWith<$Res> {
  factory _$DroppedPlaceCopyWith(_DroppedPlace value, $Res Function(_DroppedPlace) _then) = __$DroppedPlaceCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String name, String reason
});




}
/// @nodoc
class __$DroppedPlaceCopyWithImpl<$Res>
    implements _$DroppedPlaceCopyWith<$Res> {
  __$DroppedPlaceCopyWithImpl(this._self, this._then);

  final _DroppedPlace _self;
  final $Res Function(_DroppedPlace) _then;

/// Create a copy of DroppedPlace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? name = null,Object? reason = null,}) {
  return _then(_DroppedPlace(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Itinerary {

 String get id; int get version; String get title;/// 旅行日（YYYY-MM-DD）
 String get date; ItineraryStart get start; ItineraryEnd get end; List<Item> get items; List<Leg> get legs; Summary get summary; List<DroppedPlace> get dropped; DateTime? get expiresAt;
/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryCopyWith<Itinerary> get copyWith => _$ItineraryCopyWithImpl<Itinerary>(this as Itinerary, _$identity);

  /// Serializes this Itinerary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Itinerary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Itinerary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&const DeepCollectionEquality().equals(other.items, _this.items)&&const DeepCollectionEquality().equals(other.legs, _this.legs)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&const DeepCollectionEquality().equals(other.dropped, _this.dropped)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Itinerary;
  return Object.hash(runtimeType,_this.id,_this.version,_this.title,_this.date,_this.start,_this.end,const DeepCollectionEquality().hash(_this.items),const DeepCollectionEquality().hash(_this.legs),_this.summary,const DeepCollectionEquality().hash(_this.dropped),_this.expiresAt);
}

@override
String toString() {
  final _this = this as Itinerary;
  return 'Itinerary(id: ${_this.id}, version: ${_this.version}, title: ${_this.title}, date: ${_this.date}, start: ${_this.start}, end: ${_this.end}, items: ${_this.items}, legs: ${_this.legs}, summary: ${_this.summary}, dropped: ${_this.dropped}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $ItineraryCopyWith<$Res>  {
  factory $ItineraryCopyWith(Itinerary value, $Res Function(Itinerary) _then) = _$ItineraryCopyWithImpl;
@useResult
$Res call({
 String id, int version, String title, String date, ItineraryStart start, ItineraryEnd end, List<Item> items, List<Leg> legs, Summary summary, List<DroppedPlace> dropped, DateTime? expiresAt
});


$ItineraryStartCopyWith<$Res> get start;$ItineraryEndCopyWith<$Res> get end;$SummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$ItineraryCopyWithImpl<$Res>
    implements $ItineraryCopyWith<$Res> {
  _$ItineraryCopyWithImpl(this._self, this._then);

  final Itinerary _self;
  final $Res Function(Itinerary) _then;

/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? version = null,Object? title = null,Object? date = null,Object? start = null,Object? end = null,Object? items = null,Object? legs = null,Object? summary = null,Object? dropped = null,Object? expiresAt = freezed,}) {
  return _then(Itinerary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as ItineraryStart,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as ItineraryEnd,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,legs: null == legs ? _self.legs : legs // ignore: cast_nullable_to_non_nullable
as List<Leg>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Summary,dropped: null == dropped ? _self.dropped : dropped // ignore: cast_nullable_to_non_nullable
as List<DroppedPlace>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItineraryStartCopyWith<$Res> get start {
  
  return $ItineraryStartCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItineraryEndCopyWith<$Res> get end {
  
  return $ItineraryEndCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res> get summary {
  
  return $SummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [Itinerary].
extension ItineraryPatterns on Itinerary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Itinerary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Itinerary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Itinerary value)  $default,){
final _that = this;
switch (_that) {
case _Itinerary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Itinerary value)?  $default,){
final _that = this;
switch (_that) {
case _Itinerary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int version,  String title,  String date,  ItineraryStart start,  ItineraryEnd end,  List<Item> items,  List<Leg> legs,  Summary summary,  List<DroppedPlace> dropped,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Itinerary() when $default != null:
return $default(_that.id,_that.version,_that.title,_that.date,_that.start,_that.end,_that.items,_that.legs,_that.summary,_that.dropped,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int version,  String title,  String date,  ItineraryStart start,  ItineraryEnd end,  List<Item> items,  List<Leg> legs,  Summary summary,  List<DroppedPlace> dropped,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Itinerary():
return $default(_that.id,_that.version,_that.title,_that.date,_that.start,_that.end,_that.items,_that.legs,_that.summary,_that.dropped,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int version,  String title,  String date,  ItineraryStart start,  ItineraryEnd end,  List<Item> items,  List<Leg> legs,  Summary summary,  List<DroppedPlace> dropped,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Itinerary() when $default != null:
return $default(_that.id,_that.version,_that.title,_that.date,_that.start,_that.end,_that.items,_that.legs,_that.summary,_that.dropped,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Itinerary implements Itinerary {
  const _Itinerary({required this.id, required this.version, required this.title, required this.date, required this.start, required this.end,  List<Item> items = const <Item>[],  List<Leg> legs = const <Leg>[], required this.summary,  List<DroppedPlace> dropped = const <DroppedPlace>[], this.expiresAt}): _items = items,_legs = legs,_dropped = dropped;
  factory _Itinerary.fromJson(Map<String, dynamic> json) => _$ItineraryFromJson(json);

@override final  String id;
@override final  int version;
@override final  String title;
/// 旅行日（YYYY-MM-DD）
@override final  String date;
@override final  ItineraryStart start;
@override final  ItineraryEnd end;
 final  List<Item> _items;
@override@JsonKey() List<Item> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<Leg> _legs;
@override@JsonKey() List<Leg> get legs {
  if (_legs is EqualUnmodifiableListView) return _legs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_legs);
}

@override final  Summary summary;
 final  List<DroppedPlace> _dropped;
@override@JsonKey() List<DroppedPlace> get dropped {
  if (_dropped is EqualUnmodifiableListView) return _dropped;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dropped);
}

@override final  DateTime? expiresAt;

/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryCopyWith<_Itinerary> get copyWith => __$ItineraryCopyWithImpl<_Itinerary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Itinerary&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&const DeepCollectionEquality().equals(other.items, _items)&&const DeepCollectionEquality().equals(other.legs, _legs)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.dropped, _dropped)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,version,title,date,start,end,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_legs),summary,const DeepCollectionEquality().hash(_dropped),expiresAt);
}

@override
String toString() {
    return 'Itinerary(id: $id, version: $version, title: $title, date: $date, start: $start, end: $end, items: $items, legs: $legs, summary: $summary, dropped: $dropped, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ItineraryCopyWith<$Res> implements $ItineraryCopyWith<$Res> {
  factory _$ItineraryCopyWith(_Itinerary value, $Res Function(_Itinerary) _then) = __$ItineraryCopyWithImpl;
@override @useResult
$Res call({
 String id, int version, String title, String date, ItineraryStart start, ItineraryEnd end, List<Item> items, List<Leg> legs, Summary summary, List<DroppedPlace> dropped, DateTime? expiresAt
});


@override $ItineraryStartCopyWith<$Res> get start;@override $ItineraryEndCopyWith<$Res> get end;@override $SummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$ItineraryCopyWithImpl<$Res>
    implements _$ItineraryCopyWith<$Res> {
  __$ItineraryCopyWithImpl(this._self, this._then);

  final _Itinerary _self;
  final $Res Function(_Itinerary) _then;

/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? version = null,Object? title = null,Object? date = null,Object? start = null,Object? end = null,Object? items = null,Object? legs = null,Object? summary = null,Object? dropped = null,Object? expiresAt = freezed,}) {
  return _then(_Itinerary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as ItineraryStart,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as ItineraryEnd,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,legs: null == legs ? _self._legs : legs // ignore: cast_nullable_to_non_nullable
as List<Leg>,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Summary,dropped: null == dropped ? _self._dropped : dropped // ignore: cast_nullable_to_non_nullable
as List<DroppedPlace>,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItineraryStartCopyWith<$Res> get start {
  
  return $ItineraryStartCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItineraryEndCopyWith<$Res> get end {
  
  return $ItineraryEndCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}/// Create a copy of Itinerary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res> get summary {
  
  return $SummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// @nodoc
mixin _$ItineraryListStart {

 String get name; DateTime get departAt;
/// Create a copy of ItineraryListStart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryListStartCopyWith<ItineraryListStart> get copyWith => _$ItineraryListStartCopyWithImpl<ItineraryListStart>(this as ItineraryListStart, _$identity);

  /// Serializes this ItineraryListStart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ItineraryListStart;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryListStart&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.departAt, _this.departAt) || other.departAt == _this.departAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ItineraryListStart;
  return Object.hash(runtimeType,_this.name,_this.departAt);
}

@override
String toString() {
  final _this = this as ItineraryListStart;
  return 'ItineraryListStart(name: ${_this.name}, departAt: ${_this.departAt})';
}


}

/// @nodoc
abstract mixin class $ItineraryListStartCopyWith<$Res>  {
  factory $ItineraryListStartCopyWith(ItineraryListStart value, $Res Function(ItineraryListStart) _then) = _$ItineraryListStartCopyWithImpl;
@useResult
$Res call({
 String name, DateTime departAt
});




}
/// @nodoc
class _$ItineraryListStartCopyWithImpl<$Res>
    implements $ItineraryListStartCopyWith<$Res> {
  _$ItineraryListStartCopyWithImpl(this._self, this._then);

  final ItineraryListStart _self;
  final $Res Function(ItineraryListStart) _then;

/// Create a copy of ItineraryListStart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? departAt = null,}) {
  return _then(ItineraryListStart(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryListStart].
extension ItineraryListStartPatterns on ItineraryListStart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryListStart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryListStart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryListStart value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryListStart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryListStart value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryListStart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  DateTime departAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryListStart() when $default != null:
return $default(_that.name,_that.departAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  DateTime departAt)  $default,) {final _that = this;
switch (_that) {
case _ItineraryListStart():
return $default(_that.name,_that.departAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  DateTime departAt)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryListStart() when $default != null:
return $default(_that.name,_that.departAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryListStart implements ItineraryListStart {
  const _ItineraryListStart({required this.name, required this.departAt});
  factory _ItineraryListStart.fromJson(Map<String, dynamic> json) => _$ItineraryListStartFromJson(json);

@override final  String name;
@override final  DateTime departAt;

/// Create a copy of ItineraryListStart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryListStartCopyWith<_ItineraryListStart> get copyWith => __$ItineraryListStartCopyWithImpl<_ItineraryListStart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryListStartToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryListStart&&(identical(other.name, name) || other.name == name)&&(identical(other.departAt, departAt) || other.departAt == departAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,departAt);
}

@override
String toString() {
    return 'ItineraryListStart(name: $name, departAt: $departAt)';
}


}

/// @nodoc
abstract mixin class _$ItineraryListStartCopyWith<$Res> implements $ItineraryListStartCopyWith<$Res> {
  factory _$ItineraryListStartCopyWith(_ItineraryListStart value, $Res Function(_ItineraryListStart) _then) = __$ItineraryListStartCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime departAt
});




}
/// @nodoc
class __$ItineraryListStartCopyWithImpl<$Res>
    implements _$ItineraryListStartCopyWith<$Res> {
  __$ItineraryListStartCopyWithImpl(this._self, this._then);

  final _ItineraryListStart _self;
  final $Res Function(_ItineraryListStart) _then;

/// Create a copy of ItineraryListStart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? departAt = null,}) {
  return _then(_ItineraryListStart(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,departAt: null == departAt ? _self.departAt : departAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ItineraryListEnd {

 String get name; DateTime get arriveAt;
/// Create a copy of ItineraryListEnd
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryListEndCopyWith<ItineraryListEnd> get copyWith => _$ItineraryListEndCopyWithImpl<ItineraryListEnd>(this as ItineraryListEnd, _$identity);

  /// Serializes this ItineraryListEnd to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ItineraryListEnd;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryListEnd&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.arriveAt, _this.arriveAt) || other.arriveAt == _this.arriveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ItineraryListEnd;
  return Object.hash(runtimeType,_this.name,_this.arriveAt);
}

@override
String toString() {
  final _this = this as ItineraryListEnd;
  return 'ItineraryListEnd(name: ${_this.name}, arriveAt: ${_this.arriveAt})';
}


}

/// @nodoc
abstract mixin class $ItineraryListEndCopyWith<$Res>  {
  factory $ItineraryListEndCopyWith(ItineraryListEnd value, $Res Function(ItineraryListEnd) _then) = _$ItineraryListEndCopyWithImpl;
@useResult
$Res call({
 String name, DateTime arriveAt
});




}
/// @nodoc
class _$ItineraryListEndCopyWithImpl<$Res>
    implements $ItineraryListEndCopyWith<$Res> {
  _$ItineraryListEndCopyWithImpl(this._self, this._then);

  final ItineraryListEnd _self;
  final $Res Function(ItineraryListEnd) _then;

/// Create a copy of ItineraryListEnd
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? arriveAt = null,}) {
  return _then(ItineraryListEnd(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arriveAt: null == arriveAt ? _self.arriveAt : arriveAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryListEnd].
extension ItineraryListEndPatterns on ItineraryListEnd {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryListEnd value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryListEnd() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryListEnd value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryListEnd():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryListEnd value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryListEnd() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  DateTime arriveAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryListEnd() when $default != null:
return $default(_that.name,_that.arriveAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  DateTime arriveAt)  $default,) {final _that = this;
switch (_that) {
case _ItineraryListEnd():
return $default(_that.name,_that.arriveAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  DateTime arriveAt)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryListEnd() when $default != null:
return $default(_that.name,_that.arriveAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryListEnd implements ItineraryListEnd {
  const _ItineraryListEnd({required this.name, required this.arriveAt});
  factory _ItineraryListEnd.fromJson(Map<String, dynamic> json) => _$ItineraryListEndFromJson(json);

@override final  String name;
@override final  DateTime arriveAt;

/// Create a copy of ItineraryListEnd
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryListEndCopyWith<_ItineraryListEnd> get copyWith => __$ItineraryListEndCopyWithImpl<_ItineraryListEnd>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryListEndToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryListEnd&&(identical(other.name, name) || other.name == name)&&(identical(other.arriveAt, arriveAt) || other.arriveAt == arriveAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,arriveAt);
}

@override
String toString() {
    return 'ItineraryListEnd(name: $name, arriveAt: $arriveAt)';
}


}

/// @nodoc
abstract mixin class _$ItineraryListEndCopyWith<$Res> implements $ItineraryListEndCopyWith<$Res> {
  factory _$ItineraryListEndCopyWith(_ItineraryListEnd value, $Res Function(_ItineraryListEnd) _then) = __$ItineraryListEndCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime arriveAt
});




}
/// @nodoc
class __$ItineraryListEndCopyWithImpl<$Res>
    implements _$ItineraryListEndCopyWith<$Res> {
  __$ItineraryListEndCopyWithImpl(this._self, this._then);

  final _ItineraryListEnd _self;
  final $Res Function(_ItineraryListEnd) _then;

/// Create a copy of ItineraryListEnd
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? arriveAt = null,}) {
  return _then(_ItineraryListEnd(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arriveAt: null == arriveAt ? _self.arriveAt : arriveAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ItineraryListEntry {

 String get id; String get title;/// 旅行日（YYYY-MM-DD）
 String get date; ItineraryListStart get start; ItineraryListEnd get end; int get placeCount;/// 行き先の名前（先頭 3 件まで）
 List<String> get placeNames; DateTime get updatedAt;/// 自動で消える日時（一覧の「終わった旅」に出す）
 DateTime? get expiresAt;
/// Create a copy of ItineraryListEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryListEntryCopyWith<ItineraryListEntry> get copyWith => _$ItineraryListEntryCopyWithImpl<ItineraryListEntry>(this as ItineraryListEntry, _$identity);

  /// Serializes this ItineraryListEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ItineraryListEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryListEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.placeCount, _this.placeCount) || other.placeCount == _this.placeCount)&&const DeepCollectionEquality().equals(other.placeNames, _this.placeNames)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ItineraryListEntry;
  return Object.hash(runtimeType,_this.id,_this.title,_this.date,_this.start,_this.end,_this.placeCount,const DeepCollectionEquality().hash(_this.placeNames),_this.updatedAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as ItineraryListEntry;
  return 'ItineraryListEntry(id: ${_this.id}, title: ${_this.title}, date: ${_this.date}, start: ${_this.start}, end: ${_this.end}, placeCount: ${_this.placeCount}, placeNames: ${_this.placeNames}, updatedAt: ${_this.updatedAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $ItineraryListEntryCopyWith<$Res>  {
  factory $ItineraryListEntryCopyWith(ItineraryListEntry value, $Res Function(ItineraryListEntry) _then) = _$ItineraryListEntryCopyWithImpl;
@useResult
$Res call({
 String id, String title, String date, ItineraryListStart start, ItineraryListEnd end, int placeCount, List<String> placeNames, DateTime updatedAt, DateTime? expiresAt
});


$ItineraryListStartCopyWith<$Res> get start;$ItineraryListEndCopyWith<$Res> get end;

}
/// @nodoc
class _$ItineraryListEntryCopyWithImpl<$Res>
    implements $ItineraryListEntryCopyWith<$Res> {
  _$ItineraryListEntryCopyWithImpl(this._self, this._then);

  final ItineraryListEntry _self;
  final $Res Function(ItineraryListEntry) _then;

/// Create a copy of ItineraryListEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? date = null,Object? start = null,Object? end = null,Object? placeCount = null,Object? placeNames = null,Object? updatedAt = null,Object? expiresAt = freezed,}) {
  return _then(ItineraryListEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as ItineraryListStart,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as ItineraryListEnd,placeCount: null == placeCount ? _self.placeCount : placeCount // ignore: cast_nullable_to_non_nullable
as int,placeNames: null == placeNames ? _self.placeNames : placeNames // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ItineraryListEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItineraryListStartCopyWith<$Res> get start {
  
  return $ItineraryListStartCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of ItineraryListEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItineraryListEndCopyWith<$Res> get end {
  
  return $ItineraryListEndCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}


/// Adds pattern-matching-related methods to [ItineraryListEntry].
extension ItineraryListEntryPatterns on ItineraryListEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryListEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryListEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryListEntry value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryListEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryListEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryListEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String date,  ItineraryListStart start,  ItineraryListEnd end,  int placeCount,  List<String> placeNames,  DateTime updatedAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryListEntry() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.start,_that.end,_that.placeCount,_that.placeNames,_that.updatedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String date,  ItineraryListStart start,  ItineraryListEnd end,  int placeCount,  List<String> placeNames,  DateTime updatedAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ItineraryListEntry():
return $default(_that.id,_that.title,_that.date,_that.start,_that.end,_that.placeCount,_that.placeNames,_that.updatedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String date,  ItineraryListStart start,  ItineraryListEnd end,  int placeCount,  List<String> placeNames,  DateTime updatedAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryListEntry() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.start,_that.end,_that.placeCount,_that.placeNames,_that.updatedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryListEntry implements ItineraryListEntry {
  const _ItineraryListEntry({required this.id, required this.title, required this.date, required this.start, required this.end, this.placeCount = 0,  List<String> placeNames = const <String>[], required this.updatedAt, this.expiresAt}): _placeNames = placeNames;
  factory _ItineraryListEntry.fromJson(Map<String, dynamic> json) => _$ItineraryListEntryFromJson(json);

@override final  String id;
@override final  String title;
/// 旅行日（YYYY-MM-DD）
@override final  String date;
@override final  ItineraryListStart start;
@override final  ItineraryListEnd end;
@override@JsonKey() final  int placeCount;
/// 行き先の名前（先頭 3 件まで）
 final  List<String> _placeNames;
/// 行き先の名前（先頭 3 件まで）
@override@JsonKey() List<String> get placeNames {
  if (_placeNames is EqualUnmodifiableListView) return _placeNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_placeNames);
}

@override final  DateTime updatedAt;
/// 自動で消える日時（一覧の「終わった旅」に出す）
@override final  DateTime? expiresAt;

/// Create a copy of ItineraryListEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryListEntryCopyWith<_ItineraryListEntry> get copyWith => __$ItineraryListEntryCopyWithImpl<_ItineraryListEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryListEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryListEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.placeCount, placeCount) || other.placeCount == placeCount)&&const DeepCollectionEquality().equals(other.placeNames, _placeNames)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,date,start,end,placeCount,const DeepCollectionEquality().hash(_placeNames),updatedAt,expiresAt);
}

@override
String toString() {
    return 'ItineraryListEntry(id: $id, title: $title, date: $date, start: $start, end: $end, placeCount: $placeCount, placeNames: $placeNames, updatedAt: $updatedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ItineraryListEntryCopyWith<$Res> implements $ItineraryListEntryCopyWith<$Res> {
  factory _$ItineraryListEntryCopyWith(_ItineraryListEntry value, $Res Function(_ItineraryListEntry) _then) = __$ItineraryListEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String date, ItineraryListStart start, ItineraryListEnd end, int placeCount, List<String> placeNames, DateTime updatedAt, DateTime? expiresAt
});


@override $ItineraryListStartCopyWith<$Res> get start;@override $ItineraryListEndCopyWith<$Res> get end;

}
/// @nodoc
class __$ItineraryListEntryCopyWithImpl<$Res>
    implements _$ItineraryListEntryCopyWith<$Res> {
  __$ItineraryListEntryCopyWithImpl(this._self, this._then);

  final _ItineraryListEntry _self;
  final $Res Function(_ItineraryListEntry) _then;

/// Create a copy of ItineraryListEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = null,Object? start = null,Object? end = null,Object? placeCount = null,Object? placeNames = null,Object? updatedAt = null,Object? expiresAt = freezed,}) {
  return _then(_ItineraryListEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as ItineraryListStart,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as ItineraryListEnd,placeCount: null == placeCount ? _self.placeCount : placeCount // ignore: cast_nullable_to_non_nullable
as int,placeNames: null == placeNames ? _self._placeNames : placeNames // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ItineraryListEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItineraryListStartCopyWith<$Res> get start {
  
  return $ItineraryListStartCopyWith<$Res>(_self.start, (value) {
    return _then(_self.copyWith(start: value));
  });
}/// Create a copy of ItineraryListEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItineraryListEndCopyWith<$Res> get end {
  
  return $ItineraryListEndCopyWith<$Res>(_self.end, (value) {
    return _then(_self.copyWith(end: value));
  });
}
}


/// @nodoc
mixin _$ItineraryPage {

 List<ItineraryListEntry> get itineraries; String? get nextCursor;
/// Create a copy of ItineraryPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItineraryPageCopyWith<ItineraryPage> get copyWith => _$ItineraryPageCopyWithImpl<ItineraryPage>(this as ItineraryPage, _$identity);

  /// Serializes this ItineraryPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ItineraryPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItineraryPage&&const DeepCollectionEquality().equals(other.itineraries, _this.itineraries)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ItineraryPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.itineraries),_this.nextCursor);
}

@override
String toString() {
  final _this = this as ItineraryPage;
  return 'ItineraryPage(itineraries: ${_this.itineraries}, nextCursor: ${_this.nextCursor})';
}


}

/// @nodoc
abstract mixin class $ItineraryPageCopyWith<$Res>  {
  factory $ItineraryPageCopyWith(ItineraryPage value, $Res Function(ItineraryPage) _then) = _$ItineraryPageCopyWithImpl;
@useResult
$Res call({
 List<ItineraryListEntry> itineraries, String? nextCursor
});




}
/// @nodoc
class _$ItineraryPageCopyWithImpl<$Res>
    implements $ItineraryPageCopyWith<$Res> {
  _$ItineraryPageCopyWithImpl(this._self, this._then);

  final ItineraryPage _self;
  final $Res Function(ItineraryPage) _then;

/// Create a copy of ItineraryPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itineraries = null,Object? nextCursor = freezed,}) {
  return _then(ItineraryPage(
itineraries: null == itineraries ? _self.itineraries : itineraries // ignore: cast_nullable_to_non_nullable
as List<ItineraryListEntry>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItineraryPage].
extension ItineraryPagePatterns on ItineraryPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItineraryPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItineraryPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItineraryPage value)  $default,){
final _that = this;
switch (_that) {
case _ItineraryPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItineraryPage value)?  $default,){
final _that = this;
switch (_that) {
case _ItineraryPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ItineraryListEntry> itineraries,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItineraryPage() when $default != null:
return $default(_that.itineraries,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ItineraryListEntry> itineraries,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _ItineraryPage():
return $default(_that.itineraries,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ItineraryListEntry> itineraries,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _ItineraryPage() when $default != null:
return $default(_that.itineraries,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItineraryPage implements ItineraryPage {
  const _ItineraryPage({ List<ItineraryListEntry> itineraries = const <ItineraryListEntry>[], this.nextCursor}): _itineraries = itineraries;
  factory _ItineraryPage.fromJson(Map<String, dynamic> json) => _$ItineraryPageFromJson(json);

 final  List<ItineraryListEntry> _itineraries;
@override@JsonKey() List<ItineraryListEntry> get itineraries {
  if (_itineraries is EqualUnmodifiableListView) return _itineraries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itineraries);
}

@override final  String? nextCursor;

/// Create a copy of ItineraryPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItineraryPageCopyWith<_ItineraryPage> get copyWith => __$ItineraryPageCopyWithImpl<_ItineraryPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItineraryPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItineraryPage&&const DeepCollectionEquality().equals(other.itineraries, _itineraries)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_itineraries),nextCursor);
}

@override
String toString() {
    return 'ItineraryPage(itineraries: $itineraries, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$ItineraryPageCopyWith<$Res> implements $ItineraryPageCopyWith<$Res> {
  factory _$ItineraryPageCopyWith(_ItineraryPage value, $Res Function(_ItineraryPage) _then) = __$ItineraryPageCopyWithImpl;
@override @useResult
$Res call({
 List<ItineraryListEntry> itineraries, String? nextCursor
});




}
/// @nodoc
class __$ItineraryPageCopyWithImpl<$Res>
    implements _$ItineraryPageCopyWith<$Res> {
  __$ItineraryPageCopyWithImpl(this._self, this._then);

  final _ItineraryPage _self;
  final $Res Function(_ItineraryPage) _then;

/// Create a copy of ItineraryPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itineraries = null,Object? nextCursor = freezed,}) {
  return _then(_ItineraryPage(
itineraries: null == itineraries ? _self._itineraries : itineraries // ignore: cast_nullable_to_non_nullable
as List<ItineraryListEntry>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
