import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers.dart';
import '../../routing/routes.dart';
import '../../widgets/common.dart';

/// 起動直後の振り分け。旅程があれば旅行日の新しいものを開き、なければ行き先の入力へ進む。
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
        context.go(list.isEmpty ? Routes.plan : Routes.today(list.first.id));
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
