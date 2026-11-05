import 'package:freezed_annotation/freezed_annotation.dart';

import 'itinerary.dart';

part 'requests.freezed.dart';
part 'requests.g.dart';

/// 旅程に入れたい行き先
@freezed
abstract class PlaceInput with _$PlaceInput {
  const factory PlaceInput({
    required String placeId,
    required Priority priority,
    required int stayMin,
  }) = _PlaceInput;

  factory PlaceInput.fromJson(Map<String, dynamic> json) =>
      _$PlaceInputFromJson(json);
}

@freezed
abstract class StartInput with _$StartInput {
  const factory StartInput({
    required String placeId,

    /// 出発時刻（HH:mm）
    required String departAt,
  }) = _StartInput;

  factory StartInput.fromJson(Map<String, dynamic> json) =>
      _$StartInputFromJson(json);
}

/// POST /itineraries
@freezed
abstract class CreateItineraryRequest with _$CreateItineraryRequest {
  const factory CreateItineraryRequest({
    required String title,

    /// 旅行日（YYYY-MM-DD）
    required String date,
    required StartInput start,

    /// 終わりたい時刻（HH:mm）
    required String endBy,
    required List<PlaceInput> places,
  }) = _CreateItineraryRequest;

  factory CreateItineraryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateItineraryRequestFromJson(json);
}

/// PUT /itineraries/:id/places（places は全件を送る）
@freezed
abstract class UpdatePlacesRequest with _$UpdatePlacesRequest {
  const factory UpdatePlacesRequest({
    String? endBy,
    required List<PlaceInput> places,
  }) = _UpdatePlacesRequest;

  factory UpdatePlacesRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePlacesRequestFromJson(json);
}

/// POST /itineraries/:id/replans（delayMin か now のどちらか一方が必須）
@freezed
abstract class ReplanRequest with _$ReplanRequest {
  @Assert('(delayMin == null) != (now == null)', 'delayMin か now のどちらか一方を指定する')
  const factory ReplanRequest({
    String? currentItemId,
    int? delayMin,
    DateTime? now,
  }) = _ReplanRequest;

  factory ReplanRequest.fromJson(Map<String, dynamic> json) =>
      _$ReplanRequestFromJson(json);
}

/// POST /itineraries/:id/items
@freezed
abstract class AddItemRequest with _$AddItemRequest {
  const factory AddItemRequest({
    required String placeId,
    required int stayMin,
    @Default(Priority.optional) Priority priority,
    String? insertAfterItemId,
  }) = _AddItemRequest;

  factory AddItemRequest.fromJson(Map<String, dynamic> json) =>
      _$AddItemRequestFromJson(json);
}
