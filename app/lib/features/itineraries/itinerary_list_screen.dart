import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/app_strings.dart';
import '../../constants/api_constraints.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../routing/routes.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../today/today_screen.dart' show useNow;
import 'itinerary_groups.dart';
import 'itinerary_list_actions.dart';

/// 3.1 旅程一覧（F-08、F-09、F-11）。作った旅程をまとめて管理する。
///
/// 旅程を「今日」「これから」「終わった旅」に分けて並べ、
/// 画面下部に常に「新しい旅程を作る」ボタンを置く。
class ItineraryListScreen extends HookConsumerWidget {
  const ItineraryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itineraries = ref.watch(myItinerariesProvider);
    final now = useNow();
    final actions = ItineraryListActions(ref);
    final busy = useState(false);

    Future<void> run(Future<void> Function() task, String done) async {
      busy.value = true;
      try {
        await task();
        if (context.mounted) showMessageSnackBar(context, done);
      } catch (e) {
        if (context.mounted) showErrorSnackBar(context, e);
      } finally {
        busy.value = false;
      }
    }

    Future<void> openMenu(ItineraryListEntry entry) async {
      final action = await showItineraryMenu(context, entry);
      if (action == null || !context.mounted) return;
      switch (action) {
        case ItineraryMenuAction.edit:
          final result = await showEditItineraryDialog(context, entry);
          if (result == null) return;
          await run(
            () =>
                actions.edit(entry.id, title: result.title, date: result.date),
            AppStrings.listEdited,
          );
        case ItineraryMenuAction.copy:
          final date = await pickTripDate(
            context,
            initialDate: Format.isoDate(now),
            helpText: AppStrings.listCopyHelp,
          );
          if (date == null) return;
          await run(
            () => actions.copy(entry.id, date: date),
            AppStrings.listCopied,
          );
        case ItineraryMenuAction.delete:
          await run(() => actions.delete(entry.id), AppStrings.listDeleted);
      }
    }

    Future<void> open(ItineraryListEntry entry) async {
      await context.push(Routes.today(entry.id));
      // 旅程の画面で組み直しなどをした場合に、一覧の時刻を新しくする
      ref.invalidate(myItinerariesProvider);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            if (busy.value) const LinearProgressIndicator(),
            Expanded(
              child: switch (itineraries) {
                AsyncValue(:final value?) => RefreshIndicator(
                  onRefresh: () => ref.refresh(myItinerariesProvider.future),
                  child: _ListBody(
                    groups: ItineraryGroups.from(value, now),
                    now: now,
                    onOpen: open,
                    onMenu: openMenu,
                  ),
                ),
                AsyncError(:final error) => ErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(myItinerariesProvider),
                ),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CreateBar(
        onPressed: () => context.push(Routes.plan),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.space28,
        tokens.screenPadding,
        tokens.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tokens.space2,
        children: [
          Text(AppStrings.listTitle, style: context.texts.headlineMedium),
          Text(
            AppStrings.listSubtitle,
            style: context.texts.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.groups,
    required this.now,
    required this.onOpen,
    required this.onMenu,
  });

  final ItineraryGroups groups;
  final DateTime now;
  final void Function(ItineraryListEntry) onOpen;
  final void Function(ItineraryListEntry) onMenu;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final padding = EdgeInsets.fromLTRB(
      tokens.screenPadding,
      tokens.space8,
      tokens.screenPadding,
      tokens.space16,
    );
    if (groups.isEmpty) {
      // 引っぱって読み直せるよう、空でもスクロールできるようにする
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          SizedBox(height: tokens.space28),
          Text(
            AppStrings.listEmpty,
            textAlign: TextAlign.center,
            style: context.texts.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      children: [
        for (final section in [
          if (groups.today.isNotEmpty)
            _Section(
              title:
                  '${AppStrings.listTodayPrefix}${Format.dateJa(groups.today.first.date)}',
              children: [
                for (final e in groups.today)
                  _TodayCard(
                    entry: e,
                    now: now,
                    onTap: () => onOpen(e),
                    onMenu: () => onMenu(e),
                  ),
              ],
            ),
          if (groups.upcoming.isNotEmpty)
            _Section(
              title: AppStrings.listUpcoming,
              children: [
                for (final e in groups.upcoming)
                  _DateCard(
                    entry: e,
                    subtitle: _routeSummary(e),
                    note: _daysLeft(daysUntil(e.date, now)),
                    onTap: () => onOpen(e),
                    onMenu: () => onMenu(e),
                  ),
              ],
            ),
          if (groups.past.isNotEmpty)
            _Section(
              title: AppStrings.listPast,
              children: [
                for (final e in groups.past)
                  _DateCard(
                    entry: e,
                    subtitle: _expires(e),
                    past: true,
                    onMenu: () => onMenu(e),
                  ),
              ],
            ),
        ])
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space20),
            child: section,
          ),
      ],
    );
  }

  /// みなと町駅 09:00 → 16:05・4か所
  static String _routeSummary(ItineraryListEntry e) =>
      '${e.start.name} ${Format.time(e.start.departAt)}'
      '${AppStrings.listArrow}${Format.time(e.end.arriveAt)}'
      '${AppStrings.listPlaceSeparator}${e.placeCount}${AppStrings.listPlaceCountSuffix}';

  /// あと9日（翌日は「明日」）
  static String _daysLeft(int days) => days == 1
      ? AppStrings.listTomorrow
      : '${AppStrings.listDaysLeftPrefix}$days${AppStrings.listDaysLeftSuffix}';

  /// 12月3日に自動で消えます。expiresAt が無ければ旅行日から保存期間で求める。
  static String _expires(ItineraryListEntry e) {
    final expiresAt =
        e.expiresAt ?? DateTime.parse(e.date).add(ApiConstraints.itineraryTtl);
    return '${Format.monthDayJa(expiresAt)}${AppStrings.listExpiresSuffix}';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      label: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space8,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: context.texts.titleSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// 「…」ボタン（48px）
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox.square(
      dimension: tokens.iconButtonSize,
      child: IconButton(
        tooltip: '$title${AppStrings.listMenuSuffix}',
        color: context.colors.onSurfaceVariant,
        onPressed: onPressed,
        icon: Icon(Icons.more_horiz, size: tokens.iconSize),
      ),
    );
  }
}

/// 今日の旅程の大きなカード。「次の移動まで あと N 分」も出す。
class _TodayCard extends ConsumerWidget {
  const _TodayCard({
    required this.entry,
    required this.now,
    required this.onTap,
    required this.onMenu,
  });

