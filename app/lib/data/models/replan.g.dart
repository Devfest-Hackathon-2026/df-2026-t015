// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReplanWarning _$ReplanWarningFromJson(Map<String, dynamic> json) =>
    _ReplanWarning(
      type: $enumDecode(
        _$ReplanWarningTypeEnumMap,
        json['type'],
        unknownValue: ReplanWarningType.unknown,
      ),
      itemId: json['itemId'] as String?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ReplanWarningToJson(_ReplanWarning instance) =>
    <String, dynamic>{
      'type': _$ReplanWarningTypeEnumMap[instance.type]!,
      'itemId': ?instance.itemId,
      'message': instance.message,
    };

const _$ReplanWarningTypeEnumMap = {
  ReplanWarningType.missTransit: 'miss_transit',
  ReplanWarningType.mustAtRisk: 'must_at_risk',
  ReplanWarningType.endAtRisk: 'end_at_risk',
  ReplanWarningType.unknown: 'unknown',
};

_ChangeSnapshot _$ChangeSnapshotFromJson(Map<String, dynamic> json) =>
    _ChangeSnapshot(
      placeId: json['placeId'] as String?,
      name: json['name'] as String?,
      startAt: json['startAt'] == null
          ? null
          : DateTime.parse(json['startAt'] as String),
      endAt: json['endAt'] == null
          ? null
          : DateTime.parse(json['endAt'] as String),
      price: json['price'] == null
          ? null
          : Price.fromJson(json['price'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChangeSnapshotToJson(_ChangeSnapshot instance) =>
    <String, dynamic>{
      'placeId': ?instance.placeId,
      'name': ?instance.name,
      'startAt': ?instance.startAt?.toIso8601String(),
      'endAt': ?instance.endAt?.toIso8601String(),
      'price': ?instance.price?.toJson(),
    };

_ReplanChange _$ReplanChangeFromJson(Map<String, dynamic> json) =>
    _ReplanChange(
      type: $enumDecode(_$ChangeTypeEnumMap, json['type']),
      itemId: json['itemId'] as String,
      before: json['before'] == null
          ? null
          : ChangeSnapshot.fromJson(json['before'] as Map<String, dynamic>),
      after: json['after'] == null
          ? null
          : ChangeSnapshot.fromJson(json['after'] as Map<String, dynamic>),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$ReplanChangeToJson(_ReplanChange instance) =>
    <String, dynamic>{
      'type': _$ChangeTypeEnumMap[instance.type]!,
      'itemId': instance.itemId,
      'before': ?instance.before?.toJson(),
      'after': ?instance.after?.toJson(),
      'note': ?instance.note,
    };

const _$ChangeTypeEnumMap = {
  ChangeType.replace: 'replace',
  ChangeType.retime: 'retime',
  ChangeType.drop: 'drop',
  ChangeType.keep: 'keep',
};

_ReplanPreview _$ReplanPreviewFromJson(Map<String, dynamic> json) =>
    _ReplanPreview(
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
    );

Map<String, dynamic> _$ReplanPreviewToJson(_ReplanPreview instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'legs': instance.legs.map((e) => e.toJson()).toList(),
    };

_ReplanOption _$ReplanOptionFromJson(Map<String, dynamic> json) =>
    _ReplanOption(
      optionId: json['optionId'] as String,
      changes:
          (json['changes'] as List<dynamic>?)
              ?.map((e) => ReplanChange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReplanChange>[],
      summaryBefore: Summary.fromJson(
        json['summaryBefore'] as Map<String, dynamic>,
      ),
      summaryAfter: Summary.fromJson(
        json['summaryAfter'] as Map<String, dynamic>,
      ),
      preview: json['preview'] == null
          ? const ReplanPreview()
          : ReplanPreview.fromJson(json['preview'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReplanOptionToJson(_ReplanOption instance) =>
    <String, dynamic>{
      'optionId': instance.optionId,
      'changes': instance.changes.map((e) => e.toJson()).toList(),
      'summaryBefore': instance.summaryBefore.toJson(),
      'summaryAfter': instance.summaryAfter.toJson(),
      'preview': instance.preview.toJson(),
    };

_Explanation _$ExplanationFromJson(Map<String, dynamic> json) => _Explanation(
  status: $enumDecode(
    _$ExplanationStatusEnumMap,
    json['status'],
    unknownValue: ExplanationStatus.failed,
  ),
  text: json['text'] as String?,
);

Map<String, dynamic> _$ExplanationToJson(_Explanation instance) =>
    <String, dynamic>{
      'status': _$ExplanationStatusEnumMap[instance.status]!,
      'text': ?instance.text,
    };

const _$ExplanationStatusEnumMap = {
  ExplanationStatus.pending: 'pending',
  ExplanationStatus.ready: 'ready',
  ExplanationStatus.failed: 'failed',
};

_ReplanResult _$ReplanResultFromJson(Map<String, dynamic> json) =>
    _ReplanResult(
      replanId: json['replanId'] as String?,
      basedOnVersion: (json['basedOnVersion'] as num?)?.toInt(),
      needsChange: json['needsChange'] as bool,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => ReplanWarning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReplanWarning>[],
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => ReplanOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReplanOption>[],
      explanation: json['explanation'] == null
          ? null
          : Explanation.fromJson(json['explanation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReplanResultToJson(_ReplanResult instance) =>
    <String, dynamic>{
      'replanId': ?instance.replanId,
      'basedOnVersion': ?instance.basedOnVersion,
      'needsChange': instance.needsChange,
      'expiresAt': ?instance.expiresAt?.toIso8601String(),
      'warnings': instance.warnings.map((e) => e.toJson()).toList(),
      'options': instance.options.map((e) => e.toJson()).toList(),
      'explanation': ?instance.explanation?.toJson(),
    };
