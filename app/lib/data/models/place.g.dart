// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LatLng _$LatLngFromJson(Map<String, dynamic> json) => _LatLng(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$LatLngToJson(_LatLng instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};

_Place _$PlaceFromJson(Map<String, dynamic> json) => _Place(
  placeId: json['placeId'] as String,
  name: json['name'] as String,
  address: json['address'] as String? ?? '',
  location: json['location'] == null
      ? null
      : LatLng.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlaceToJson(_Place instance) => <String, dynamic>{
  'placeId': instance.placeId,
  'name': instance.name,
  'address': instance.address,
  'location': ?instance.location?.toJson(),
};

_InterpretedCandidate _$InterpretedCandidateFromJson(
  Map<String, dynamic> json,
) => _InterpretedCandidate(
  place: Place.fromJson(json['place'] as Map<String, dynamic>),
  reason: json['reason'] as String,
);

Map<String, dynamic> _$InterpretedCandidateToJson(
  _InterpretedCandidate instance,
) => <String, dynamic>{
  'place': instance.place.toJson(),
  'reason': instance.reason,
};

_Price _$PriceFromJson(Map<String, dynamic> json) => _Price(
  amount: (json['amount'] as num?)?.toInt(),
  kind:
      $enumDecodeNullable(
        _$PriceKindEnumMap,
        json['kind'],
        unknownValue: PriceKind.unknown,
      ) ??
      PriceKind.unknown,
  source: json['source'] as String?,
);

Map<String, dynamic> _$PriceToJson(_Price instance) => <String, dynamic>{
  'amount': ?instance.amount,
  'kind': _$PriceKindEnumMap[instance.kind]!,
  'source': ?instance.source,
};

const _$PriceKindEnumMap = {
  PriceKind.fixed: 'fixed',
  PriceKind.estimate: 'estimate',
  PriceKind.unknown: 'unknown',
};
