import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers.dart';
import '../../routing/routes.dart';
import '../../widgets/common.dart';
import '../itineraries/itinerary_groups.dart';

/// 起動直後の振り分け。その日の旅程があれば「今日の旅程」を直接開き、
/// なければ旅程一覧を開く（docs/iterinerary_app_ui_fac.docx 2 章）。
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itineraries = ref.watch(myItinerariesProvider);

    useEffect(() {
      final list = itineraries.value;
      if (list == null) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final today = ItineraryGroups.from(list, DateTime.now()).today;
        context.go(
          today.isEmpty ? Routes.itineraries : Routes.today(today.first.id),
        );
      });
      return null;
    }, [itineraries.value]);

    return Scaffold(
      body: itineraries.hasError
          ? ErrorView(
              error: itineraries.error!,
              onRetry: () => ref.invalidate(myItinerariesProvider),
            )
          : const LoadingView(),
    );
  }
}
