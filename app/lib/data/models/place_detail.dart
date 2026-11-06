import 'package:freezed_annotation/freezed_annotation.dart';

import 'itinerary.dart';
import 'place.dart';

part 'place_detail.freezed.dart';
part 'place_detail.g.dart';

/// GET /places/nearby の 1 件（F-10）。地図にピンとして出す。
@freezed
abstract class NearbyPlace with _$NearbyPlace {
  const factory NearbyPlace({
    required String placeId,
    required String name,
    @Default('') String address,
    required LatLng location,

    /// 画面に出す施設の種類（駅、温泉、飲食店街など）
    @Default('') String typeLabel,
  }) = _NearbyPlace;

  const NearbyPlace._();

  /// 出発地・終わる場所・行き先として扱うための [Place]
  Place get place =>
      Place(placeId: placeId, name: name, address: address, location: location);

  factory NearbyPlace.fromJson(Map<String, dynamic> json) =>
      _$NearbyPlaceFromJson(json);
}

/// GET /places/:placeId の応答（F-10）。地図の下部のカードに出す。
@freezed
abstract class PlaceDetail with _$PlaceDetail {
  const factory PlaceDetail({
    required Place place,
    @Default('') String typeLabel,

    /// その日の営業時間。休みなら null
    OpeningHours? openingHours,
    @Default(Price()) Price price,
  }) = _PlaceDetail;

  factory PlaceDetail.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailFromJson(json);
}
