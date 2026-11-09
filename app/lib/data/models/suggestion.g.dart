// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LegFromPrev _$LegFromPrevFromJson(Map<String, dynamic> json) => _LegFromPrev(
  mode: $enumDecode(_$TransitModeEnumMap, json['mode']),
  durationMin: (json['durationMin'] as num).toInt(),
);

Map<String, dynamic> _$LegFromPrevToJson(_LegFromPrev instance) =>
    <String, dynamic>{
      'mode': _$TransitModeEnumMap[instance.mode]!,
      'durationMin': instance.durationMin,
    };

const _$TransitModeEnumMap = {
  TransitMode.walk: 'walk',
  TransitMode.bus: 'bus',
  TransitMode.train: 'train',
  TransitMode.taxi: 'taxi',
};

_Suggestion _$SuggestionFromJson(Map<String, dynamic> json) => _Suggestion(
  place: Place.fromJson(json['place'] as Map<String, dynamic>),
  reason: json['reason'] as String,
  stayMin: (json['stayMin'] as num).toInt(),
  price: json['price'] == null
      ? const Price()
      : Price.fromJson(json['price'] as Map<String, dynamic>),
  insertAfterItemId: json['insertAfterItemId'] as String?,
  legFromPrev: json['legFromPrev'] == null
      ? null
      : LegFromPrev.fromJson(json['legFromPrev'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SuggestionToJson(_Suggestion instance) =>
    <String, dynamic>{
      'place': instance.place.toJson(),
      'reason': instance.reason,
      'stayMin': instance.stayMin,
      'price': instance.price.toJson(),
      'insertAfterItemId': ?instance.insertAfterItemId,
      'legFromPrev': ?instance.legFromPrev?.toJson(),
    };
