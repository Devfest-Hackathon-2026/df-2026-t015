// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReplanWarning {

@JsonKey(unknownEnumValue: ReplanWarningType.unknown) ReplanWarningType get type; String? get itemId; String get message;
/// Create a copy of ReplanWarning
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplanWarningCopyWith<ReplanWarning> get copyWith => _$ReplanWarningCopyWithImpl<ReplanWarning>(this as ReplanWarning, _$identity);

  /// Serializes this ReplanWarning to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReplanWarning;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplanWarning&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReplanWarning;
  return Object.hash(runtimeType,_this.type,_this.itemId,_this.message);
}

@override
String toString() {
  final _this = this as ReplanWarning;
  return 'ReplanWarning(type: ${_this.type}, itemId: ${_this.itemId}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ReplanWarningCopyWith<$Res>  {
  factory $ReplanWarningCopyWith(ReplanWarning value, $Res Function(ReplanWarning) _then) = _$ReplanWarningCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: ReplanWarningType.unknown) ReplanWarningType type, String? itemId, String message
});




}
/// @nodoc
class _$ReplanWarningCopyWithImpl<$Res>
    implements $ReplanWarningCopyWith<$Res> {
  _$ReplanWarningCopyWithImpl(this._self, this._then);

  final ReplanWarning _self;
  final $Res Function(ReplanWarning) _then;

/// Create a copy of ReplanWarning
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? itemId = freezed,Object? message = null,}) {
  return _then(ReplanWarning(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReplanWarningType,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplanWarning].
extension ReplanWarningPatterns on ReplanWarning {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplanWarning value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplanWarning() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplanWarning value)  $default,){
final _that = this;
switch (_that) {
case _ReplanWarning():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplanWarning value)?  $default,){
final _that = this;
switch (_that) {
case _ReplanWarning() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ReplanWarningType.unknown)  ReplanWarningType type,  String? itemId,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplanWarning() when $default != null:
return $default(_that.type,_that.itemId,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ReplanWarningType.unknown)  ReplanWarningType type,  String? itemId,  String message)  $default,) {final _that = this;
switch (_that) {
case _ReplanWarning():
return $default(_that.type,_that.itemId,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: ReplanWarningType.unknown)  ReplanWarningType type,  String? itemId,  String message)?  $default,) {final _that = this;
switch (_that) {
case _ReplanWarning() when $default != null:
return $default(_that.type,_that.itemId,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplanWarning implements ReplanWarning {
  const _ReplanWarning({@JsonKey(unknownEnumValue: ReplanWarningType.unknown) required this.type, this.itemId, required this.message});
  factory _ReplanWarning.fromJson(Map<String, dynamic> json) => _$ReplanWarningFromJson(json);

@override@JsonKey(unknownEnumValue: ReplanWarningType.unknown) final  ReplanWarningType type;
@override final  String? itemId;
@override final  String message;

/// Create a copy of ReplanWarning
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplanWarningCopyWith<_ReplanWarning> get copyWith => __$ReplanWarningCopyWithImpl<_ReplanWarning>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplanWarningToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplanWarning&&(identical(other.type, type) || other.type == type)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,itemId,message);
}

@override
String toString() {
    return 'ReplanWarning(type: $type, itemId: $itemId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ReplanWarningCopyWith<$Res> implements $ReplanWarningCopyWith<$Res> {
  factory _$ReplanWarningCopyWith(_ReplanWarning value, $Res Function(_ReplanWarning) _then) = __$ReplanWarningCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: ReplanWarningType.unknown) ReplanWarningType type, String? itemId, String message
});




}
/// @nodoc
class __$ReplanWarningCopyWithImpl<$Res>
    implements _$ReplanWarningCopyWith<$Res> {
  __$ReplanWarningCopyWithImpl(this._self, this._then);

  final _ReplanWarning _self;
  final $Res Function(_ReplanWarning) _then;

/// Create a copy of ReplanWarning
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? itemId = freezed,Object? message = null,}) {
  return _then(_ReplanWarning(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReplanWarningType,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChangeSnapshot {

 String? get placeId; String? get name; DateTime? get startAt; DateTime? get endAt; Price? get price;
/// Create a copy of ChangeSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeSnapshotCopyWith<ChangeSnapshot> get copyWith => _$ChangeSnapshotCopyWithImpl<ChangeSnapshot>(this as ChangeSnapshot, _$identity);

  /// Serializes this ChangeSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChangeSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeSnapshot&&(identical(other.placeId, _this.placeId) || other.placeId == _this.placeId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.price, _this.price) || other.price == _this.price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChangeSnapshot;
  return Object.hash(runtimeType,_this.placeId,_this.name,_this.startAt,_this.endAt,_this.price);
}

@override
String toString() {
  final _this = this as ChangeSnapshot;
  return 'ChangeSnapshot(placeId: ${_this.placeId}, name: ${_this.name}, startAt: ${_this.startAt}, endAt: ${_this.endAt}, price: ${_this.price})';
}


}

/// @nodoc
abstract mixin class $ChangeSnapshotCopyWith<$Res>  {
  factory $ChangeSnapshotCopyWith(ChangeSnapshot value, $Res Function(ChangeSnapshot) _then) = _$ChangeSnapshotCopyWithImpl;
@useResult
$Res call({
 String? placeId, String? name, DateTime? startAt, DateTime? endAt, Price? price
});


$PriceCopyWith<$Res>? get price;

}
/// @nodoc
class _$ChangeSnapshotCopyWithImpl<$Res>
    implements $ChangeSnapshotCopyWith<$Res> {
  _$ChangeSnapshotCopyWithImpl(this._self, this._then);

  final ChangeSnapshot _self;
  final $Res Function(ChangeSnapshot) _then;

/// Create a copy of ChangeSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = freezed,Object? name = freezed,Object? startAt = freezed,Object? endAt = freezed,Object? price = freezed,}) {
  return _then(ChangeSnapshot(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price?,
  ));
}
/// Create a copy of ChangeSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChangeSnapshot].
extension ChangeSnapshotPatterns on ChangeSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ChangeSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? placeId,  String? name,  DateTime? startAt,  DateTime? endAt,  Price? price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeSnapshot() when $default != null:
return $default(_that.placeId,_that.name,_that.startAt,_that.endAt,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? placeId,  String? name,  DateTime? startAt,  DateTime? endAt,  Price? price)  $default,) {final _that = this;
switch (_that) {
case _ChangeSnapshot():
return $default(_that.placeId,_that.name,_that.startAt,_that.endAt,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? placeId,  String? name,  DateTime? startAt,  DateTime? endAt,  Price? price)?  $default,) {final _that = this;
switch (_that) {
case _ChangeSnapshot() when $default != null:
return $default(_that.placeId,_that.name,_that.startAt,_that.endAt,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeSnapshot implements ChangeSnapshot {
  const _ChangeSnapshot({this.placeId, this.name, this.startAt, this.endAt, this.price});
  factory _ChangeSnapshot.fromJson(Map<String, dynamic> json) => _$ChangeSnapshotFromJson(json);

@override final  String? placeId;
@override final  String? name;
@override final  DateTime? startAt;
@override final  DateTime? endAt;
@override final  Price? price;

/// Create a copy of ChangeSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeSnapshotCopyWith<_ChangeSnapshot> get copyWith => __$ChangeSnapshotCopyWithImpl<_ChangeSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeSnapshot&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,placeId,name,startAt,endAt,price);
}

@override
String toString() {
    return 'ChangeSnapshot(placeId: $placeId, name: $name, startAt: $startAt, endAt: $endAt, price: $price)';
}


}

/// @nodoc
abstract mixin class _$ChangeSnapshotCopyWith<$Res> implements $ChangeSnapshotCopyWith<$Res> {
  factory _$ChangeSnapshotCopyWith(_ChangeSnapshot value, $Res Function(_ChangeSnapshot) _then) = __$ChangeSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String? placeId, String? name, DateTime? startAt, DateTime? endAt, Price? price
});


@override $PriceCopyWith<$Res>? get price;

}
/// @nodoc
class __$ChangeSnapshotCopyWithImpl<$Res>
    implements _$ChangeSnapshotCopyWith<$Res> {
  __$ChangeSnapshotCopyWithImpl(this._self, this._then);

  final _ChangeSnapshot _self;
  final $Res Function(_ChangeSnapshot) _then;

/// Create a copy of ChangeSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = freezed,Object? name = freezed,Object? startAt = freezed,Object? endAt = freezed,Object? price = freezed,}) {
  return _then(_ChangeSnapshot(
placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price?,
  ));
}

/// Create a copy of ChangeSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// @nodoc
mixin _$ReplanChange {

 ChangeType get type; String get itemId; ChangeSnapshot? get before; ChangeSnapshot? get after; String? get note;
/// Create a copy of ReplanChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplanChangeCopyWith<ReplanChange> get copyWith => _$ReplanChangeCopyWithImpl<ReplanChange>(this as ReplanChange, _$identity);

  /// Serializes this ReplanChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReplanChange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplanChange&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.before, _this.before) || other.before == _this.before)&&(identical(other.after, _this.after) || other.after == _this.after)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReplanChange;
  return Object.hash(runtimeType,_this.type,_this.itemId,_this.before,_this.after,_this.note);
}

@override
String toString() {
  final _this = this as ReplanChange;
  return 'ReplanChange(type: ${_this.type}, itemId: ${_this.itemId}, before: ${_this.before}, after: ${_this.after}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $ReplanChangeCopyWith<$Res>  {
  factory $ReplanChangeCopyWith(ReplanChange value, $Res Function(ReplanChange) _then) = _$ReplanChangeCopyWithImpl;
@useResult
$Res call({
 ChangeType type, String itemId, ChangeSnapshot? before, ChangeSnapshot? after, String? note
});


$ChangeSnapshotCopyWith<$Res>? get before;$ChangeSnapshotCopyWith<$Res>? get after;

}
/// @nodoc
class _$ReplanChangeCopyWithImpl<$Res>
    implements $ReplanChangeCopyWith<$Res> {
  _$ReplanChangeCopyWithImpl(this._self, this._then);

  final ReplanChange _self;
  final $Res Function(ReplanChange) _then;

/// Create a copy of ReplanChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? itemId = null,Object? before = freezed,Object? after = freezed,Object? note = freezed,}) {
  return _then(ReplanChange(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChangeType,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,before: freezed == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as ChangeSnapshot?,after: freezed == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as ChangeSnapshot?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ReplanChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangeSnapshotCopyWith<$Res>? get before {
    if (_self.before == null) {
    return null;
  }

  return $ChangeSnapshotCopyWith<$Res>(_self.before!, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of ReplanChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangeSnapshotCopyWith<$Res>? get after {
    if (_self.after == null) {
    return null;
  }

  return $ChangeSnapshotCopyWith<$Res>(_self.after!, (value) {
    return _then(_self.copyWith(after: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReplanChange].
extension ReplanChangePatterns on ReplanChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplanChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplanChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplanChange value)  $default,){
final _that = this;
switch (_that) {
case _ReplanChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplanChange value)?  $default,){
final _that = this;
switch (_that) {
case _ReplanChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChangeType type,  String itemId,  ChangeSnapshot? before,  ChangeSnapshot? after,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplanChange() when $default != null:
return $default(_that.type,_that.itemId,_that.before,_that.after,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChangeType type,  String itemId,  ChangeSnapshot? before,  ChangeSnapshot? after,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ReplanChange():
return $default(_that.type,_that.itemId,_that.before,_that.after,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChangeType type,  String itemId,  ChangeSnapshot? before,  ChangeSnapshot? after,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ReplanChange() when $default != null:
return $default(_that.type,_that.itemId,_that.before,_that.after,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplanChange implements ReplanChange {
  const _ReplanChange({required this.type, required this.itemId, this.before, this.after, this.note});
  factory _ReplanChange.fromJson(Map<String, dynamic> json) => _$ReplanChangeFromJson(json);

@override final  ChangeType type;
@override final  String itemId;
@override final  ChangeSnapshot? before;
@override final  ChangeSnapshot? after;
@override final  String? note;

/// Create a copy of ReplanChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplanChangeCopyWith<_ReplanChange> get copyWith => __$ReplanChangeCopyWithImpl<_ReplanChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplanChangeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplanChange&&(identical(other.type, type) || other.type == type)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.before, before) || other.before == before)&&(identical(other.after, after) || other.after == after)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,itemId,before,after,note);
}

@override
String toString() {
    return 'ReplanChange(type: $type, itemId: $itemId, before: $before, after: $after, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ReplanChangeCopyWith<$Res> implements $ReplanChangeCopyWith<$Res> {
  factory _$ReplanChangeCopyWith(_ReplanChange value, $Res Function(_ReplanChange) _then) = __$ReplanChangeCopyWithImpl;
@override @useResult
$Res call({
 ChangeType type, String itemId, ChangeSnapshot? before, ChangeSnapshot? after, String? note
});


@override $ChangeSnapshotCopyWith<$Res>? get before;@override $ChangeSnapshotCopyWith<$Res>? get after;

}
/// @nodoc
class __$ReplanChangeCopyWithImpl<$Res>
    implements _$ReplanChangeCopyWith<$Res> {
  __$ReplanChangeCopyWithImpl(this._self, this._then);

  final _ReplanChange _self;
  final $Res Function(_ReplanChange) _then;

/// Create a copy of ReplanChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? itemId = null,Object? before = freezed,Object? after = freezed,Object? note = freezed,}) {
  return _then(_ReplanChange(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChangeType,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,before: freezed == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as ChangeSnapshot?,after: freezed == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as ChangeSnapshot?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ReplanChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangeSnapshotCopyWith<$Res>? get before {
    if (_self.before == null) {
    return null;
  }

  return $ChangeSnapshotCopyWith<$Res>(_self.before!, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of ReplanChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChangeSnapshotCopyWith<$Res>? get after {
    if (_self.after == null) {
    return null;
  }

  return $ChangeSnapshotCopyWith<$Res>(_self.after!, (value) {
    return _then(_self.copyWith(after: value));
  });
}
}


/// @nodoc
mixin _$ReplanPreview {

 List<Item> get items; List<Leg> get legs;
/// Create a copy of ReplanPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplanPreviewCopyWith<ReplanPreview> get copyWith => _$ReplanPreviewCopyWithImpl<ReplanPreview>(this as ReplanPreview, _$identity);

  /// Serializes this ReplanPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReplanPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplanPreview&&const DeepCollectionEquality().equals(other.items, _this.items)&&const DeepCollectionEquality().equals(other.legs, _this.legs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReplanPreview;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),const DeepCollectionEquality().hash(_this.legs));
}

@override
String toString() {
  final _this = this as ReplanPreview;
  return 'ReplanPreview(items: ${_this.items}, legs: ${_this.legs})';
}


}

/// @nodoc
abstract mixin class $ReplanPreviewCopyWith<$Res>  {
  factory $ReplanPreviewCopyWith(ReplanPreview value, $Res Function(ReplanPreview) _then) = _$ReplanPreviewCopyWithImpl;
@useResult
$Res call({
 List<Item> items, List<Leg> legs
});




}
/// @nodoc
class _$ReplanPreviewCopyWithImpl<$Res>
    implements $ReplanPreviewCopyWith<$Res> {
  _$ReplanPreviewCopyWithImpl(this._self, this._then);

  final ReplanPreview _self;
  final $Res Function(ReplanPreview) _then;

/// Create a copy of ReplanPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? legs = null,}) {
  return _then(ReplanPreview(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,legs: null == legs ? _self.legs : legs // ignore: cast_nullable_to_non_nullable
as List<Leg>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplanPreview].
extension ReplanPreviewPatterns on ReplanPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplanPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplanPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplanPreview value)  $default,){
final _that = this;
switch (_that) {
case _ReplanPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplanPreview value)?  $default,){
final _that = this;
switch (_that) {
case _ReplanPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Item> items,  List<Leg> legs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplanPreview() when $default != null:
return $default(_that.items,_that.legs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Item> items,  List<Leg> legs)  $default,) {final _that = this;
switch (_that) {
case _ReplanPreview():
return $default(_that.items,_that.legs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Item> items,  List<Leg> legs)?  $default,) {final _that = this;
switch (_that) {
case _ReplanPreview() when $default != null:
return $default(_that.items,_that.legs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplanPreview implements ReplanPreview {
  const _ReplanPreview({ List<Item> items = const <Item>[],  List<Leg> legs = const <Leg>[]}): _items = items,_legs = legs;
  factory _ReplanPreview.fromJson(Map<String, dynamic> json) => _$ReplanPreviewFromJson(json);

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


/// Create a copy of ReplanPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplanPreviewCopyWith<_ReplanPreview> get copyWith => __$ReplanPreviewCopyWithImpl<_ReplanPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplanPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplanPreview&&const DeepCollectionEquality().equals(other.items, _items)&&const DeepCollectionEquality().equals(other.legs, _legs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_legs));
}

@override
String toString() {
    return 'ReplanPreview(items: $items, legs: $legs)';
}


}

/// @nodoc
abstract mixin class _$ReplanPreviewCopyWith<$Res> implements $ReplanPreviewCopyWith<$Res> {
  factory _$ReplanPreviewCopyWith(_ReplanPreview value, $Res Function(_ReplanPreview) _then) = __$ReplanPreviewCopyWithImpl;
@override @useResult
$Res call({
 List<Item> items, List<Leg> legs
});




}
/// @nodoc
class __$ReplanPreviewCopyWithImpl<$Res>
    implements _$ReplanPreviewCopyWith<$Res> {
  __$ReplanPreviewCopyWithImpl(this._self, this._then);

  final _ReplanPreview _self;
  final $Res Function(_ReplanPreview) _then;

/// Create a copy of ReplanPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? legs = null,}) {
  return _then(_ReplanPreview(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,legs: null == legs ? _self._legs : legs // ignore: cast_nullable_to_non_nullable
as List<Leg>,
  ));
}


}


/// @nodoc
mixin _$ReplanOption {

 String get optionId; List<ReplanChange> get changes; Summary get summaryBefore; Summary get summaryAfter; ReplanPreview get preview;
/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplanOptionCopyWith<ReplanOption> get copyWith => _$ReplanOptionCopyWithImpl<ReplanOption>(this as ReplanOption, _$identity);

  /// Serializes this ReplanOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReplanOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplanOption&&(identical(other.optionId, _this.optionId) || other.optionId == _this.optionId)&&const DeepCollectionEquality().equals(other.changes, _this.changes)&&(identical(other.summaryBefore, _this.summaryBefore) || other.summaryBefore == _this.summaryBefore)&&(identical(other.summaryAfter, _this.summaryAfter) || other.summaryAfter == _this.summaryAfter)&&(identical(other.preview, _this.preview) || other.preview == _this.preview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReplanOption;
  return Object.hash(runtimeType,_this.optionId,const DeepCollectionEquality().hash(_this.changes),_this.summaryBefore,_this.summaryAfter,_this.preview);
}

@override
String toString() {
  final _this = this as ReplanOption;
  return 'ReplanOption(optionId: ${_this.optionId}, changes: ${_this.changes}, summaryBefore: ${_this.summaryBefore}, summaryAfter: ${_this.summaryAfter}, preview: ${_this.preview})';
}


}

/// @nodoc
abstract mixin class $ReplanOptionCopyWith<$Res>  {
  factory $ReplanOptionCopyWith(ReplanOption value, $Res Function(ReplanOption) _then) = _$ReplanOptionCopyWithImpl;
@useResult
$Res call({
 String optionId, List<ReplanChange> changes, Summary summaryBefore, Summary summaryAfter, ReplanPreview preview
});


$SummaryCopyWith<$Res> get summaryBefore;$SummaryCopyWith<$Res> get summaryAfter;$ReplanPreviewCopyWith<$Res> get preview;

}
/// @nodoc
class _$ReplanOptionCopyWithImpl<$Res>
    implements $ReplanOptionCopyWith<$Res> {
  _$ReplanOptionCopyWithImpl(this._self, this._then);

  final ReplanOption _self;
  final $Res Function(ReplanOption) _then;

/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? optionId = null,Object? changes = null,Object? summaryBefore = null,Object? summaryAfter = null,Object? preview = null,}) {
  return _then(ReplanOption(
optionId: null == optionId ? _self.optionId : optionId // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<ReplanChange>,summaryBefore: null == summaryBefore ? _self.summaryBefore : summaryBefore // ignore: cast_nullable_to_non_nullable
as Summary,summaryAfter: null == summaryAfter ? _self.summaryAfter : summaryAfter // ignore: cast_nullable_to_non_nullable
as Summary,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as ReplanPreview,
  ));
}
/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res> get summaryBefore {
  
  return $SummaryCopyWith<$Res>(_self.summaryBefore, (value) {
    return _then(_self.copyWith(summaryBefore: value));
  });
}/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res> get summaryAfter {
  
  return $SummaryCopyWith<$Res>(_self.summaryAfter, (value) {
    return _then(_self.copyWith(summaryAfter: value));
  });
}/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReplanPreviewCopyWith<$Res> get preview {
  
  return $ReplanPreviewCopyWith<$Res>(_self.preview, (value) {
    return _then(_self.copyWith(preview: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReplanOption].
extension ReplanOptionPatterns on ReplanOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplanOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplanOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplanOption value)  $default,){
final _that = this;
switch (_that) {
case _ReplanOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplanOption value)?  $default,){
final _that = this;
switch (_that) {
case _ReplanOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String optionId,  List<ReplanChange> changes,  Summary summaryBefore,  Summary summaryAfter,  ReplanPreview preview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplanOption() when $default != null:
return $default(_that.optionId,_that.changes,_that.summaryBefore,_that.summaryAfter,_that.preview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String optionId,  List<ReplanChange> changes,  Summary summaryBefore,  Summary summaryAfter,  ReplanPreview preview)  $default,) {final _that = this;
switch (_that) {
case _ReplanOption():
return $default(_that.optionId,_that.changes,_that.summaryBefore,_that.summaryAfter,_that.preview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String optionId,  List<ReplanChange> changes,  Summary summaryBefore,  Summary summaryAfter,  ReplanPreview preview)?  $default,) {final _that = this;
switch (_that) {
case _ReplanOption() when $default != null:
return $default(_that.optionId,_that.changes,_that.summaryBefore,_that.summaryAfter,_that.preview);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplanOption implements ReplanOption {
  const _ReplanOption({required this.optionId,  List<ReplanChange> changes = const <ReplanChange>[], required this.summaryBefore, required this.summaryAfter, this.preview = const ReplanPreview()}): _changes = changes;
  factory _ReplanOption.fromJson(Map<String, dynamic> json) => _$ReplanOptionFromJson(json);

@override final  String optionId;
 final  List<ReplanChange> _changes;
@override@JsonKey() List<ReplanChange> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}

@override final  Summary summaryBefore;
@override final  Summary summaryAfter;
@override@JsonKey() final  ReplanPreview preview;

/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplanOptionCopyWith<_ReplanOption> get copyWith => __$ReplanOptionCopyWithImpl<_ReplanOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplanOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplanOption&&(identical(other.optionId, optionId) || other.optionId == optionId)&&const DeepCollectionEquality().equals(other.changes, _changes)&&(identical(other.summaryBefore, summaryBefore) || other.summaryBefore == summaryBefore)&&(identical(other.summaryAfter, summaryAfter) || other.summaryAfter == summaryAfter)&&(identical(other.preview, preview) || other.preview == preview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,optionId,const DeepCollectionEquality().hash(_changes),summaryBefore,summaryAfter,preview);
}

@override
String toString() {
    return 'ReplanOption(optionId: $optionId, changes: $changes, summaryBefore: $summaryBefore, summaryAfter: $summaryAfter, preview: $preview)';
}


}

/// @nodoc
abstract mixin class _$ReplanOptionCopyWith<$Res> implements $ReplanOptionCopyWith<$Res> {
  factory _$ReplanOptionCopyWith(_ReplanOption value, $Res Function(_ReplanOption) _then) = __$ReplanOptionCopyWithImpl;
@override @useResult
$Res call({
 String optionId, List<ReplanChange> changes, Summary summaryBefore, Summary summaryAfter, ReplanPreview preview
});


@override $SummaryCopyWith<$Res> get summaryBefore;@override $SummaryCopyWith<$Res> get summaryAfter;@override $ReplanPreviewCopyWith<$Res> get preview;

}
/// @nodoc
class __$ReplanOptionCopyWithImpl<$Res>
    implements _$ReplanOptionCopyWith<$Res> {
  __$ReplanOptionCopyWithImpl(this._self, this._then);

  final _ReplanOption _self;
  final $Res Function(_ReplanOption) _then;

/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? optionId = null,Object? changes = null,Object? summaryBefore = null,Object? summaryAfter = null,Object? preview = null,}) {
  return _then(_ReplanOption(
optionId: null == optionId ? _self.optionId : optionId // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<ReplanChange>,summaryBefore: null == summaryBefore ? _self.summaryBefore : summaryBefore // ignore: cast_nullable_to_non_nullable
as Summary,summaryAfter: null == summaryAfter ? _self.summaryAfter : summaryAfter // ignore: cast_nullable_to_non_nullable
as Summary,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as ReplanPreview,
  ));
}

/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res> get summaryBefore {
  
  return $SummaryCopyWith<$Res>(_self.summaryBefore, (value) {
    return _then(_self.copyWith(summaryBefore: value));
  });
}/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SummaryCopyWith<$Res> get summaryAfter {
  
  return $SummaryCopyWith<$Res>(_self.summaryAfter, (value) {
    return _then(_self.copyWith(summaryAfter: value));
  });
}/// Create a copy of ReplanOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReplanPreviewCopyWith<$Res> get preview {
  
  return $ReplanPreviewCopyWith<$Res>(_self.preview, (value) {
    return _then(_self.copyWith(preview: value));
  });
}
}


/// @nodoc
mixin _$Explanation {

@JsonKey(unknownEnumValue: ExplanationStatus.failed) ExplanationStatus get status; String? get text;
/// Create a copy of Explanation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExplanationCopyWith<Explanation> get copyWith => _$ExplanationCopyWithImpl<Explanation>(this as Explanation, _$identity);

  /// Serializes this Explanation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Explanation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Explanation&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.text, _this.text) || other.text == _this.text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Explanation;
  return Object.hash(runtimeType,_this.status,_this.text);
}

@override
String toString() {
  final _this = this as Explanation;
  return 'Explanation(status: ${_this.status}, text: ${_this.text})';
}


}

/// @nodoc
abstract mixin class $ExplanationCopyWith<$Res>  {
  factory $ExplanationCopyWith(Explanation value, $Res Function(Explanation) _then) = _$ExplanationCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: ExplanationStatus.failed) ExplanationStatus status, String? text
});




}
/// @nodoc
class _$ExplanationCopyWithImpl<$Res>
    implements $ExplanationCopyWith<$Res> {
  _$ExplanationCopyWithImpl(this._self, this._then);

  final Explanation _self;
  final $Res Function(Explanation) _then;

/// Create a copy of Explanation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? text = freezed,}) {
  return _then(Explanation(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExplanationStatus,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Explanation].
extension ExplanationPatterns on Explanation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Explanation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Explanation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Explanation value)  $default,){
final _that = this;
switch (_that) {
case _Explanation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Explanation value)?  $default,){
final _that = this;
switch (_that) {
case _Explanation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ExplanationStatus.failed)  ExplanationStatus status,  String? text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Explanation() when $default != null:
return $default(_that.status,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ExplanationStatus.failed)  ExplanationStatus status,  String? text)  $default,) {final _that = this;
switch (_that) {
case _Explanation():
return $default(_that.status,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: ExplanationStatus.failed)  ExplanationStatus status,  String? text)?  $default,) {final _that = this;
switch (_that) {
case _Explanation() when $default != null:
return $default(_that.status,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Explanation implements Explanation {
  const _Explanation({@JsonKey(unknownEnumValue: ExplanationStatus.failed) required this.status, this.text});
  factory _Explanation.fromJson(Map<String, dynamic> json) => _$ExplanationFromJson(json);

@override@JsonKey(unknownEnumValue: ExplanationStatus.failed) final  ExplanationStatus status;
@override final  String? text;

/// Create a copy of Explanation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExplanationCopyWith<_Explanation> get copyWith => __$ExplanationCopyWithImpl<_Explanation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExplanationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Explanation&&(identical(other.status, status) || other.status == status)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,text);
}

@override
String toString() {
    return 'Explanation(status: $status, text: $text)';
}


}

/// @nodoc
abstract mixin class _$ExplanationCopyWith<$Res> implements $ExplanationCopyWith<$Res> {
  factory _$ExplanationCopyWith(_Explanation value, $Res Function(_Explanation) _then) = __$ExplanationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: ExplanationStatus.failed) ExplanationStatus status, String? text
});




}
/// @nodoc
class __$ExplanationCopyWithImpl<$Res>
    implements _$ExplanationCopyWith<$Res> {
  __$ExplanationCopyWithImpl(this._self, this._then);

  final _Explanation _self;
  final $Res Function(_Explanation) _then;

/// Create a copy of Explanation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? text = freezed,}) {
  return _then(_Explanation(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExplanationStatus,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReplanResult {

 String? get replanId; int? get basedOnVersion; bool get needsChange; DateTime? get expiresAt; List<ReplanWarning> get warnings; List<ReplanOption> get options; Explanation? get explanation;
/// Create a copy of ReplanResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplanResultCopyWith<ReplanResult> get copyWith => _$ReplanResultCopyWithImpl<ReplanResult>(this as ReplanResult, _$identity);

  /// Serializes this ReplanResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReplanResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplanResult&&(identical(other.replanId, _this.replanId) || other.replanId == _this.replanId)&&(identical(other.basedOnVersion, _this.basedOnVersion) || other.basedOnVersion == _this.basedOnVersion)&&(identical(other.needsChange, _this.needsChange) || other.needsChange == _this.needsChange)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&const DeepCollectionEquality().equals(other.warnings, _this.warnings)&&const DeepCollectionEquality().equals(other.options, _this.options)&&(identical(other.explanation, _this.explanation) || other.explanation == _this.explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReplanResult;
  return Object.hash(runtimeType,_this.replanId,_this.basedOnVersion,_this.needsChange,_this.expiresAt,const DeepCollectionEquality().hash(_this.warnings),const DeepCollectionEquality().hash(_this.options),_this.explanation);
}

@override
String toString() {
  final _this = this as ReplanResult;
  return 'ReplanResult(replanId: ${_this.replanId}, basedOnVersion: ${_this.basedOnVersion}, needsChange: ${_this.needsChange}, expiresAt: ${_this.expiresAt}, warnings: ${_this.warnings}, options: ${_this.options}, explanation: ${_this.explanation})';
}


}

/// @nodoc
abstract mixin class $ReplanResultCopyWith<$Res>  {
  factory $ReplanResultCopyWith(ReplanResult value, $Res Function(ReplanResult) _then) = _$ReplanResultCopyWithImpl;
@useResult
$Res call({
 String? replanId, int? basedOnVersion, bool needsChange, DateTime? expiresAt, List<ReplanWarning> warnings, List<ReplanOption> options, Explanation? explanation
});


$ExplanationCopyWith<$Res>? get explanation;

}
/// @nodoc
class _$ReplanResultCopyWithImpl<$Res>
    implements $ReplanResultCopyWith<$Res> {
  _$ReplanResultCopyWithImpl(this._self, this._then);

  final ReplanResult _self;
  final $Res Function(ReplanResult) _then;

/// Create a copy of ReplanResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? replanId = freezed,Object? basedOnVersion = freezed,Object? needsChange = null,Object? expiresAt = freezed,Object? warnings = null,Object? options = null,Object? explanation = freezed,}) {
  return _then(ReplanResult(
replanId: freezed == replanId ? _self.replanId : replanId // ignore: cast_nullable_to_non_nullable
as String?,basedOnVersion: freezed == basedOnVersion ? _self.basedOnVersion : basedOnVersion // ignore: cast_nullable_to_non_nullable
as int?,needsChange: null == needsChange ? _self.needsChange : needsChange // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<ReplanWarning>,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<ReplanOption>,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as Explanation?,
  ));
}
/// Create a copy of ReplanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExplanationCopyWith<$Res>? get explanation {
    if (_self.explanation == null) {
    return null;
  }

  return $ExplanationCopyWith<$Res>(_self.explanation!, (value) {
    return _then(_self.copyWith(explanation: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReplanResult].
extension ReplanResultPatterns on ReplanResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplanResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplanResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplanResult value)  $default,){
final _that = this;
switch (_that) {
case _ReplanResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplanResult value)?  $default,){
final _that = this;
switch (_that) {
case _ReplanResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? replanId,  int? basedOnVersion,  bool needsChange,  DateTime? expiresAt,  List<ReplanWarning> warnings,  List<ReplanOption> options,  Explanation? explanation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplanResult() when $default != null:
return $default(_that.replanId,_that.basedOnVersion,_that.needsChange,_that.expiresAt,_that.warnings,_that.options,_that.explanation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? replanId,  int? basedOnVersion,  bool needsChange,  DateTime? expiresAt,  List<ReplanWarning> warnings,  List<ReplanOption> options,  Explanation? explanation)  $default,) {final _that = this;
switch (_that) {
case _ReplanResult():
return $default(_that.replanId,_that.basedOnVersion,_that.needsChange,_that.expiresAt,_that.warnings,_that.options,_that.explanation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? replanId,  int? basedOnVersion,  bool needsChange,  DateTime? expiresAt,  List<ReplanWarning> warnings,  List<ReplanOption> options,  Explanation? explanation)?  $default,) {final _that = this;
switch (_that) {
case _ReplanResult() when $default != null:
return $default(_that.replanId,_that.basedOnVersion,_that.needsChange,_that.expiresAt,_that.warnings,_that.options,_that.explanation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplanResult implements ReplanResult {
  const _ReplanResult({this.replanId, this.basedOnVersion, required this.needsChange, this.expiresAt,  List<ReplanWarning> warnings = const <ReplanWarning>[],  List<ReplanOption> options = const <ReplanOption>[], this.explanation}): _warnings = warnings,_options = options;
  factory _ReplanResult.fromJson(Map<String, dynamic> json) => _$ReplanResultFromJson(json);

@override final  String? replanId;
@override final  int? basedOnVersion;
@override final  bool needsChange;
@override final  DateTime? expiresAt;
 final  List<ReplanWarning> _warnings;
@override@JsonKey() List<ReplanWarning> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}

 final  List<ReplanOption> _options;
@override@JsonKey() List<ReplanOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override final  Explanation? explanation;

/// Create a copy of ReplanResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplanResultCopyWith<_ReplanResult> get copyWith => __$ReplanResultCopyWithImpl<_ReplanResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplanResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplanResult&&(identical(other.replanId, replanId) || other.replanId == replanId)&&(identical(other.basedOnVersion, basedOnVersion) || other.basedOnVersion == basedOnVersion)&&(identical(other.needsChange, needsChange) || other.needsChange == needsChange)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.warnings, _warnings)&&const DeepCollectionEquality().equals(other.options, _options)&&(identical(other.explanation, explanation) || other.explanation == explanation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,replanId,basedOnVersion,needsChange,expiresAt,const DeepCollectionEquality().hash(_warnings),const DeepCollectionEquality().hash(_options),explanation);
}

@override
String toString() {
    return 'ReplanResult(replanId: $replanId, basedOnVersion: $basedOnVersion, needsChange: $needsChange, expiresAt: $expiresAt, warnings: $warnings, options: $options, explanation: $explanation)';
}


}

/// @nodoc
abstract mixin class _$ReplanResultCopyWith<$Res> implements $ReplanResultCopyWith<$Res> {
  factory _$ReplanResultCopyWith(_ReplanResult value, $Res Function(_ReplanResult) _then) = __$ReplanResultCopyWithImpl;
@override @useResult
$Res call({
 String? replanId, int? basedOnVersion, bool needsChange, DateTime? expiresAt, List<ReplanWarning> warnings, List<ReplanOption> options, Explanation? explanation
});


@override $ExplanationCopyWith<$Res>? get explanation;

}
/// @nodoc
class __$ReplanResultCopyWithImpl<$Res>
    implements _$ReplanResultCopyWith<$Res> {
  __$ReplanResultCopyWithImpl(this._self, this._then);

  final _ReplanResult _self;
  final $Res Function(_ReplanResult) _then;

/// Create a copy of ReplanResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? replanId = freezed,Object? basedOnVersion = freezed,Object? needsChange = null,Object? expiresAt = freezed,Object? warnings = null,Object? options = null,Object? explanation = freezed,}) {
  return _then(_ReplanResult(
replanId: freezed == replanId ? _self.replanId : replanId // ignore: cast_nullable_to_non_nullable
as String?,basedOnVersion: freezed == basedOnVersion ? _self.basedOnVersion : basedOnVersion // ignore: cast_nullable_to_non_nullable
as int?,needsChange: null == needsChange ? _self.needsChange : needsChange // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<ReplanWarning>,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<ReplanOption>,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as Explanation?,
  ));
}

/// Create a copy of ReplanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExplanationCopyWith<$Res>? get explanation {
    if (_self.explanation == null) {
    return null;
  }

  return $ExplanationCopyWith<$Res>(_self.explanation!, (value) {
    return _then(_self.copyWith(explanation: value));
  });
}
}

// dart format on
