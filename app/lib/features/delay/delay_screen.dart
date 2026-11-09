import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/api_constraints.dart';
import '../../constants/app_strings.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../routing/routes.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../replan/replan_providers.dart';
import '../today/today_screen.dart';

/// 大きなボタンで選べる遅れの大きさ（分）
const _delayChoices = <({int minutes, String label})>[
  (minutes: 10, label: '10分'),
  (minutes: 20, label: '20分'),
  (minutes: 40, label: '40分'),
  (minutes: 60, label: AppStrings.delayOverOneHour),
];

/// 3.3 遅れを伝える（F-03）
///
/// 選んだ時点で POST /itineraries/:id/replans を呼び、影響をすぐに表示する。
/// 組み直しが不要なら「このままで間に合います」と伝えて旅程に戻す。
class DelayScreen extends HookConsumerWidget {
  const DelayScreen({super.key, required this.itineraryId});

  final String itineraryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final itinerary = ref.watch(itineraryProvider(itineraryId)).value;
    final current = itinerary == null ? null : currentItemOf(itinerary);
    final replans = ref.read(replanResultProvider(itineraryId).notifier);

    final picked = useState<String?>(null);
    final result = useState<AsyncValue<ReplanResult>?>(null);

    Future<void> send(String label, ReplanRequest request) async {
      picked.value = label;
      result.value = const AsyncLoading();
      final next = await AsyncValue.guard(() => replans.request(request));
      if (context.mounted) result.value = next;
    }

    Future<void> pickTime() async {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time == null) return;
      final now = DateTime.now();
      final at = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      await send(
        Format.hhmm(time.hour, time.minute),
        ReplanRequest(currentItemId: current?.itemId, now: at),
      );
    }

    final value = result.value?.value;
    final late = value?.needsChange ?? false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackTopBar(
              title: AppStrings.delayTopBar,
              backLabel: AppStrings.delayBackToItinerary,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  tokens.screenPadding,
                  tokens.space16,
                  tokens.screenPadding,
                  tokens.space16,
                ),
                children: [
                  Text(
                    AppStrings.delayTitle,
                    style: context.texts.headlineMedium,
                  ),
                  if (current != null) ...[
                    SizedBox(height: tokens.space6),
                    Text(
                      '${AppStrings.delayCurrentPrefix}${current.name}（${Format.time(current.endAt)}${AppStrings.delayCurrentStaySuffix}）',
                      style: context.texts.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  SizedBox(height: tokens.space20),
                  GridView.count(
                    crossAxisCount: _delayChoices.length ~/ 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: tokens.space12,
                    crossAxisSpacing: tokens.space12,
                    mainAxisExtent: tokens.delayChoiceHeight,
                    children: [
                      for (final c in _delayChoices)
                        _DelayChoiceButton(
                          label: c.label,
                          selected: picked.value == c.label,
                          onTap: () => send(
                            c.label,
                            ReplanRequest(
                              currentItemId: current?.itemId,
                              delayMin: c.minutes.clamp(
                                ApiConstraints.delayMinMin,
                                ApiConstraints.delayMinMax,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: tokens.space12),
                  SizedBox(
                    height: tokens.inputHeight,
                    child: OutlinedButton(
                      onPressed: pickTime,
                      child: const Text(AppStrings.delayPickTime),
                    ),
                  ),
                  SizedBox(height: tokens.space20),
                  switch (result.value) {
                    null => const SizedBox.shrink(),
                    AsyncLoading() => Text(
                      AppStrings.delayChecking,
                      style: context.texts.bodyMedium,
                    ),
                    AsyncError(:final error) => ErrorView(error: error),
                    AsyncData(:final value) when value.needsChange =>
                      NoticeCard(
                        tone: NoticeTone.warning,
                        title:
                            '${picked.value}${AppStrings.delayLateTitleSuffix}',
                        body: Text(
                          value.warnings.map((w) => w.message).join('\n'),
                        ),
                      ),
                    AsyncData() => const NoticeCard(
                      tone: NoticeTone.info,
                      title: AppStrings.delayOkTitle,
                      body: Text(AppStrings.delayOkBody),
                    ),
                  },
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.screenPadding,
                tokens.space12,
                tokens.screenPadding,
                tokens.space24,
              ),
              child: late
                  ? PrimaryButton(
                      label: AppStrings.delayGoReplan,
                      onPressed: () =>
                          context.pushReplacement(Routes.replan(itineraryId)),
                    )
                  : PrimaryButton(
                      label: AppStrings.delayBackToItinerary,
                      onPressed: result.value is AsyncLoading
                          ? null
                          : () => context.pop(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DelayChoiceButton extends StatelessWidget {
  const _DelayChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(tokens.delayChoiceHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLarge),
        ),
        backgroundColor: selected ? colors.primaryContainer : colors.surface,
        foregroundColor: selected ? tokens.info.title : colors.onSurface,
        side: BorderSide(
          color: selected ? colors.primary : colors.outline,
          width: selected ? tokens.selectedBorderWidth : tokens.borderWidth,
        ),
        textStyle: context.texts.displaySmall,
      ),
      child: Text(label),
    );
  }
}
