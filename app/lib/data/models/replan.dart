import 'package:freezed_annotation/freezed_annotation.dart';

import 'itinerary.dart';
import 'place.dart';

part 'replan.freezed.dart';
part 'replan.g.dart';

enum ReplanWarningType {
  @JsonValue('miss_transit')
  missTransit,
  @JsonValue('must_at_risk')
  mustAtRisk,
  unknown,
}

@freezed
abstract class ReplanWarning with _$ReplanWarning {
  const factory ReplanWarning({
    @JsonKey(unknownEnumValue: ReplanWarningType.unknown)
    required ReplanWarningType type,
    String? itemId,
    required String message,
  }) = _ReplanWarning;

  factory ReplanWarning.fromJson(Map<String, dynamic> json) =>
      _$ReplanWarningFromJson(json);
}

enum ChangeType {
  @JsonValue('replace')
  replace,
  @JsonValue('retime')
  retime,
  @JsonValue('drop')
  drop,
  @JsonValue('keep')
  keep,
}

/// 変更前後の予定の一部。変更の種類によって入る項目が違うため、すべて任意。
@freezed
abstract class ChangeSnapshot with _$ChangeSnapshot {
  const factory ChangeSnapshot({
    String? placeId,
    String? name,
    DateTime? startAt,
    DateTime? endAt,
    Price? price,
  }) = _ChangeSnapshot;

  factory ChangeSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ChangeSnapshotFromJson(json);
}

@freezed
abstract class ReplanChange with _$ReplanChange {
  const factory ReplanChange({
    required ChangeType type,
    required String itemId,
    ChangeSnapshot? before,
    ChangeSnapshot? after,
    String? note,
  }) = _ReplanChange;

  factory ReplanChange.fromJson(Map<String, dynamic> json) =>
      _$ReplanChangeFromJson(json);
}

/// 確定後の旅程の items と legs（確定前に旅程全体を見せる用）
@freezed
abstract class ReplanPreview with _$ReplanPreview {
  const factory ReplanPreview({
    @Default(<Item>[]) List<Item> items,
    @Default(<Leg>[]) List<Leg> legs,
  }) = _ReplanPreview;

  factory ReplanPreview.fromJson(Map<String, dynamic> json) =>
      _$ReplanPreviewFromJson(json);
}

@freezed
abstract class ReplanOption with _$ReplanOption {
  const factory ReplanOption({
    required String optionId,
    @Default(<ReplanChange>[]) List<ReplanChange> changes,
    required Summary summaryBefore,
    required Summary summaryAfter,
    @Default(ReplanPreview()) ReplanPreview preview,
  }) = _ReplanOption;

  factory ReplanOption.fromJson(Map<String, dynamic> json) =>
      _$ReplanOptionFromJson(json);
}

enum ExplanationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('ready')
  ready,
  @JsonValue('failed')
  failed,
}

/// GET .../replans/:replanId/explanation
@freezed
abstract class Explanation with _$Explanation {
  const factory Explanation({
    @JsonKey(unknownEnumValue: ExplanationStatus.failed)
    required ExplanationStatus status,
    String? text,
  }) = _Explanation;

  factory Explanation.fromJson(Map<String, dynamic> json) =>
      _$ExplanationFromJson(json);
}

/// POST /itineraries/:id/replans の結果。needsChange が false なら options は空。
@freezed
abstract class ReplanResult with _$ReplanResult {
  const factory ReplanResult({
    String? replanId,
    int? basedOnVersion,
    required bool needsChange,
    DateTime? expiresAt,
    @Default(<ReplanWarning>[]) List<ReplanWarning> warnings,
    @Default(<ReplanOption>[]) List<ReplanOption> options,
    Explanation? explanation,
  }) = _ReplanResult;

  factory ReplanResult.fromJson(Map<String, dynamic> json) =>
      _$ReplanResultFromJson(json);
}
