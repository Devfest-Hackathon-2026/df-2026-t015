// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceInput _$PlaceInputFromJson(Map<String, dynamic> json) => _PlaceInput(
  placeId: json['placeId'] as String,
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  stayMin: (json['stayMin'] as num).toInt(),
);

Map<String, dynamic> _$PlaceInputToJson(_PlaceInput instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'stayMin': instance.stayMin,
    };

const _$PriorityEnumMap = {
  Priority.must: 'must',
  Priority.want: 'want',
  Priority.optional: 'optional',
};

_StartInput _$StartInputFromJson(Map<String, dynamic> json) => _StartInput(
  placeId: json['placeId'] as String,
  departAt: json['departAt'] as String,
);

Map<String, dynamic> _$StartInputToJson(_StartInput instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'departAt': instance.departAt,
    };

_CreateItineraryRequest _$CreateItineraryRequestFromJson(
  Map<String, dynamic> json,
) => _CreateItineraryRequest(
  title: json['title'] as String,
  date: json['date'] as String,
  start: StartInput.fromJson(json['start'] as Map<String, dynamic>),
  endBy: json['endBy'] as String,
  places: (json['places'] as List<dynamic>)
      .map((e) => PlaceInput.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreateItineraryRequestToJson(
  _CreateItineraryRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'date': instance.date,
  'start': instance.start.toJson(),
  'endBy': instance.endBy,
  'places': instance.places.map((e) => e.toJson()).toList(),
};

_UpdatePlacesRequest _$UpdatePlacesRequestFromJson(Map<String, dynamic> json) =>
    _UpdatePlacesRequest(
      endBy: json['endBy'] as String?,
      places: (json['places'] as List<dynamic>)
          .map((e) => PlaceInput.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdatePlacesRequestToJson(
  _UpdatePlacesRequest instance,
) => <String, dynamic>{
  'endBy': ?instance.endBy,
  'places': instance.places.map((e) => e.toJson()).toList(),
};

_ReplanRequest _$ReplanRequestFromJson(Map<String, dynamic> json) =>
    _ReplanRequest(
      currentItemId: json['currentItemId'] as String?,
      delayMin: (json['delayMin'] as num?)?.toInt(),
      now: json['now'] == null ? null : DateTime.parse(json['now'] as String),
    );

Map<String, dynamic> _$ReplanRequestToJson(_ReplanRequest instance) =>
    <String, dynamic>{
      'currentItemId': ?instance.currentItemId,
      'delayMin': ?instance.delayMin,
      'now': ?instance.now?.toIso8601String(),
    };

_AddItemRequest _$AddItemRequestFromJson(Map<String, dynamic> json) =>
    _AddItemRequest(
      placeId: json['placeId'] as String,
      stayMin: (json['stayMin'] as num).toInt(),
      priority:
          $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
          Priority.optional,
      insertAfterItemId: json['insertAfterItemId'] as String?,
    );

Map<String, dynamic> _$AddItemRequestToJson(_AddItemRequest instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'stayMin': instance.stayMin,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'insertAfterItemId': ?instance.insertAfterItemId,
    };
