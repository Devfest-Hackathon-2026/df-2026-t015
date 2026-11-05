import 'package:freezed_annotation/freezed_annotation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
abstract class LatLng with _$LatLng {
  const factory LatLng({required double lat, required double lng}) = _LatLng;

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
}

/// 施設（Places API の Place）。autocomplete の候補では location が無い。
@freezed
abstract class Place with _$Place {
  const factory Place({
    required String placeId,
    required String name,
    @Default('') String address,
    LatLng? location,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}

/// POST /places/interpret の候補
@freezed
abstract class InterpretedCandidate with _$InterpretedCandidate {
  const factory InterpretedCandidate({
    required Place place,
    required String reason,
  }) = _InterpretedCandidate;

  factory InterpretedCandidate.fromJson(Map<String, dynamic> json) =>
      _$InterpretedCandidateFromJson(json);
}

enum PriceKind {
  @JsonValue('fixed')
  fixed,
  @JsonValue('estimate')
  estimate,
  @JsonValue('unknown')
  unknown,
}

/// 料金。kind で確定値・目安・不明を区別し、推測で断定しない。
@freezed
abstract class Price with _$Price {
  const factory Price({
    int? amount,
    @JsonKey(unknownEnumValue: PriceKind.unknown)
    @Default(PriceKind.unknown)
    PriceKind kind,
    String? source,
  }) = _Price;

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}
