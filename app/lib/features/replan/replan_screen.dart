import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/app_strings.dart';
import '../../data/api/api_exception.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../routing/routes.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';
import 'replan_providers.dart';

/// 3.4 組み直し案（F-04、F-05）
///
/// 変更点より先に「なぜ変えたか」を見せる。確定するまで旅程は変えない。
class ReplanScreen extends HookConsumerWidget {
  const ReplanScreen({super.key, required this.itineraryId});

  final String itineraryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final result = ref.watch(replanResultProvider(itineraryId));
    final itinerary = ref.watch(itineraryProvider(itineraryId)).value;
    final optionIndex = useState(0);
    final accepting = useState(false);

    void backToItinerary() {
      ref.read(replanResultProvider(itineraryId).notifier).clear();
      context.go(Routes.today(itineraryId));
    }

    final replanId = result?.replanId;
    final basedOnVersion = result?.basedOnVersion;
    if (result == null ||
        replanId == null ||
        basedOnVersion == null ||
        result.options.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: ErrorView(
            error: AppStrings.replanExpired,
            onRetry: backToItinerary,
          ),
        ),
      );
    }

    final option = result.options[optionIndex.value % result.options.length];
    final explanation = ref.watch(
      explanationProvider((
        itineraryId: itineraryId,
        replanId: replanId,
        optionId: option.optionId,
      )),
    );
    final names = {
      for (final i in itinerary?.items ?? const <Item>[]) i.itemId: i,
    };

    Future<void> accept() async {
      accepting.value = true;
      try {
        await ref
            .read(itineraryProvider(itineraryId).notifier)
            .acceptReplan(
              replanId: replanId,
              optionId: option.optionId,
              basedOnVersion: basedOnVersion,
            );
        if (context.mounted) backToItinerary();
      } on ApiException catch (e) {
        if (!context.mounted) return;
        final message = switch (e.code) {
          ApiErrorCode.versionConflict => AppStrings.replanConflict,
          ApiErrorCode.replanExpired => AppStrings.replanExpired,
          _ => null,
        };
        if (message == null) {
          showErrorSnackBar(context, e);
          return;
        }
        // 古い案での上書きはしない。旅程を読み直して戻る
        showMessageSnackBar(context, message);
        await ref.read(itineraryProvider(itineraryId).notifier).reload();
        if (context.mounted) backToItinerary();
      } finally {
        if (context.mounted) accepting.value = false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackTopBar(
              title: AppStrings.replanTopBar,
              backLabel: AppStrings.replanBackToDelay,
              onBack: () => context.pushReplacement(Routes.delay(itineraryId)),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  tokens.screenPadding,
                  tokens.space8,
                  tokens.screenPadding,
                  tokens.space16,
                ),
                children: [
                  _ExplanationBanner(explanation: explanation.value),
                  SizedBox(height: tokens.space16),
                  Text(
                    '${AppStrings.replanChangesPrefix}${option.changes.length}${AppStrings.replanChangesSuffix}',
                    style: context.texts.labelLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: tokens.space8),
                  for (final change in option.changes)
                    Padding(
                      padding: EdgeInsets.only(bottom: tokens.space10),
                      child: _ChangeCard(
                        change: change,
                        item: names[change.itemId],
                      ),
                    ),
                  SizedBox(height: tokens.space4),
                  _SummaryCompare(
                    before: option.summaryBefore,
                    after: option.summaryAfter,
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: tokens.cardBorder,
                    width: tokens.borderWidth,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.screenPadding,
                  tokens.space12,
                  tokens.screenPadding,
                  tokens.space24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: tokens.space8,
                  children: [
                    PrimaryButton(
                      label: AppStrings.replanAccept,
                      loading: accepting.value,
                      onPressed: accept,
                    ),
                    Row(
                      spacing: tokens.space8,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: result.options.length > 1
                                ? () => optionIndex.value++
                                : null,
                            child: const Text(AppStrings.replanOtherOption),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: backToItinerary,
                            child: const Text(AppStrings.replanKeepOriginal),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationBanner extends StatelessWidget {
  const _ExplanationBanner({required this.explanation});

  final Explanation? explanation;

  @override
  Widget build(BuildContext context) {
    final text = switch (explanation) {
      Explanation(status: ExplanationStatus.ready, :final text?) => text,
      Explanation(status: ExplanationStatus.failed) =>
        AppStrings.replanExplanationFailed,
      _ => AppStrings.replanExplanationPending,
    };
    return NoticeCard(
      tone: NoticeTone.warning,
      icon: Icons.schedule,
      body: Text(text),
    );
  }
}

class _ChangeCard extends StatelessWidget {
  const _ChangeCard({required this.change, required this.item});

  final ReplanChange change;
  final Item? item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final texts = context.texts;
    final muted = context.colors.onSurfaceVariant;
    final name = item?.name ?? change.before?.name ?? '';
    final detailStyle = texts.bodySmall?.copyWith(color: muted);

    String? time(DateTime? t) => t == null ? null : Format.time(t);

    final List<Widget> content = switch (change.type) {
      ChangeType.replace => [
        Wrap(
          spacing: tokens.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              change.before?.name ?? name,
              style: texts.bodyLarge?.copyWith(
                color: muted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: tokens.smallIconSize,
              color: muted,
              semanticLabel: AppStrings.replanArrow,
            ),
            Text(change.after?.name ?? '', style: texts.titleLarge),
          ],
        ),
        if (change.note != null || change.after?.price != null)
          Text(
            [
              ?change.note,
              if (change.after?.price case final price?) Format.price(price),
            ].join('・'),
            style: detailStyle,
          ),
      ],
      ChangeType.retime => [
        Text(name, style: texts.titleLarge),
        Text(
          '${AppStrings.replanStayChangedPrefix}${time(change.before?.endAt) ?? ''}${AppStrings.replanUntil}'
          '${AppStrings.replanArrow}${time(change.after?.endAt) ?? ''}${AppStrings.replanUntil}',
          style: detailStyle,
        ),
      ],
      ChangeType.keep => [
        Row(
          spacing: tokens.space8,
          children: [
            Flexible(child: Text(name, style: texts.titleLarge)),
            if (item != null) LabelChip.priority(item!.priority, tokens),
          ],
        ),
        if (time(item?.startAt ?? change.before?.startAt) case final t?)
          Text('$t${AppStrings.replanKeepTimeSuffix}', style: detailStyle),
      ],
      ChangeType.drop => [
        Text(
          name,
          style: texts.titleLarge?.copyWith(
            color: muted,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        if (change.note != null) Text(change.note!, style: detailStyle),
      ],
    };

    return OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.space4,
        children: [LabelChip.change(change.type, tokens), ...content],
      ),
    );
  }
}

class _SummaryCompare extends StatelessWidget {
  const _SummaryCompare({required this.before, required this.after});

  final Summary before;
  final Summary after;

  String _signed(int value, String Function(int) format) => value == 0
      ? AppStrings.unchanged
      : '（${value > 0 ? '+' : '−'}${format(value.abs())}）';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final endDiff = after.endAt.difference(before.endAt).inMinutes;
    final priceDiff = after.priceTotal.amount - before.priceTotal.amount;
    return Row(
      spacing: tokens.space8,
      children: [
        Expanded(
          child: SummaryTile(
            label: AppStrings.todayEndAt,
            value: Format.time(after.endAt),
            note: _signed(endDiff, Format.duration),
          ),
        ),
        Expanded(
          child: SummaryTile(
            label: AppStrings.todayPriceTotal,
            value: Format.yen(after.priceTotal.amount),
            note: _signed(priceDiff, Format.yen),
          ),
        ),
      ],
    );
  }
}
