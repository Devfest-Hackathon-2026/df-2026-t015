import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iterinerary/app.dart';
import 'package:iterinerary/constants/app_strings.dart';
import 'package:iterinerary/data/api/api_exception.dart';
import 'package:iterinerary/data/api/mock_itinerary_api.dart';
import 'package:iterinerary/data/models/models.dart';
import 'package:iterinerary/data/providers.dart';
import 'package:iterinerary/features/itineraries/itinerary_groups.dart';
import 'package:iterinerary/utils/format.dart';

CreateItineraryRequest overnightRequest({String? endDate = '2026-11-21'}) =>
    CreateItineraryRequest.fromJson({
      'title': '夜の旅',
      'date': '2026-11-20',
      'start': {'placeId': 'p_station', 'departAt': '23:00'},
      'end': {'placeId': 'p_station', 'date': ?endDate, 'arriveBy': '02:00'},
      'places': [
        {'placeId': 'p_asaichi', 'priority': 'must', 'stayMin': 60},
      ],
    });

void main() {
  test('終了日の旧JSONを受け付け、明示した終了日を往復できる', () {
    final legacy = EndInput.fromJson({
      'placeId': 'station',
      'arriveBy': '17:00',
    });
    expect(legacy.toJson().containsKey('date'), isFalse);
    expect(overnightRequest().end.toJson()['date'], '2026-11-21');
    final end = ItineraryEnd.fromJson({
      'placeId': 'station',
      'name': '駅',
      'date': '2026-11-21',
      'arriveBy': '02:00',
      'arriveAt': '2026-11-21T00:30:00+09:00',
    });
    expect(end.toJson()['date'], '2026-11-21');
    expect(
      EndInput.fromEndpoint(end, arriveBy: '03:00').toJson()['date'],
      '2026-11-21',
    );
  });

  test('新しい公共交通エラーを識別して説明を保持する', () {
    for (final code in ['TRANSIT_UNAVAILABLE', 'ROUTE_NOT_FOUND']) {
      final error = ApiException.fromResponse(503, {
        'error': {'code': code, 'message': '公共交通の経路を取得できません'},
      });
      expect(error.code.value, code);
      expect(error.message, '公共交通の経路を取得できません');
    }
  });

  test('2日目の旅程は実際の終了日まで今日に含める', () {
    final entry = ItineraryListEntry(
      id: 'overnight',
      title: '夜の旅',
      date: '2026-11-20',
      start: ItineraryListStart(
        name: '駅',
        departAt: DateTime(2026, 11, 20, 23),
      ),
      end: ItineraryListEnd(name: '駅', arriveAt: DateTime(2026, 11, 21, 1)),
      updatedAt: DateTime(2026, 11, 20),
    );
    final secondDay = ItineraryGroups.from([entry], DateTime(2026, 11, 21));
    expect(secondDay.today, [entry]);
    expect(secondDay.past, isEmpty);
    expect(ItineraryGroups.from([entry], DateTime(2026, 11, 22)).past, [entry]);
  });

  test('モックは翌日の終了日を保存し、コピーと日付変更で日数を保つ', () async {
    final api = MockItineraryApi(clock: () => DateTime(2026, 11, 19));
    final original = await api.createItinerary(overnightRequest());
    expect(original.end.toJson()['date'], '2026-11-21');
    expect(Format.isoDate(original.end.arriveAt), '2026-11-21');
    expect(original.expiresAt, DateTime(2026, 12, 21));
    final copied = await api.copyItinerary(
      original.id,
      const CopyItineraryRequest(date: '2026-12-01'),
    );
    expect(copied.end.toJson()['date'], '2026-12-02');
    expect(Format.isoDate(copied.items.single.startAt), '2026-12-01');
    expect(copied.items.single.status, ItemStatus.upcoming);
    final updated = await api.updatePlaces(
      original.id,
      UpdatePlacesRequest(
        date: '2026-12-03',
        places: overnightRequest().places,
      ),
      version: original.version,
    );
    expect(updated.end.toJson()['date'], '2026-12-04');
    expect(Format.isoDate(updated.end.arriveAt), '2026-12-04');
  });

  test('モックも同日の逆転した終了日時を拒否する', () async {
    final api = MockItineraryApi(clock: () => DateTime(2026, 11, 19));
    await expectLater(
      api.createItinerary(overnightRequest(endDate: null)),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
    );
  });

  test('モックは存在しない終了日と出発より前の終了日を拒否する', () async {
    final api = MockItineraryApi(clock: () => DateTime(2026, 11, 19));
    for (final endDate in ['2026-11-19', '2026-11-31']) {
      await expectLater(
        api.createItinerary(overnightRequest(endDate: endDate)),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
      );
    }
  });

  test('モックも翌日の終了期限に収まらない旅程を拒否する', () async {
    final api = MockItineraryApi(clock: () => DateTime(2026, 11, 19));
    final request = overnightRequest();
    await expectLater(
      api.createItinerary(
        request.copyWith(end: request.end.copyWith(arriveBy: '00:15')),
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.endInfeasible,
        ),
      ),
    );
  });

  test('終了地点を送って終了日を省く編集は開始日として扱う', () async {
    final api = MockItineraryApi(clock: () => DateTime(2026, 11, 19));
    final request = overnightRequest();
    final original = await api.createItinerary(request);
    await expectLater(
      api.updatePlaces(
        original.id,
        UpdatePlacesRequest(
          end: const EndInput(placeId: 'p_station', arriveBy: '02:00'),
          places: request.places,
        ),
        version: original.version,
      ),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
    );
  });

  test('コピー先が過去でも予定の状態をupcomingに戻す', () async {
    final api = MockItineraryApi(clock: () => DateTime(2026, 12, 10));
    final original = await api.createItinerary(overnightRequest());
    final copied = await api.copyItinerary(
      original.id,
      const CopyItineraryRequest(date: '2026-11-01'),
    );
    expect(copied.items.single.status, ItemStatus.upcoming);
  });

  test('翌日の遅延は終了日と比較して日付を戻さない', () async {
    final api = MockItineraryApi(clock: () => DateTime(2026, 11, 19));
    final original = await api.createItinerary(overnightRequest());
    final result = await api.createReplan(
      original.id,
      ReplanRequest(
        currentItemId: original.items.single.itemId,
        now: DateTime(2026, 11, 21, 0, 55),
      ),
    );
    expect(result.needsChange, isTrue);
    expect(
      result.warnings.any((w) => w.type == ReplanWarningType.endAtRisk),
      isFalse,
    );
    expect(
      Format.isoDate(result.options.single.summaryAfter.endAt),
      '2026-11-21',
    );
  });

  test('日またぎの組み直しは後続の予定と移動も遅らせる', () async {
    final api = MockItineraryApi(clock: () => DateTime(2026, 11, 19));
    final request = overnightRequest();
    final original = await api.createItinerary(
      request.copyWith(
        end: request.end.copyWith(arriveBy: '06:00'),
        places: [
          ...request.places,
          const PlaceInput(
            placeId: 'p_bijutsu',
            priority: Priority.want,
            stayMin: 60,
          ),
          const PlaceInput(
            placeId: 'p_toudai',
            priority: Priority.must,
            stayMin: 60,
          ),
        ],
      ),
    );
    final result = await api.createReplan(
      original.id,
      ReplanRequest(currentItemId: original.items.first.itemId, delayMin: 40),
    );
    final updated = await api.acceptReplan(
      original.id,
      result.replanId!,
      optionId: result.options.single.optionId,
      version: original.version,
    );
    expect(updated.items.last.startAt, DateTime(2026, 11, 21, 2, 25));
    for (final item in updated.items) {
      final outgoing = updated.legs.firstWhere(
        (leg) => leg.fromItemId == item.itemId,
      );
      expect(outgoing.departAt.isBefore(item.endAt), isFalse);
    }
    expect(updated.legs.last.arriveAt, updated.end.arriveAt);
  });

  testWidgets('編集で終了日を復元し、翌朝の時刻で保存できる', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = MockItineraryApi(clock: () => DateTime(2026, 11, 19));
    await tester.runAsync(() => api.createItinerary(overnightRequest()));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [itineraryApiProvider.overrideWithValue(api)],
        child: const IterineraryApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('夜の旅'));
    await tester.tap(find.text('夜の旅'));
    await tester.pumpAndSettle();
    expect(find.textContaining('11/21'), findsWidgets);
    await tester.tap(find.text(AppStrings.todayEditButton));
    await tester.pumpAndSettle();
    expect(find.text('終了日'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^終了日 11/21')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('^開始日 ')));
    await tester.pumpAndSettle();
    final picker = find.byType(DatePickerDialog);
    final labels = MaterialLocalizations.of(tester.element(picker));
    await tester.tap(find.descendant(of: picker, matching: find.text('22')));
    await tester.tap(find.text(labels.okButtonLabel));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('^終了日 11/23')), findsOneWidget);
    await tester.tap(find.text(AppStrings.planUpdate));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.planInvalidTimeRange), findsNothing);
    expect(find.text(AppStrings.todayEditButton), findsOneWidget);
  });
}