  final ItineraryListEntry entry;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final texts = context.texts;
    final muted = context.colors.onSurfaceVariant;
    final radius = BorderRadius.circular(tokens.radiusXLarge);

    // 一覧の応答には移動の時刻が無いため、今日の旅程だけ 1 件を取得する
    final nextDepartAt = ref
        .watch(itineraryProvider(entry.id))
        .value
        ?.legs
        .map((l) => l.departAt)
        .where((t) => t.isAfter(now))
        .firstOrNull;

    final more = entry.placeCount - entry.placeNames.length;
    final places = [
      entry.placeNames.join(AppStrings.listPlaceSeparator),
      if (more > 0)
        '${AppStrings.listMorePlacesPrefix}$more${AppStrings.listPlaceCountSuffix}',
    ].join();

    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: context.colors.primary,
          width: tokens.selectedBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space16,
                  tokens.space14,
                  tokens.space4,
                  tokens.space14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: tokens.space6,
                  children: [
                    Text(entry.title, style: texts.displaySmall),
                    Text(
                      '${Format.time(entry.start.departAt)} ${entry.start.name}${AppStrings.listDepartSuffix}'
                      '${AppStrings.listArrow}'
                      '${Format.time(entry.end.arriveAt)} ${entry.end.name}${AppStrings.listArriveSuffix}',
                      style: texts.bodySmall?.copyWith(color: muted),
                    ),
                    if (places.isNotEmpty)
                      Text(
                        places,
                        style: texts.bodySmall?.copyWith(color: muted),
                      ),
                    if (nextDepartAt != null)
                      Padding(
                        padding: EdgeInsets.only(top: tokens.space4),
                        child: _NextMovePill(
                          minutes: nextDepartAt.difference(now).inMinutes,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: tokens.space6,
                right: tokens.space4,
              ),
              child: _MenuButton(title: entry.title, onPressed: onMenu),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextMovePill extends StatelessWidget {
  const _NextMovePill({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final foreground = context.colors.onPrimaryContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space12,
          vertical: tokens.space10,
        ),
        child: Row(
          spacing: tokens.space8,
          children: [
            Icon(Icons.schedule, size: tokens.smallIconSize, color: foreground),
            Expanded(
              child: Text(
                '${AppStrings.todayNextMovePrefix}${Format.duration(minutes)}',
                style: context.texts.labelLarge?.copyWith(color: foreground),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: tokens.smallIconSize,
              color: foreground,
            ),
          ],
        ),
      ),
    );
  }
}

/// 日付のバッジ付きのカード（これから・終わった旅）。
/// 終わった旅はデザインに合わせて開けないようにし、色を抑える。
class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.entry,
    required this.subtitle,
    required this.onMenu,
    this.note,
    this.onTap,
    this.past = false,
  });

  final ItineraryListEntry entry;
  final String subtitle;
  final String? note;
  final VoidCallback? onTap;
  final VoidCallback onMenu;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final texts = context.texts;
    final colors = context.colors;
    final muted = colors.onSurfaceVariant;
    final radius = BorderRadius.circular(tokens.radiusLarge);

    return Material(
      color: past ? tokens.cardDoneBackground : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: tokens.cardBorder, width: tokens.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space14,
                  tokens.space12,
                  tokens.space4,
                  tokens.space12,
                ),
                child: Row(
                  spacing: tokens.space12,
                  children: [
                    _DateBadge(date: entry.date, past: past),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: tokens.space2,
                        children: [
                          Text(
                            entry.title,
                            style: texts.titleMedium?.copyWith(
                              color: past
                                  ? tokens.priorityOptional.foreground
                                  : null,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: (past ? texts.labelMedium : texts.bodySmall)
                                ?.copyWith(color: muted),
                          ),
                          if (note != null)
                            Text(
                              note!,
                              style: texts.labelMedium?.copyWith(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: tokens.space4),
              child: _MenuButton(title: entry.title, onPressed: onMenu),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date, required this.past});

  final String date;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final muted = context.colors.onSurfaceVariant;
    return Container(
      width: tokens.dateBadgeWidth,
      padding: EdgeInsets.symmetric(vertical: tokens.space6),
      decoration: past
          ? null
          : BoxDecoration(
              color: tokens.tileBackground,
              borderRadius: BorderRadius.circular(tokens.radiusSmall),
            ),
      child: Column(
        children: [
          Text(
            Format.monthDay(date),
            style: context.texts.titleMedium?.copyWith(
              color: past ? muted : null,
            ),
          ),
          Text(
            Format.weekday(date),
            style: context.texts.labelSmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// 画面下部に常に置く「新しい旅程を作る」
class _CreateBar extends StatelessWidget {
  const _CreateBar({required this.onPressed});

  /// null なら押せない表示にする
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: tokens.cardBorder)),
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
          child: PrimaryButton(
            label: AppStrings.listCreate,
            icon: Icons.add,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
