import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/app_strings.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../routing/routes.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';

/// 「次の移動まで あと N 分」を更新する間隔
const _clockTick = Duration(seconds: 30);

/// 今いる予定。滞在中のものが無ければ、次に行く予定。
Item? currentItemOf(Itinerary itinerary) =>
    itinerary.items.where((i) => i.status == ItemStatus.current).firstOrNull ??
    itinerary.items.where((i) => i.status == ItemStatus.upcoming).firstOrNull;

/// 1 分ごとくらいに再描画するための現在時刻
DateTime useNow() {
  final now = useState(DateTime.now());
  useEffect(() {
    final timer = Timer.periodic(_clockTick, (_) => now.value = DateTime.now());
    return timer.cancel;
  }, const []);
  return now.value;
}

/// 3.2 今日の旅程（F-06）。旅行当日に開きっぱなしにするメイン画面。
class TodayScreen extends HookConsumerWidget {
  const TodayScreen({super.key, required this.itineraryId});

  final String itineraryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itinerary = ref.watch(itineraryProvider(itineraryId));
    final notifier = ref.read(itineraryProvider(itineraryId).notifier);

    // 一覧から push されていれば戻る。go で直接開いたときは一覧を開き直す
    void backToList() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(Routes.itineraries);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackTopBar(
              title: AppStrings.listTitle,
              backLabel: AppStrings.todayBackToList,
              onBack: backToList,
            ),
            Expanded(
              child: switch (itinerary) {
                AsyncValue(:final value?) => _TodayBody(
                  itinerary: value,
                  onRefresh: notifier.reload,
                ),
                AsyncError(:final error) => ErrorView(
                  error: error,
                  onRetry: notifier.reload,
                ),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: itinerary.hasValue
          ? _BottomActions(
              onDelay: () => context.push(Routes.delay(itineraryId)),
              onEdit: () => context.push(Routes.edit(itineraryId)),
            )
          : null,
    );
  }
}

class _TodayBody extends HookWidget {
  const _TodayBody({required this.itinerary, required this.onRefresh});

