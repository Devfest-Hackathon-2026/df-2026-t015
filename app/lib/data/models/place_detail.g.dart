// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NearbyPlace _$NearbyPlaceFromJson(Map<String, dynamic> json) => _NearbyPlace(
  placeId: json['placeId'] as String,
  name: json['name'] as String,
  address: json['address'] as String? ?? '',
  location: LatLng.fromJson(json['location'] as Map<String, dynamic>),
  typeLabel: json['typeLabel'] as String? ?? '',
);

Map<String, dynamic> _$NearbyPlaceToJson(_NearbyPlace instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'name': instance.name,
      'address': instance.address,
      'location': instance.location.toJson(),
      'typeLabel': instance.typeLabel,
    };

_PlaceDetail _$PlaceDetailFromJson(Map<String, dynamic> json) => _PlaceDetail(
  place: Place.fromJson(json['place'] as Map<String, dynamic>),
  typeLabel: json['typeLabel'] as String? ?? '',
  openingHours: json['openingHours'] == null
      ? null
      : OpeningHours.fromJson(json['openingHours'] as Map<String, dynamic>),
  price: json['price'] == null
      ? const Price()
      : Price.fromJson(json['price'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlaceDetailToJson(_PlaceDetail instance) =>
    <String, dynamic>{
      'place': instance.place.toJson(),
      'typeLabel': instance.typeLabel,
      'openingHours': ?instance.openingHours?.toJson(),
      'price': instance.price.toJson(),
    };
