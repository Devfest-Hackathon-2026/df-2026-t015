import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iterinerary/app.dart';
import 'package:iterinerary/constants/app_strings.dart';
import 'package:iterinerary/data/api/mock_itinerary_api.dart';
import 'package:iterinerary/data/models/models.dart';
import 'package:iterinerary/data/providers.dart';
import 'package:iterinerary/features/plan/place_search.dart';
import 'package:iterinerary/features/plan/plan_screen.dart';

/// 3.2 新しい旅程（出発・終わり・行き先と優先度）
void main() {
  Future<void> openApp(WidgetTester tester, {int hour = 0}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day, hour);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itineraryApiProvider.overrideWithValue(
            MockItineraryApi(clock: () => now),
          ),
        ],
        child: const IterineraryApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('新しい旅程では旅行日・名前・出発と終わりを入力できる', (tester) async {
    await openApp(tester);
    await tester.tap(find.text(AppStrings.listCreate));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.planTopBarNew), findsOneWidget);
    expect(find.text(AppStrings.planDateLabel), findsOneWidget);
    expect(find.text(AppStrings.planTitleLabel), findsOneWidget);
    expect(find.text(AppStrings.planStart), findsOneWidget);
    expect(find.text(AppStrings.planEnd), findsOneWidget);
    expect(find.text(AppStrings.planStartUnset), findsOneWidget);
    expect(find.text(AppStrings.planEndUnset), findsOneWidget);
    expect(find.text(AppStrings.planPlacesHeader), findsOneWidget);
    expect(find.byTooltip(AppStrings.planCloseNew), findsOneWidget);

    // 閉じると旅程一覧に戻る
    await tester.tap(find.byTooltip(AppStrings.planCloseNew));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.listTitle), findsOneWidget);
  });

  testWidgets('変更した出発と終わりを保存し、開き直して確認できる', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('みなと町 日帰り旅'));
    await tester.pumpAndSettle();
    final editButton = find.text(AppStrings.todayEditButton);
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    Future<void> selectPlace(String label, String query, String name) async {
      await tester.tap(find.bySemanticsLabel(RegExp('^$label .*検索する')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(PlaceSearchSheet),
          matching: find.byType(TextField),
        ),
        query,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    Future<void> setTime(String label, String hour, {String? period}) async {
      await tester.tap(find.bySemanticsLabel(RegExp('^$label .*を変える')));
      await tester.pumpAndSettle();
      final dialog = find.byType(TimePickerDialog);
      final labels = MaterialLocalizations.of(tester.element(dialog));
      await tester.tap(find.byTooltip(labels.inputTimeModeButtonLabel));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: dialog,
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.first, hour);
      if (period != null) {
        await tester.tap(
          find.descendant(of: dialog, matching: find.text(period)),
        );
      }
      await tester.tap(find.text(labels.okButtonLabel));
      await tester.pumpAndSettle();
    }

    await selectPlace(AppStrings.planStartPlaceLabel, '城下町', '城下町駅');
    await selectPlace(AppStrings.planEndPlaceLabel, '山あい', '山あいの駅');
    await setTime(AppStrings.planStartTimeLabel, '6', period: 'PM');
    await tester.tap(find.text(AppStrings.planUpdate));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.planInvalidTimeRange), findsOneWidget);
    expect(find.text(AppStrings.planTopBarEdit), findsOneWidget);

    await setTime(AppStrings.planStartTimeLabel, '10', period: 'AM');
    await setTime(AppStrings.planEndTimeLabel, '6');
    await tester.tap(find.text(AppStrings.planUpdate));
    await tester.pumpAndSettle();
    await tester.tap(editButton);
    await tester.pumpAndSettle();
    expect(find.text('城下町駅'), findsOneWidget);
    expect(find.text('山あいの駅'), findsOneWidget);
    expect(find.text('10:00', findRichText: true), findsOneWidget);
    expect(find.text('18:00 まで', findRichText: true), findsOneWidget);
  });

  testWidgets('編集では今の旅程の名前・出発地・終わる場所が入っている', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('みなと町 日帰り旅'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.todayEditButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.planTopBarEdit), findsOneWidget);
    expect(find.text('みなと町 日帰り旅'), findsOneWidget);
    // 出発地と終わる場所
    expect(find.text('みなと町駅'), findsNWidgets(2));
    expect(find.text(AppStrings.planUpdate), findsOneWidget);
  });

  testWidgets('開始済みの旅程は同じ日の出発地と時刻を変更できない', (tester) async {
    await openApp(tester, hour: 12);
    await tester.tap(find.text('みなと町 日帰り旅'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.todayEditButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.planStartLocked), findsOneWidget);
    final departure = find.bySemanticsLabel('出発時刻 09:00');
    await tester.tap(departure);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);

    await tester.tap(find.bySemanticsLabel('終わりの時刻 17:00 までを変える'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  test('名前が空欄なら行き先から名前をつける', () {
    PlanEntry entry(String name) => PlanEntry(
      place: Place(placeId: name, name: name),
    );

    expect(autoTitle([entry('朝市通り')]), '朝市通り');
    expect(autoTitle([entry('朝市通り'), entry('海の美術館')]), '朝市通り・海の美術館');
    expect(
      autoTitle([entry('朝市通り'), entry('海の美術館'), entry('灯台の丘')]),
      '朝市通り・海の美術館 ほか',
    );
  });
}