  final Itinerary itinerary;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final now = useNow();
    final summary = itinerary.summary;
    final nextLeg = itinerary.legs
        .where((l) => l.departAt.isAfter(now))
        .firstOrNull;
    final legsByTo = {for (final l in itinerary.legs) l.toItemId: l};

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space8,
          tokens.screenPadding,
          tokens.space16,
        ),
        children: [
          Text(
            Format.dateJa(itinerary.date),
            style: context.texts.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.space2),
          Text(itinerary.title, style: context.texts.headlineMedium),
          SizedBox(height: tokens.space12),
          Row(
            spacing: tokens.space8,
            children: [
              Expanded(
                child: SummaryTile(
                  label: AppStrings.todayMoveTotal,
                  value: Format.minutes(summary.moveMin),
                ),
              ),
              Expanded(
                child: SummaryTile(
                  label: AppStrings.todayPriceTotal,
                  value: Format.yen(summary.priceTotal.amount),
                ),
              ),
              Expanded(
                child: SummaryTile(
                  label: AppStrings.todayEndAt,
                  value: Format.dateTime(summary.endAt, date: itinerary.date),
                ),
              ),
            ],
          ),
          if (nextLeg != null) ...[
            SizedBox(height: tokens.space12),
            _NextMoveBanner(
              minutes: nextLeg.departAt.difference(now).inMinutes,
            ),
          ],
          SizedBox(height: tokens.space16),
          for (final (index, item) in itinerary.items.indexed) ...[
            if (index == 0 ||
                Format.isoDate(item.startAt.toLocal()) !=
                    Format.isoDate(
                      itinerary.items[index - 1].startAt.toLocal(),
                    ))
              Padding(
                padding: EdgeInsets.only(top: tokens.space8),
                child: Text(
                  Format.dateJa(Format.isoDate(item.startAt.toLocal())),
                  style: context.texts.titleSmall,
                ),
              ),
            if (legsByTo[item.itemId] case final leg?) _LegRow(leg: leg),
            _ItemRow(item: item),
          ],
          if (legsByTo[Leg.endItemId] case final leg?) _LegRow(leg: leg),
          Padding(
            padding: EdgeInsets.only(top: tokens.space8),
            child: Text(
              '${Format.dateTime(itinerary.end.arriveAt, date: itinerary.date)} ${itinerary.end.name}',
              style: context.texts.titleSmall,
            ),
          ),
          if (itinerary.dropped.isNotEmpty) ...[
            SizedBox(height: tokens.space16),
            NoticeCard(
              tone: NoticeTone.warning,
              title: AppStrings.todayDropped,
              body: Text(
                itinerary.dropped
                    .map((d) => '${d.name}：${d.reason}')
                    .join('\n'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextMoveBanner extends StatelessWidget {
  const _NextMoveBanner({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.info;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space14,
          vertical: tokens.space10,
        ),
        child: Row(
          spacing: tokens.space8,
          children: [
            Icon(
              Icons.schedule,
              color: colors.icon,
              size: tokens.smallIconSize,
            ),
            Text(
              '${AppStrings.todayNextMovePrefix} ${Format.duration(minutes)}',
              style: context.texts.labelLarge?.copyWith(color: colors.icon),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final texts = context.texts;
    final muted = context.colors.onSurfaceVariant;
    final done = item.status == ItemStatus.done;
    final current = item.status == ItemStatus.current;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.space12,
      children: [
        SizedBox(
          width: tokens.timeColumnWidth,
          child: Padding(
            padding: EdgeInsets.only(top: tokens.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Format.time(item.startAt),
                  style: texts.titleMedium?.copyWith(
                    color: done ? muted : null,
                  ),
                ),
                Text(
                  Format.dateTime(
                    item.endAt,
                    date: Format.isoDate(item.startAt.toLocal()),
                  ),
                  style: texts.labelMedium?.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: OutlinedCard(
            selected: current,
            background: done ? tokens.cardDoneBackground : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: tokens.space6,
              children: [
                Row(
                  spacing: tokens.space8,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: texts.titleLarge?.copyWith(
                          color: done ? muted : null,
                        ),
                      ),
                    ),
                    if (done)
                      Row(
                        spacing: tokens.space4,
                        children: [
                          Icon(
                            Icons.check,
                            size: tokens.smallIconSize,
                            color: muted,
                          ),
                          Text(
                            AppStrings.todayDone,
                            style: texts.labelMedium?.copyWith(color: muted),
                          ),
                        ],
                      ),
                    if (current)
                      Text(
                        AppStrings.todayCurrent,
                        style: texts.labelSmall?.copyWith(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                  ],
                ),
                DefaultTextStyle.merge(
                  style: texts.bodySmall?.copyWith(color: muted),
                  child: Row(
                    spacing: tokens.space8,
                    children: [
                      LabelChip.priority(item.priority, tokens),
                      Expanded(
                        child: Text(
                          '${AppStrings.planStayPrefix}${Format.duration(item.stayMin)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          Format.price(item.price),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegRow extends StatelessWidget {
  const _LegRow({required this.leg});

  final Leg leg;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final muted = context.colors.onSurfaceVariant;
    // 線を時刻の列の中央に引き、文字はカードの左端に揃える
    final lineInset = (tokens.timeColumnWidth - tokens.legLineWidth) / 2;
    final textInset =
        tokens.timeColumnWidth +
        tokens.space12 -
        lineInset -
        tokens.legLineWidth;
    final text = leg.mode == TransitMode.walk
        ? '${leg.mode.label} ${Format.duration(leg.durationMin)}'
        : '${leg.mode.label} ${Format.duration(leg.durationMin)}・${Format.dateTime(leg.departAt)}${AppStrings.departSuffix}';

    return Padding(
      padding: EdgeInsets.only(left: lineInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: tokens.legLine, width: tokens.legLineWidth),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            textInset,
            tokens.space8,
            0,
            tokens.space8,
          ),
          child: Row(
            spacing: tokens.space8,
            children: [
              Icon(leg.mode.icon, size: tokens.smallIconSize, color: muted),
              Flexible(
                child: Text(
                  [text, ?leg.lineName].join('  '),
                  style: context.texts.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 画面下部に常に置く「予定より遅れている」ボタン（片手の親指で届く位置）
class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onDelay, required this.onEdit});

  final VoidCallback onDelay;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: tokens.cardBorder, width: tokens.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.space12,
            tokens.screenPadding,
            tokens.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: tokens.space4,
            children: [
              PrimaryButton(
                label: AppStrings.todayDelayButton,
                icon: Icons.schedule,
                onPressed: onDelay,
              ),
              TextButton(
                onPressed: onEdit,
                child: const Text(AppStrings.todayEditButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
