import 'package:freezed_annotation/freezed_annotation.dart';

import 'itinerary.dart';
import 'place.dart';

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

/// 出発地と出発時刻。
///
/// 施設なら [placeId]、地図で施設ではない地点を選んだときは [location] と [name] で指定する。
@freezed
abstract class StartInput with _$StartInput {
  @Assert(
    'placeId != null || (location != null && name != null)',
    'placeId か location と name のどちらかを指定する',
  )
  const factory StartInput({
    String? placeId,
    LatLng? location,
    String? name,

    /// 出発時刻（HH:mm）
    required String departAt,
  }) = _StartInput;

  /// 今の旅程の出発地を、時刻だけ変えて送り直す
  factory StartInput.fromEndpoint(
    ItineraryStart start, {
    required String departAt,
  }) => start.placeId != null
      ? StartInput(placeId: start.placeId, departAt: departAt)
      : StartInput(
          location: start.location,
          name: start.name,
          departAt: departAt,
        );

  factory StartInput.fromJson(Map<String, dynamic> json) =>
      _$StartInputFromJson(json);
}

/// 終わる場所と着きたい時刻。
///
/// 施設なら [placeId]、地図で施設ではない地点を選んだときは [location] と [name] で指定する。
@freezed
abstract class EndInput with _$EndInput {
  @Assert(
    'placeId != null || (location != null && name != null)',
    'placeId か location と name のどちらかを指定する',
  )
  const factory EndInput({
    String? placeId,
    LatLng? location,
    String? name,
    String? date,

    /// 終わる場所に着きたい時刻（HH:mm）。終わる場所への移動も含めて判定される
    required String arriveBy,
  }) = _EndInput;

  /// 今の旅程の終わる場所を、時刻だけ変えて送り直す
  factory EndInput.fromEndpoint(ItineraryEnd end, {required String arriveBy}) =>
      end.placeId != null
      ? EndInput(placeId: end.placeId, date: end.date, arriveBy: arriveBy)
      : EndInput(
          location: end.location,
          name: end.name,
          date: end.date,
          arriveBy: arriveBy,
        );

  factory EndInput.fromJson(Map<String, dynamic> json) =>
      _$EndInputFromJson(json);
}

/// POST /itineraries
@freezed
abstract class CreateItineraryRequest with _$CreateItineraryRequest {
  const factory CreateItineraryRequest({
    required String title,

    /// 旅行日（YYYY-MM-DD）
    required String date,
    required StartInput start,
    required EndInput end,
    required List<PlaceInput> places,
  }) = _CreateItineraryRequest;

  factory CreateItineraryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateItineraryRequestFromJson(json);
}

/// PUT /itineraries/:id/places（places は全件を送る）。
///
/// [date]・[start]・[end] は送らなければ今の値のまま。
/// [date] を変えると時刻表が変わるため、旅程全体が作り直される。
@freezed
abstract class UpdatePlacesRequest with _$UpdatePlacesRequest {
  const factory UpdatePlacesRequest({
    /// 旅行日（YYYY-MM-DD）
    String? date,
    StartInput? start,
    EndInput? end,
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

/// POST /itineraries/:id/copy（F-11）。[title] を省くと元の名前を使う。
@freezed
abstract class CopyItineraryRequest with _$CopyItineraryRequest {
  const factory CopyItineraryRequest({
    /// コピー先の旅行日（YYYY-MM-DD）
    required String date,
    String? title,
  }) = _CopyItineraryRequest;

  factory CopyItineraryRequest.fromJson(Map<String, dynamic> json) =>
      _$CopyItineraryRequestFromJson(json);
}
