import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iterinerary/app.dart';
import 'package:iterinerary/constants/app_strings.dart';
import 'package:iterinerary/data/api/mock_itinerary_api.dart';
import 'package:iterinerary/data/providers.dart';

/// モック API で「今日の旅程 → 遅れを伝える → 組み直し案 → 確定」を一通り操作する。
///
/// モックは予定の状態（完了・滞在中）を時計で決めるので、旅程の出発（9:00）より前の
/// 8:00 に固定する。実際の時刻で動かすと、テストを実行する時間帯によって
/// 最初の予定の次（置き換える予定）が無くなり、結果が変わってしまう。
void main() {
  testWidgets('遅れを伝えて組み直し案を確定できる', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day, 8);
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

    // 旅程一覧から今日の旅程を開く
    expect(find.text(AppStrings.listTitle), findsOneWidget);
    await tester.tap(find.text('みなと町 日帰り旅'));
    await tester.pumpAndSettle();

    // 今日の旅程
    expect(find.text('みなと町 日帰り旅'), findsOneWidget);
    expect(find.text(AppStrings.todayDelayButton), findsOneWidget);

    // 遅れを伝える：10 分なら間に合う
    await tester.tap(find.text(AppStrings.todayDelayButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10分'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.delayOkTitle), findsOneWidget);

    // 40 分なら組み直しが必要
    await tester.tap(find.text('40分'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.delayGoReplan), findsOneWidget);

    // 組み直し案：理由文が届くまで待ってから確定する
    await tester.tap(find.text(AppStrings.delayGoReplan));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.replanAccept), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.textContaining('港の資料館'), findsWidgets);

    await tester.tap(find.text(AppStrings.replanAccept));
    await tester.pumpAndSettle();

    // 確定後は今日の旅程に戻り、置き換え先が入っている
    expect(find.text(AppStrings.todayDelayButton), findsOneWidget);
    expect(find.text('港の資料館'), findsOneWidget);
  });
}
