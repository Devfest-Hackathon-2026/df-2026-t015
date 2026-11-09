// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LegFromPrev {

 TransitMode get mode; int get durationMin;
/// Create a copy of LegFromPrev
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegFromPrevCopyWith<LegFromPrev> get copyWith => _$LegFromPrevCopyWithImpl<LegFromPrev>(this as LegFromPrev, _$identity);

  /// Serializes this LegFromPrev to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LegFromPrev;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegFromPrev&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.durationMin, _this.durationMin) || other.durationMin == _this.durationMin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LegFromPrev;
  return Object.hash(runtimeType,_this.mode,_this.durationMin);
}

@override
String toString() {
  final _this = this as LegFromPrev;
  return 'LegFromPrev(mode: ${_this.mode}, durationMin: ${_this.durationMin})';
}


}

/// @nodoc
abstract mixin class $LegFromPrevCopyWith<$Res>  {
  factory $LegFromPrevCopyWith(LegFromPrev value, $Res Function(LegFromPrev) _then) = _$LegFromPrevCopyWithImpl;
@useResult
$Res call({
 TransitMode mode, int durationMin
});




}
/// @nodoc
class _$LegFromPrevCopyWithImpl<$Res>
    implements $LegFromPrevCopyWith<$Res> {
  _$LegFromPrevCopyWithImpl(this._self, this._then);

  final LegFromPrev _self;
  final $Res Function(LegFromPrev) _then;

/// Create a copy of LegFromPrev
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? durationMin = null,}) {
  return _then(LegFromPrev(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as TransitMode,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LegFromPrev].
extension LegFromPrevPatterns on LegFromPrev {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LegFromPrev value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LegFromPrev() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LegFromPrev value)  $default,){
final _that = this;
switch (_that) {
case _LegFromPrev():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LegFromPrev value)?  $default,){
final _that = this;
switch (_that) {
case _LegFromPrev() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TransitMode mode,  int durationMin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LegFromPrev() when $default != null:
return $default(_that.mode,_that.durationMin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TransitMode mode,  int durationMin)  $default,) {final _that = this;
switch (_that) {
case _LegFromPrev():
return $default(_that.mode,_that.durationMin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TransitMode mode,  int durationMin)?  $default,) {final _that = this;
switch (_that) {
case _LegFromPrev() when $default != null:
return $default(_that.mode,_that.durationMin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LegFromPrev implements LegFromPrev {
  const _LegFromPrev({required this.mode, required this.durationMin});
  factory _LegFromPrev.fromJson(Map<String, dynamic> json) => _$LegFromPrevFromJson(json);

@override final  TransitMode mode;
@override final  int durationMin;

/// Create a copy of LegFromPrev
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LegFromPrevCopyWith<_LegFromPrev> get copyWith => __$LegFromPrevCopyWithImpl<_LegFromPrev>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LegFromPrevToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LegFromPrev&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.durationMin, durationMin) || other.durationMin == durationMin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mode,durationMin);
}

@override
String toString() {
    return 'LegFromPrev(mode: $mode, durationMin: $durationMin)';
}


}

/// @nodoc
abstract mixin class _$LegFromPrevCopyWith<$Res> implements $LegFromPrevCopyWith<$Res> {
  factory _$LegFromPrevCopyWith(_LegFromPrev value, $Res Function(_LegFromPrev) _then) = __$LegFromPrevCopyWithImpl;
@override @useResult
$Res call({
 TransitMode mode, int durationMin
});




}
/// @nodoc
class __$LegFromPrevCopyWithImpl<$Res>
    implements _$LegFromPrevCopyWith<$Res> {
  __$LegFromPrevCopyWithImpl(this._self, this._then);

  final _LegFromPrev _self;
  final $Res Function(_LegFromPrev) _then;

/// Create a copy of LegFromPrev
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? durationMin = null,}) {
  return _then(_LegFromPrev(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as TransitMode,durationMin: null == durationMin ? _self.durationMin : durationMin // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Suggestion {

 Place get place; String get reason; int get stayMin; Price get price; String? get insertAfterItemId; LegFromPrev? get legFromPrev;
/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestionCopyWith<Suggestion> get copyWith => _$SuggestionCopyWithImpl<Suggestion>(this as Suggestion, _$identity);

  /// Serializes this Suggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Suggestion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Suggestion&&(identical(other.place, _this.place) || other.place == _this.place)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.stayMin, _this.stayMin) || other.stayMin == _this.stayMin)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.insertAfterItemId, _this.insertAfterItemId) || other.insertAfterItemId == _this.insertAfterItemId)&&(identical(other.legFromPrev, _this.legFromPrev) || other.legFromPrev == _this.legFromPrev));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Suggestion;
  return Object.hash(runtimeType,_this.place,_this.reason,_this.stayMin,_this.price,_this.insertAfterItemId,_this.legFromPrev);
}

@override
String toString() {
  final _this = this as Suggestion;
  return 'Suggestion(place: ${_this.place}, reason: ${_this.reason}, stayMin: ${_this.stayMin}, price: ${_this.price}, insertAfterItemId: ${_this.insertAfterItemId}, legFromPrev: ${_this.legFromPrev})';
}


}

/// @nodoc
abstract mixin class $SuggestionCopyWith<$Res>  {
  factory $SuggestionCopyWith(Suggestion value, $Res Function(Suggestion) _then) = _$SuggestionCopyWithImpl;
@useResult
$Res call({
 Place place, String reason, int stayMin, Price price, String? insertAfterItemId, LegFromPrev? legFromPrev
});


$PlaceCopyWith<$Res> get place;$PriceCopyWith<$Res> get price;$LegFromPrevCopyWith<$Res>? get legFromPrev;

}
/// @nodoc
class _$SuggestionCopyWithImpl<$Res>
    implements $SuggestionCopyWith<$Res> {
  _$SuggestionCopyWithImpl(this._self, this._then);

  final Suggestion _self;
  final $Res Function(Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? place = null,Object? reason = null,Object? stayMin = null,Object? price = null,Object? insertAfterItemId = freezed,Object? legFromPrev = freezed,}) {
  return _then(Suggestion(
place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as Place,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,stayMin: null == stayMin ? _self.stayMin : stayMin // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,insertAfterItemId: freezed == insertAfterItemId ? _self.insertAfterItemId : insertAfterItemId // ignore: cast_nullable_to_non_nullable
as String?,legFromPrev: freezed == legFromPrev ? _self.legFromPrev : legFromPrev // ignore: cast_nullable_to_non_nullable
as LegFromPrev?,
  ));
}
/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get place {
  
  return $PlaceCopyWith<$Res>(_self.place, (value) {
    return _then(_self.copyWith(place: value));
  });
}/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LegFromPrevCopyWith<$Res>? get legFromPrev {
    if (_self.legFromPrev == null) {
    return null;
  }

  return $LegFromPrevCopyWith<$Res>(_self.legFromPrev!, (value) {
    return _then(_self.copyWith(legFromPrev: value));
  });
}
}


/// Adds pattern-matching-related methods to [Suggestion].
extension SuggestionPatterns on Suggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Suggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Suggestion value)  $default,){
final _that = this;
switch (_that) {
case _Suggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Suggestion value)?  $default,){
final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Place place,  String reason,  int stayMin,  Price price,  String? insertAfterItemId,  LegFromPrev? legFromPrev)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.place,_that.reason,_that.stayMin,_that.price,_that.insertAfterItemId,_that.legFromPrev);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Place place,  String reason,  int stayMin,  Price price,  String? insertAfterItemId,  LegFromPrev? legFromPrev)  $default,) {final _that = this;
switch (_that) {
case _Suggestion():
return $default(_that.place,_that.reason,_that.stayMin,_that.price,_that.insertAfterItemId,_that.legFromPrev);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Place place,  String reason,  int stayMin,  Price price,  String? insertAfterItemId,  LegFromPrev? legFromPrev)?  $default,) {final _that = this;
switch (_that) {
case _Suggestion() when $default != null:
return $default(_that.place,_that.reason,_that.stayMin,_that.price,_that.insertAfterItemId,_that.legFromPrev);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Suggestion implements Suggestion {
  const _Suggestion({required this.place, required this.reason, required this.stayMin, this.price = const Price(), this.insertAfterItemId, this.legFromPrev});
  factory _Suggestion.fromJson(Map<String, dynamic> json) => _$SuggestionFromJson(json);

@override final  Place place;
@override final  String reason;
@override final  int stayMin;
@override@JsonKey() final  Price price;
@override final  String? insertAfterItemId;
@override final  LegFromPrev? legFromPrev;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestionCopyWith<_Suggestion> get copyWith => __$SuggestionCopyWithImpl<_Suggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Suggestion&&(identical(other.place, place) || other.place == place)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.stayMin, stayMin) || other.stayMin == stayMin)&&(identical(other.price, price) || other.price == price)&&(identical(other.insertAfterItemId, insertAfterItemId) || other.insertAfterItemId == insertAfterItemId)&&(identical(other.legFromPrev, legFromPrev) || other.legFromPrev == legFromPrev));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,place,reason,stayMin,price,insertAfterItemId,legFromPrev);
}

