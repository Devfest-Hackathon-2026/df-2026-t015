import 'package:freezed_annotation/freezed_annotation.dart';

import 'itinerary.dart';
import 'place.dart';

part 'suggestion.freezed.dart';
part 'suggestion.g.dart';

@freezed
abstract class LegFromPrev with _$LegFromPrev {
  const factory LegFromPrev({
    required TransitMode mode,
    required int durationMin,
  }) = _LegFromPrev;

  factory LegFromPrev.fromJson(Map<String, dynamic> json) =>
      _$LegFromPrevFromJson(json);
}

/// GET /itineraries/:id/suggestions の 1 件（F-07）
@freezed
abstract class Suggestion with _$Suggestion {
  const factory Suggestion({
    required Place place,
    required String reason,
    required int stayMin,
    @Default(Price()) Price price,
    String? insertAfterItemId,
    LegFromPrev? legFromPrev,
  }) = _Suggestion;

  factory Suggestion.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFromJson(json);
}
