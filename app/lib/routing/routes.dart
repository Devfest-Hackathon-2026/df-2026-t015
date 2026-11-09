import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/delay/delay_screen.dart';
import '../features/home/home_screen.dart';
import '../features/itineraries/itinerary_list_screen.dart';
import '../features/plan/plan_screen.dart';
import '../features/replan/replan_screen.dart';
import '../features/today/today_screen.dart';

/// 画面のパス。画面遷移は docs/iterinerary_app_ui_fac.docx の「2. 画面構成と遷移」に従う。
///
/// 旅程一覧 → 行き先と優先度 → 今日の旅程 ⇄ 遅れを伝える → 組み直し案 → 今日の旅程
///
/// 旅程の画面は旅程一覧の下に置き、`go` で直接開いても戻ると旅程一覧になるようにする。
abstract final class Routes {
  static const home = '/';
  static const plan = '/plan';
  static const itineraries = '/itineraries';
  static const _idParam = 'id';
  static const _itinerary = ':$_idParam';

  static String today(String id) => '$itineraries/$id';
  static String edit(String id) => '${today(id)}/edit';
  static String delay(String id) => '${today(id)}/delay';
  static String replan(String id) => '${today(id)}/replan';
}

final routerProvider = Provider<GoRouter>((ref) {
  String id(GoRouterState state) => state.pathParameters[Routes._idParam]!;
  return GoRouter(
    // 当面は旅程一覧から始める。今日の旅程を直接開く振り分けは Routes.home（HomeScreen）に残してある
    initialLocation: Routes.itineraries,
    routes: [
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: Routes.plan, builder: (_, _) => const PlanScreen()),
      GoRoute(
        path: Routes.itineraries,
        builder: (_, _) => const ItineraryListScreen(),
        routes: [
          GoRoute(
            path: Routes._itinerary,
            builder: (_, state) => TodayScreen(itineraryId: id(state)),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, state) => PlanScreen(itineraryId: id(state)),
              ),
              GoRoute(
                path: 'delay',
                builder: (_, state) => DelayScreen(itineraryId: id(state)),
              ),
              GoRoute(
                path: 'replan',
                builder: (_, state) => ReplanScreen(itineraryId: id(state)),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
