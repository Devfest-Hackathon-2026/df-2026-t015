import 'package:freezed_annotation/freezed_annotation.dart';

import 'place.dart';

part 'itinerary.freezed.dart';
part 'itinerary.g.dart';

enum Priority {
  @JsonValue('must')
  must,
  @JsonValue('want')
  want,
  @JsonValue('optional')
  optional,
}

enum ItemStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('current')
  current,
  @JsonValue('done')
  done,
}

enum TransitMode {
  @JsonValue('walk')
  walk,
  @JsonValue('bus')
  bus,
  @JsonValue('train')
  train,
  @JsonValue('taxi')
  taxi,
}

/// その日の営業時間（HH:mm）
@freezed
abstract class OpeningHours with _$OpeningHours {
  const factory OpeningHours({
    required String opensAt,
    required String closesAt,
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
}

/// 旅程内の予定
@freezed
abstract class Item with _$Item {
  const factory Item({
    required String itemId,
    required String placeId,
    required String name,
    required Priority priority,
    required int stayMin,
    required DateTime startAt,
    required DateTime endAt,
    @Default(Price()) Price price,
    OpeningHours? openingHours,
    @JsonKey(unknownEnumValue: ItemStatus.upcoming)
    @Default(ItemStatus.upcoming)
    ItemStatus status,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

/// 予定間の移動。出発地からの移動は fromItemId が [startItemId]、
/// 終わる場所への移動は toItemId が [endItemId]。
@freezed
abstract class Leg with _$Leg {
  const factory Leg({
    required String fromItemId,
    required String toItemId,
    required TransitMode mode,
    required int durationMin,
    required DateTime departAt,
    required DateTime arriveAt,
    String? lineName,
  }) = _Leg;

  static const startItemId = 'start';
  static const endItemId = 'end';

  factory Leg.fromJson(Map<String, dynamic> json) => _$LegFromJson(json);
}

@freezed
abstract class PriceTotal with _$PriceTotal {
  const factory PriceTotal({required int amount, required bool hasEstimate}) =
      _PriceTotal;

  factory PriceTotal.fromJson(Map<String, dynamic> json) =>
      _$PriceTotalFromJson(json);
}

/// 旅程の集計
@freezed
abstract class Summary with _$Summary {
  const factory Summary({
    required int moveMin,
    required PriceTotal priceTotal,

    /// 終わる場所に着く時刻
    required DateTime endAt,
  }) = _Summary;

  factory Summary.fromJson(Map<String, dynamic> json) =>
      _$SummaryFromJson(json);
}

/// 出発地と出発時刻（Endpoint ＋ { departAt }）。
/// 地図で施設ではない地点を選んだときは [placeId] が null。
@freezed
abstract class ItineraryStart with _$ItineraryStart {
  const factory ItineraryStart({
    String? placeId,
    required String name,
    LatLng? location,
    required DateTime departAt,
  }) = _ItineraryStart;

  factory ItineraryStart.fromJson(Map<String, dynamic> json) =>
      _$ItineraryStartFromJson(json);
}

/// 終わる場所と時刻（Endpoint ＋ { arriveBy, arriveAt }）。
/// 地図で施設ではない地点を選んだときは [placeId] が null。
@freezed
abstract class ItineraryEnd with _$ItineraryEnd {
  const factory ItineraryEnd({
    String? placeId,
    required String name,
    LatLng? location,
    String? date,

    /// 着きたい時刻（HH:mm）
    required String arriveBy,

    /// 着く予定の時刻
    required DateTime arriveAt,
  }) = _ItineraryEnd;

  factory ItineraryEnd.fromJson(Map<String, dynamic> json) =>
      _$ItineraryEndFromJson(json);
}

/// 入りきらずに外した行き先
@freezed
abstract class DroppedPlace with _$DroppedPlace {
  const factory DroppedPlace({
    required String placeId,
    required String name,
    required String reason,
  }) = _DroppedPlace;

  factory DroppedPlace.fromJson(Map<String, dynamic> json) =>
      _$DroppedPlaceFromJson(json);
}

/// 旅程
@freezed
abstract class Itinerary with _$Itinerary {
  const factory Itinerary({
    required String id,
    required int version,
    required String title,

    /// 旅行日（YYYY-MM-DD）
    required String date,
    required ItineraryStart start,
    required ItineraryEnd end,
    @Default(<Item>[]) List<Item> items,
    @Default(<Leg>[]) List<Leg> legs,
    required Summary summary,
    @Default(<DroppedPlace>[]) List<DroppedPlace> dropped,
    DateTime? expiresAt,
  }) = _Itinerary;

  factory Itinerary.fromJson(Map<String, dynamic> json) =>
      _$ItineraryFromJson(json);
}

/// GET /me/itineraries の 1 件の出発
@freezed
abstract class ItineraryListStart with _$ItineraryListStart {
  const factory ItineraryListStart({
    required String name,
    required DateTime departAt,
  }) = _ItineraryListStart;

  factory ItineraryListStart.fromJson(Map<String, dynamic> json) =>
      _$ItineraryListStartFromJson(json);
}

/// GET /me/itineraries の 1 件の終わり
@freezed
abstract class ItineraryListEnd with _$ItineraryListEnd {
  const factory ItineraryListEnd({
    required String name,
    required DateTime arriveAt,
  }) = _ItineraryListEnd;

  factory ItineraryListEnd.fromJson(Map<String, dynamic> json) =>
      _$ItineraryListEndFromJson(json);
}

/// GET /me/itineraries の 1 件（F-08）
@freezed
abstract class ItineraryListEntry with _$ItineraryListEntry {
  const factory ItineraryListEntry({
    required String id,
    required String title,

    /// 旅行日（YYYY-MM-DD）
    required String date,
    required ItineraryListStart start,
    required ItineraryListEnd end,
    @Default(0) int placeCount,

    /// 行き先の名前（先頭 3 件まで）
    @Default(<String>[]) List<String> placeNames,
    required DateTime updatedAt,

    /// 自動で消える日時（一覧の「終わった旅」に出す）
    DateTime? expiresAt,
  }) = _ItineraryListEntry;

  factory ItineraryListEntry.fromJson(Map<String, dynamic> json) =>
      _$ItineraryListEntryFromJson(json);
}

/// GET /me/itineraries の応答。[nextCursor] が null なら続きはない。
@freezed
abstract class ItineraryPage with _$ItineraryPage {
  const factory ItineraryPage({
    @Default(<ItineraryListEntry>[]) List<ItineraryListEntry> itineraries,
    String? nextCursor,
  }) = _ItineraryPage;

  factory ItineraryPage.fromJson(Map<String, dynamic> json) =>
      _$ItineraryPageFromJson(json);
}
