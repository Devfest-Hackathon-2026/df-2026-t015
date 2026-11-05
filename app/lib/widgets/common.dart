import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../data/api/api_exception.dart';
import '../theme.dart';

/// 主要なボタン（高さ 60）。読み込み中は押せなくしてくるくるを出す。
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final child = loading
        ? SizedBox.square(
            dimension: tokens.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: tokens.selectedBorderWidth,
              color: context.colors.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: tokens.space10,
            children: [
              if (icon != null) Icon(icon, size: tokens.iconSize),
              Text(label),
            ],
          );
    return FilledButton(onPressed: loading ? null : onPressed, child: child);
  }
}

/// 戻るボタン付きの上部バー（デザインの 48px の戻るボタン + 見出し）
class BackTopBar extends StatelessWidget {
  const BackTopBar({
    super.key,
    required this.title,
    required this.onBack,
    this.backLabel = AppStrings.back,
  });

  final String title;
  final VoidCallback onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space12,
        tokens.space16,
        tokens.space12,
        0,
      ),
      child: Row(
        spacing: tokens.space4,
        children: [
          SizedBox.square(
            dimension: tokens.iconButtonSize,
            child: IconButton(
              tooltip: backLabel,
              onPressed: onBack,
              icon: Icon(Icons.chevron_left, size: tokens.iconSize),
            ),
          ),
          Text(title, style: context.texts.titleMedium),
        ],
      ),
    );
  }
}

/// 灰色のタイルに「ラベル + 値」を出す集計表示
class SummaryTile extends StatelessWidget {
  const SummaryTile({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.onTap,
  });

  final String label;
  final String value;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final texts = context.texts;
    final muted = context.colors.onSurfaceVariant;
    return Material(
      color: tokens.tileBackground,
      borderRadius: BorderRadius.circular(tokens.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusMedium),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space12,
            vertical: tokens.space10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.space2,
            children: [
              Text(label, style: texts.labelMedium?.copyWith(color: muted)),
              Text.rich(
                TextSpan(
                  text: value,
                  children: [
                    if (note != null)
                      TextSpan(
                        text: note,
                        style: texts.labelMedium?.copyWith(color: muted),
                      ),
                  ],
                ),
                style: texts.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum NoticeTone { warning, info }

/// 警告・案内の枠
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.tone,
    required this.body,
    this.title,
    this.icon,
  });

  final NoticeTone tone;
  final String? title;
  final Widget body;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = switch (tone) {
      NoticeTone.warning => tokens.warning,
      NoticeTone.info => tokens.info,
    };
    final defaultIcon = switch (tone) {
      NoticeTone.warning => Icons.warning_amber_rounded,
      NoticeTone.info => Icons.check,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(tokens.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: tokens.space12,
          children: [
            Icon(
              icon ?? defaultIcon,
              color: colors.icon,
              size: tokens.iconSize,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: tokens.space4,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: context.texts.titleMedium?.copyWith(
                        color: colors.title,
                      ),
                    ),
                  DefaultTextStyle.merge(
                    style: context.texts.bodyMedium?.copyWith(
                      color: colors.body,
                    ),
                    child: body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 枠線付きのカード
class OutlinedCard extends StatelessWidget {
  const OutlinedCard({
    super.key,
    required this.child,
    this.selected = false,
    this.background,
  });

  final Widget child;
  final bool selected;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final borderWidth = selected
        ? tokens.selectedBorderWidth
        : tokens.borderWidth;
    // 枠が太くなった分だけ内側の余白を減らし、中身の位置を揃える
    final inset = borderWidth - tokens.borderWidth;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? context.colors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLarge),
        border: Border.all(
          color: selected ? context.colors.primary : tokens.cardBorder,
          width: borderWidth,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space14 - inset,
          vertical: tokens.space12 - inset,
        ),
        child: child,
      ),
    );
  }
}

/// 読み込み中
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(semanticsLabel: AppStrings.loading),
  );
}

/// 読み込みに失敗したとき
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final message = switch (error) {
      final String text => text,
      ApiException(:final message) when message.isNotEmpty => message,
      _ => AppStrings.genericError,
    };
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: tokens.space16,
          children: [
            Text(
              message,
              style: context.texts.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              OutlinedButton(
                onPressed: onRetry,
                child: const Text(AppStrings.retry),
              ),
          ],
        ),
      ),
    );
  }
}

/// SnackBar でエラーを伝える
void showErrorSnackBar(BuildContext context, Object error, {String? fallback}) {
  final message = error is ApiException && error.message.isNotEmpty
      ? error.message
      : (fallback ?? AppStrings.genericError);
  showMessageSnackBar(context, message);
}

/// SnackBar で短いお知らせを出す
void showMessageSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
