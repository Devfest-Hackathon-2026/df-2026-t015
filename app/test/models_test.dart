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
      'end': {
        'placeId': 'ChIJ_s',
        'name': 'みなと町駅',
        'arriveBy': '17:00',
        'arriveAt': '2026-11-14T16:05:00+09:00',
      },
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
        'moveMin': 62,
        'priceTotal': {'amount': 3800, 'hasEstimate': true},
        'endAt': '2026-11-14T16:05:00+09:00',
      },
      'dropped': <Object>[],
      'expiresAt': '2026-12-14T00:00:00+09:00',
    });

    expect(itinerary.items.single.priority, Priority.must);
    expect(itinerary.items.single.price.kind, PriceKind.estimate);
    expect(itinerary.legs.single.mode, TransitMode.bus);
    expect(itinerary.summary.priceTotal.hasEstimate, isTrue);
    expect(itinerary.start.departAt.toUtc(), DateTime.utc(2026, 11, 14, 0));
    expect(itinerary.end.arriveBy, '17:00');
    expect(itinerary.end.arriveAt.toUtc(), DateTime.utc(2026, 11, 14, 7, 5));
  });

  test('地図で選んだ地点（placeId が null）の出発地を読める', () {
    final start = ItineraryStart.fromJson({
      'placeId': null,
      'name': '山あいの駐車場',
      'location': {'lat': 35.12, 'lng': 136.45},
      'departAt': '2026-11-14T09:00:00+09:00',
    });
    expect(start.placeId, isNull);
    expect(start.location, const LatLng(lat: 35.12, lng: 136.45));
  });

  test('POST /itineraries の start・end は placeId か location と name で送る', () {
    const request = CreateItineraryRequest(
      title: 'みなと町 日帰り旅',
      date: '2026-11-14',
      start: StartInput(placeId: 'ChIJ_s', departAt: '09:00'),
      end: EndInput(
        location: LatLng(lat: 34.57, lng: 135.48),
        name: '港の駐車場',
        arriveBy: '17:00',
      ),
      places: [
        PlaceInput(placeId: 'ChIJ_1', priority: Priority.must, stayMin: 60),
      ],
    );
    final json = request.toJson();
    expect(json['start'], {'placeId': 'ChIJ_s', 'departAt': '09:00'});
    expect(json['end'], {
      'location': {'lat': 34.57, 'lng': 135.48},
      'name': '港の駐車場',
      'arriveBy': '17:00',
    });
    expect(json.containsKey('endBy'), isFalse);
  });

  test('PUT /itineraries/:id/places は送らない項目を省く', () {
    const request = UpdatePlacesRequest(
      date: '2026-11-23',
      places: [
        PlaceInput(placeId: 'ChIJ_1', priority: Priority.must, stayMin: 60),
      ],
    );
    final json = request.toJson();
    expect(json['date'], '2026-11-23');
    expect(json.containsKey('start'), isFalse);
    expect(json.containsKey('end'), isFalse);
  });

  test('EndInput.fromEndpoint は施設でない地点を location と name で送る', () {
    final end = EndInput.fromEndpoint(
      ItineraryEnd(
        name: '港の駐車場',
        location: const LatLng(lat: 34.57, lng: 135.48),
        arriveBy: '17:00',
        arriveAt: DateTime.utc(2026, 11, 14, 7),
      ),
      arriveBy: '18:00',
    );
    expect(end.placeId, isNull);
    expect(end.name, '港の駐車場');
    expect(end.arriveBy, '18:00');
  });

  test('GET /me/itineraries の出力を読める', () {
    final page = ItineraryPage.fromJson({
      'itineraries': [
        {
          'id': 'itn_8f2k',
          'title': 'みなと町 日帰り旅',
          'date': '2026-11-14',
          'start': {'name': 'みなと町駅', 'departAt': '2026-11-14T09:00:00+09:00'},
          'end': {'name': 'みなと町駅', 'arriveAt': '2026-11-14T16:05:00+09:00'},
          'placeCount': 4,
          'placeNames': ['朝市通り', '旧港の倉庫街', '海の美術館'],
          'updatedAt': '2026-11-13T21:04:00+09:00',
          'expiresAt': '2026-12-14T00:00:00+09:00',
        },
      ],
      'nextCursor': null,
    });
    final entry = page.itineraries.single;
    expect(entry.placeCount, 4);
    expect(entry.placeNames, hasLength(3));
    expect(entry.end.name, 'みなと町駅');
    expect(page.nextCursor, isNull);
  });

  test('GET /places/nearby と GET /places/:placeId の出力を読める', () {
    final nearby = NearbyPlace.fromJson({
      'placeId': 'ChIJ_n',
      'name': '山あいの駅',
      'address': '山あい町 本町1',
      'location': {'lat': 35.12, 'lng': 136.45},
      'typeLabel': '駅',
    });
    expect(nearby.typeLabel, '駅');
    expect(nearby.place.placeId, 'ChIJ_n');

    final detail = PlaceDetail.fromJson({
      'place': {
        'placeId': 'ChIJ_d',
        'name': '共同浴場と足湯',
        'address': '山あい町 湯元3',
        'location': {'lat': 35.11, 'lng': 136.46},
      },
      'typeLabel': '温泉',
      'openingHours': null,
      'price': {'amount': 600, 'kind': 'estimate'},
    });
    expect(detail.openingHours, isNull);
    expect(detail.price.amount, 600);
  });

  test('end_at_risk の warning を読める', () {
    final warning = ReplanWarning.fromJson({
      'type': 'end_at_risk',
      'message': '17:00 までに駅に戻れません',
    });
    expect(warning.type, ReplanWarningType.endAtRisk);
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

  test('追加されたエラーコードを読める', () {
    for (final (value, code) in [
      ('END_INFEASIBLE', ApiErrorCode.endInfeasible),
      ('ITINERARY_LIMIT', ApiErrorCode.itineraryLimit),
    ]) {
      final e = ApiException.fromResponse(422, {
        'error': {'code': value, 'message': 'x'},
      });
      expect(e.code, code);
    }
  });
}
