// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OpeningHours _$OpeningHoursFromJson(Map<String, dynamic> json) =>
    _OpeningHours(
      opensAt: json['opensAt'] as String,
      closesAt: json['closesAt'] as String,
    );

Map<String, dynamic> _$OpeningHoursToJson(_OpeningHours instance) =>
    <String, dynamic>{
      'opensAt': instance.opensAt,
      'closesAt': instance.closesAt,
    };

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  itemId: json['itemId'] as String,
  placeId: json['placeId'] as String,
  name: json['name'] as String,
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  stayMin: (json['stayMin'] as num).toInt(),
  startAt: DateTime.parse(json['startAt'] as String),
  endAt: DateTime.parse(json['endAt'] as String),
  price: json['price'] == null
      ? const Price()
      : Price.fromJson(json['price'] as Map<String, dynamic>),
  openingHours: json['openingHours'] == null
      ? null
      : OpeningHours.fromJson(json['openingHours'] as Map<String, dynamic>),
  status:
      $enumDecodeNullable(
        _$ItemStatusEnumMap,
        json['status'],
        unknownValue: ItemStatus.upcoming,
      ) ??
      ItemStatus.upcoming,
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'itemId': instance.itemId,
  'placeId': instance.placeId,
  'name': instance.name,
  'priority': _$PriorityEnumMap[instance.priority]!,
  'stayMin': instance.stayMin,
  'startAt': instance.startAt.toIso8601String(),
  'endAt': instance.endAt.toIso8601String(),
  'price': instance.price.toJson(),
  'openingHours': ?instance.openingHours?.toJson(),
  'status': _$ItemStatusEnumMap[instance.status]!,
};

const _$PriorityEnumMap = {
  Priority.must: 'must',
  Priority.want: 'want',
  Priority.optional: 'optional',
};

const _$ItemStatusEnumMap = {
  ItemStatus.upcoming: 'upcoming',
  ItemStatus.current: 'current',
  ItemStatus.done: 'done',
};

_Leg _$LegFromJson(Map<String, dynamic> json) => _Leg(
  fromItemId: json['fromItemId'] as String,
  toItemId: json['toItemId'] as String,
  mode: $enumDecode(_$TransitModeEnumMap, json['mode']),
  durationMin: (json['durationMin'] as num).toInt(),
  departAt: DateTime.parse(json['departAt'] as String),
  arriveAt: DateTime.parse(json['arriveAt'] as String),
  lineName: json['lineName'] as String?,
);

Map<String, dynamic> _$LegToJson(_Leg instance) => <String, dynamic>{
  'fromItemId': instance.fromItemId,
  'toItemId': instance.toItemId,
  'mode': _$TransitModeEnumMap[instance.mode]!,
  'durationMin': instance.durationMin,
  'departAt': instance.departAt.toIso8601String(),
  'arriveAt': instance.arriveAt.toIso8601String(),
  'lineName': ?instance.lineName,
};

const _$TransitModeEnumMap = {
  TransitMode.walk: 'walk',
  TransitMode.bus: 'bus',
  TransitMode.train: 'train',
  TransitMode.taxi: 'taxi',
};

_PriceTotal _$PriceTotalFromJson(Map<String, dynamic> json) => _PriceTotal(
  amount: (json['amount'] as num).toInt(),
  hasEstimate: json['hasEstimate'] as bool,
);

Map<String, dynamic> _$PriceTotalToJson(_PriceTotal instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'hasEstimate': instance.hasEstimate,
    };

_Summary _$SummaryFromJson(Map<String, dynamic> json) => _Summary(
  moveMin: (json['moveMin'] as num).toInt(),
  priceTotal: PriceTotal.fromJson(json['priceTotal'] as Map<String, dynamic>),
  endAt: DateTime.parse(json['endAt'] as String),
);

Map<String, dynamic> _$SummaryToJson(_Summary instance) => <String, dynamic>{
  'moveMin': instance.moveMin,
  'priceTotal': instance.priceTotal.toJson(),
  'endAt': instance.endAt.toIso8601String(),
};

_ItineraryStart _$ItineraryStartFromJson(Map<String, dynamic> json) =>
    _ItineraryStart(
      placeId: json['placeId'] as String?,
      name: json['name'] as String,
      location: json['location'] == null
          ? null
          : LatLng.fromJson(json['location'] as Map<String, dynamic>),
      departAt: DateTime.parse(json['departAt'] as String),
    );

