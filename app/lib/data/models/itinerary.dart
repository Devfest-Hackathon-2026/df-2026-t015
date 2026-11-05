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

/// 予定間の移動。出発地からの移動は fromItemId が [startItemId]。
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
    required DateTime endAt,
  }) = _Summary;

  factory Summary.fromJson(Map<String, dynamic> json) =>
      _$SummaryFromJson(json);
}

@freezed
abstract class ItineraryStart with _$ItineraryStart {
  const factory ItineraryStart({
    required String placeId,
    required String name,
    required DateTime departAt,
  }) = _ItineraryStart;

  factory ItineraryStart.fromJson(Map<String, dynamic> json) =>
      _$ItineraryStartFromJson(json);
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

    /// 終わりたい時刻（HH:mm）
    required String endBy,
    @Default(<Item>[]) List<Item> items,
    @Default(<Leg>[]) List<Leg> legs,
    required Summary summary,
    @Default(<DroppedPlace>[]) List<DroppedPlace> dropped,
    DateTime? expiresAt,
  }) = _Itinerary;

  factory Itinerary.fromJson(Map<String, dynamic> json) =>
      _$ItineraryFromJson(json);
}

/// GET /me/itineraries の 1 件
@freezed
abstract class ItineraryListEntry with _$ItineraryListEntry {
  const factory ItineraryListEntry({
    required String id,
    required String title,
    required String date,
    required DateTime updatedAt,
  }) = _ItineraryListEntry;

  factory ItineraryListEntry.fromJson(Map<String, dynamic> json) =>
      _$ItineraryListEntryFromJson(json);
}