@override
String toString() {
    return 'Suggestion(place: $place, reason: $reason, stayMin: $stayMin, price: $price, insertAfterItemId: $insertAfterItemId, legFromPrev: $legFromPrev)';
}


}

/// @nodoc
abstract mixin class _$SuggestionCopyWith<$Res> implements $SuggestionCopyWith<$Res> {
  factory _$SuggestionCopyWith(_Suggestion value, $Res Function(_Suggestion) _then) = __$SuggestionCopyWithImpl;
@override @useResult
$Res call({
 Place place, String reason, int stayMin, Price price, String? insertAfterItemId, LegFromPrev? legFromPrev
});


@override $PlaceCopyWith<$Res> get place;@override $PriceCopyWith<$Res> get price;@override $LegFromPrevCopyWith<$Res>? get legFromPrev;

}
/// @nodoc
class __$SuggestionCopyWithImpl<$Res>
    implements _$SuggestionCopyWith<$Res> {
  __$SuggestionCopyWithImpl(this._self, this._then);

  final _Suggestion _self;
  final $Res Function(_Suggestion) _then;

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? place = null,Object? reason = null,Object? stayMin = null,Object? price = null,Object? insertAfterItemId = freezed,Object? legFromPrev = freezed,}) {
  return _then(_Suggestion(
place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as Place,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,stayMin: null == stayMin ? _self.stayMin : stayMin // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price,insertAfterItemId: freezed == insertAfterItemId ? _self.insertAfterItemId : insertAfterItemId // ignore: cast_nullable_to_non_nullable
as String?,legFromPrev: freezed == legFromPrev ? _self.legFromPrev : legFromPrev // ignore: cast_nullable_to_non_nullable
as LegFromPrev?,
  ));
}

/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceCopyWith<$Res> get place {
  
  return $PlaceCopyWith<$Res>(_self.place, (value) {
    return _then(_self.copyWith(place: value));
  });
}/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res> get price {
  
  return $PriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Suggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LegFromPrevCopyWith<$Res>? get legFromPrev {
    if (_self.legFromPrev == null) {
    return null;
  }

  return $LegFromPrevCopyWith<$Res>(_self.legFromPrev!, (value) {
    return _then(_self.copyWith(legFromPrev: value));
  });
}
}

// dart format on
