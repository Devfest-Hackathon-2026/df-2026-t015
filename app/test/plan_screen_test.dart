import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iterinerary/app.dart';
import 'package:iterinerary/constants/app_strings.dart';
import 'package:iterinerary/data/models/models.dart';
import 'package:iterinerary/features/plan/plan_screen.dart';
import 'package:iterinerary/routing/routes.dart';

/// 3.2 新しい旅程（出発・終わり・行き先と優先度）
void main() {
  Future<void> openApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ProviderScope(child: IterineraryApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('新しい旅程では旅行日・名前・出発と終わりを入力できる', (tester) async {
    await openApp(tester);
    // 一覧の「新しい旅程を作る」は当面押せないため、ルーターから開く
    GoRouter.of(tester.element(find.text(AppStrings.listTitle)))
        .push(Routes.plan);
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
