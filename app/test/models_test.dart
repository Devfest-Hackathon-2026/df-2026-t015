import 'package:flutter_test/flutter_test.dart';
import 'package:iterinerary/data/api/api_exception.dart';
import 'package:iterinerary/data/models/models.dart';

/// API 仕様（docs/iterinerary_API.docx）の例をそのまま読めることを確かめる。
void main() {
  test('POST /itineraries の出力を Itinerary として読める', () {
    final itinerary = Itinerary.fromJson({
      'id': 'itn_8f2k',
      'version': 1,
      'title': 'みなと町 日帰り旅',
      'date': '2026-11-14',
      'start': {
        'placeId': 'ChIJ_s',
        'name': 'みなと町駅',
        'departAt': '2026-11-14T09:00:00+09:00',
      },
      'endBy': '17:00',
      'items': [
        {
          'itemId': 'it_1',
          'placeId': 'ChIJ_1',
          'name': '朝市通り',
          'priority': 'must',
          'stayMin': 60,
          'startAt': '2026-11-14T09:30:00+09:00',
          'endAt': '2026-11-14T10:30:00+09:00',
          'price': {'amount': 1500, 'kind': 'estimate'},
          'openingHours': {'opensAt': '06:00', 'closesAt': '12:00'},
          'status': 'upcoming',
        },
      ],
      'legs': [
        {
          'fromItemId': 'it_1',
          'toItemId': 'it_2',
          'mode': 'bus',
          'durationMin': 15,
          'departAt': '2026-11-14T10:35:00+09:00',
          'arriveAt': '2026-11-14T10:50:00+09:00',
          'lineName': '12系統',
        },
      ],
      'summary': {
        'moveMin': 47,
        'priceTotal': {'amount': 3800, 'hasEstimate': true},
        'endAt': '2026-11-14T15:40:00+09:00',
      },
      'dropped': <Object>[],
      'expiresAt': '2026-12-14T00:00:00+09:00',
    });

    expect(itinerary.items.single.priority, Priority.must);
    expect(itinerary.items.single.price.kind, PriceKind.estimate);
    expect(itinerary.legs.single.mode, TransitMode.bus);
    expect(itinerary.summary.priceTotal.hasEstimate, isTrue);
    expect(itinerary.start.departAt.toUtc(), DateTime.utc(2026, 11, 14, 0));
  });

  test('組み直し不要の結果を読める', () {
    final result = ReplanResult.fromJson({
      'needsChange': false,
      'warnings': <Object>[],
      'options': <Object>[],
    });
    expect(result.needsChange, isFalse);
    expect(result.options, isEmpty);
  });

  test('知らない warning の種類は unknown として読む', () {
    final warning = ReplanWarning.fromJson({
      'type': 'new_type',
      'message': 'x',
    });
    expect(warning.type, ReplanWarningType.unknown);
  });

  test('ReplanRequest は null の項目を送らない', () {
    const request = ReplanRequest(currentItemId: 'it_2', delayMin: 40);
    expect(request.toJson(), {'currentItemId': 'it_2', 'delayMin': 40});
  });

  test('エラー応答を ApiException にする', () {
    final e = ApiException.fromResponse(422, {
      'error': {
        'code': 'MUST_ITEMS_INFEASIBLE',
        'message': '入りきりません',
        'details': {
          'placeIds': ['a', 'b'],
        },
      },
    });
    expect(e.code, ApiErrorCode.mustItemsInfeasible);
    expect(e.infeasiblePlaceIds, ['a', 'b']);
  });
}