Map<String, dynamic> _$ItineraryStartToJson(_ItineraryStart instance) =>
    <String, dynamic>{
      'placeId': ?instance.placeId,
      'name': instance.name,
      'location': ?instance.location?.toJson(),
      'departAt': instance.departAt.toIso8601String(),
    };

_ItineraryEnd _$ItineraryEndFromJson(Map<String, dynamic> json) =>
    _ItineraryEnd(
      placeId: json['placeId'] as String?,
      name: json['name'] as String,
      location: json['location'] == null
          ? null
          : LatLng.fromJson(json['location'] as Map<String, dynamic>),
      date: json['date'] as String?,
      arriveBy: json['arriveBy'] as String,
      arriveAt: DateTime.parse(json['arriveAt'] as String),
    );

Map<String, dynamic> _$ItineraryEndToJson(_ItineraryEnd instance) =>
    <String, dynamic>{
      'placeId': ?instance.placeId,
      'name': instance.name,
      'location': ?instance.location?.toJson(),
      'date': ?instance.date,
      'arriveBy': instance.arriveBy,
      'arriveAt': instance.arriveAt.toIso8601String(),
    };

_DroppedPlace _$DroppedPlaceFromJson(Map<String, dynamic> json) =>
    _DroppedPlace(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$DroppedPlaceToJson(_DroppedPlace instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'name': instance.name,
      'reason': instance.reason,
    };

_Itinerary _$ItineraryFromJson(Map<String, dynamic> json) => _Itinerary(
  id: json['id'] as String,
  version: (json['version'] as num).toInt(),
  title: json['title'] as String,
  date: json['date'] as String,
  start: ItineraryStart.fromJson(json['start'] as Map<String, dynamic>),
  end: ItineraryEnd.fromJson(json['end'] as Map<String, dynamic>),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Item>[],
  legs:
      (json['legs'] as List<dynamic>?)
          ?.map((e) => Leg.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Leg>[],
  summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
  dropped:
      (json['dropped'] as List<dynamic>?)
          ?.map((e) => DroppedPlace.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DroppedPlace>[],
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$ItineraryToJson(_Itinerary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'title': instance.title,
      'date': instance.date,
      'start': instance.start.toJson(),
      'end': instance.end.toJson(),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'legs': instance.legs.map((e) => e.toJson()).toList(),
      'summary': instance.summary.toJson(),
      'dropped': instance.dropped.map((e) => e.toJson()).toList(),
      'expiresAt': ?instance.expiresAt?.toIso8601String(),
    };

_ItineraryListStart _$ItineraryListStartFromJson(Map<String, dynamic> json) =>
    _ItineraryListStart(
      name: json['name'] as String,
      departAt: DateTime.parse(json['departAt'] as String),
    );

Map<String, dynamic> _$ItineraryListStartToJson(_ItineraryListStart instance) =>
    <String, dynamic>{
      'name': instance.name,
      'departAt': instance.departAt.toIso8601String(),
    };

_ItineraryListEnd _$ItineraryListEndFromJson(Map<String, dynamic> json) =>
    _ItineraryListEnd(
      name: json['name'] as String,
      arriveAt: DateTime.parse(json['arriveAt'] as String),
    );

Map<String, dynamic> _$ItineraryListEndToJson(_ItineraryListEnd instance) =>
    <String, dynamic>{
      'name': instance.name,
      'arriveAt': instance.arriveAt.toIso8601String(),
    };

_ItineraryListEntry _$ItineraryListEntryFromJson(Map<String, dynamic> json) =>
    _ItineraryListEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      start: ItineraryListStart.fromJson(json['start'] as Map<String, dynamic>),
      end: ItineraryListEnd.fromJson(json['end'] as Map<String, dynamic>),
      placeCount: (json['placeCount'] as num?)?.toInt() ?? 0,
      placeNames:
          (json['placeNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$ItineraryListEntryToJson(_ItineraryListEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date,
      'start': instance.start.toJson(),
      'end': instance.end.toJson(),
      'placeCount': instance.placeCount,
      'placeNames': instance.placeNames,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'expiresAt': ?instance.expiresAt?.toIso8601String(),
    };

_ItineraryPage _$ItineraryPageFromJson(Map<String, dynamic> json) =>
    _ItineraryPage(
      itineraries:
          (json['itineraries'] as List<dynamic>?)
              ?.map(
                (e) => ItineraryListEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ItineraryListEntry>[],
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$ItineraryPageToJson(_ItineraryPage instance) =>
    <String, dynamic>{
      'itineraries': instance.itineraries.map((e) => e.toJson()).toList(),
      'nextCursor': ?instance.nextCursor,
    };
