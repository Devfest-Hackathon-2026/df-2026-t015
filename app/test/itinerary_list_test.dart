import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iterinerary/app.dart';
import 'package:iterinerary/constants/app_strings.dart';
import 'package:iterinerary/data/api/mock_itinerary_api.dart';
import 'package:iterinerary/data/models/models.dart';
import 'package:iterinerary/data/providers.dart';
import 'package:iterinerary/features/itineraries/itinerary_groups.dart';
import 'package:iterinerary/utils/format.dart';

ItineraryListEntry _entry(String id, String date) => ItineraryListEntry(
  id: id,
  title: id,
  date: date,
  start: ItineraryListStart(
    name: '駅',
    departAt: DateTime.parse('${date}T09:00:00'),
  ),
  end: ItineraryListEnd(
    name: '駅',
    arriveAt: DateTime.parse('${date}T17:00:00'),
  ),
  updatedAt: DateTime(2026, 11, 1),
);

void main() {
  group('ItineraryGroups', () {
    final now = DateTime(2026, 11, 14, 10, 30);

    test('今日・これから（近い順）・終わった旅（新しい順）に分ける', () {
      // API と同じく旅行日の新しい順で渡す
      final groups = ItineraryGroups.from([
        _entry('dec5', '2026-12-05'),
        _entry('nov23', '2026-11-23'),
        _entry('today1', '2026-11-14'),
        _entry('today2', '2026-11-14'),
        _entry('nov3', '2026-11-03'),
        _entry('oct20', '2026-10-20'),
      ], now);

      expect(groups.today.map((e) => e.id), ['today1', 'today2']);
      expect(groups.upcoming.map((e) => e.id), ['nov23', 'dec5']);
      expect(groups.past.map((e) => e.id), ['nov3', 'oct20']);
      expect(groups.isEmpty, isFalse);
    });

    test('旅程が無ければ空', () {
      expect(ItineraryGroups.from(const [], now).isEmpty, isTrue);
    });

    test('残りの日数は時刻に関係なく日付で数える', () {
      expect(daysUntil('2026-11-14', now), 0);
      expect(daysUntil('2026-11-15', now), 1);
      expect(daysUntil('2026-11-23', now), 9);
      expect(daysUntil('2026-12-05', now), 21);
    });
  });

  testWidgets('旅程一覧に分けて並べ、確認してから削除できる', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // モックは今日・9 日後・21 日後・11 日前の旅程を用意している
    final api = MockItineraryApi();
    final container = ProviderContainer(
      overrides: [itineraryApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const IterineraryApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 起動時は旅程一覧を開く
    expect(find.text(AppStrings.listTitle), findsOneWidget);
    expect(
      find.text(
        '${AppStrings.listTodayPrefix}${Format.dateJa(Format.isoDate(DateTime.now()))}',
      ),
      findsOneWidget,
    );
    expect(find.text(AppStrings.listUpcoming), findsOneWidget);
    expect(find.text(AppStrings.listPast), findsOneWidget);
    expect(find.text('みなと町 日帰り旅'), findsOneWidget);
    expect(find.text('山あいの温泉町めぐり'), findsOneWidget);
    expect(find.text('あと9日'), findsOneWidget);
    expect(find.text('城下町さんぽ'), findsOneWidget);
    expect(find.text('あと21日'), findsOneWidget);
    expect(find.text('島の港町 日帰り'), findsOneWidget);
    expect(find.textContaining(AppStrings.listExpiresSuffix), findsOneWidget);
    expect(find.text(AppStrings.listCreate), findsOneWidget);
    // 旅程を作る画面が未完成のため、当面は押せない
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text(AppStrings.listCreate),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );

    // 「…」→ 削除 → 確認してから消える
    await tester.ensureVisible(
      find.byTooltip('島の港町 日帰り${AppStrings.listMenuSuffix}'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('島の港町 日帰り${AppStrings.listMenuSuffix}'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.listActionDelete));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.listDeleteConfirm), findsOneWidget);
    await tester.tap(find.text(AppStrings.listDeleteButton));
    await tester.pumpAndSettle();

    expect(find.text('島の港町 日帰り'), findsNothing);
    expect(find.text(AppStrings.listPast), findsNothing);
    expect(find.text(AppStrings.listDeleted), findsOneWidget);

    // これからの旅程を開くと、旅程の画面に進む
    await tester.ensureVisible(find.text('山あいの温泉町めぐり'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('山あいの温泉町めぐり'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.todayEditButton), findsOneWidget);
  });
}
