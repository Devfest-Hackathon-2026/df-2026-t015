import 'package:flutter/material.dart';

/// デザインの値（色・余白・角丸・文字サイズ・ボタンの高さ）はすべてこのファイルに置く。
/// ウィジェットからは `Theme.of(context)` / `context.tokens` 経由で参照する。
/// 値は docs/iterinerary_ui.html（Iterinerary UI）に合わせている。

// ---------------------------------------------------------------------------
// パレット（このファイルの外から直接参照しない）
// ---------------------------------------------------------------------------
abstract final class _Palette {
  static const accent = Color(0xFF1F5FD1);
  static const accentText = Color(0xFF1A4FB0);
  static const accentStrong = Color(0xFF143D88);
  static const accentDeep = Color(0xFF1A3A70);
  static const accentSoft = Color(0xFFE8F0FD);
  static const accentOutline = Color(0xFF8FB0EE);

  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF16191D);
  static const inkMuted = Color(0xFF5A636E);
  static const inkNeutral = Color(0xFF4A525C);
  static const border = Color(0xFFC9D0D9);
  static const divider = Color(0xFFE3E7ED);
  static const surfaceMuted = Color(0xFFF3F5F8);
  static const surfaceDone = Color(0xFFFAFBFC);

  static const warnSoft = Color(0xFFFFF1E6);
  static const warnIcon = Color(0xFFB8480A);
  static const warnTitle = Color(0xFF8A3505);
  static const warnBody = Color(0xFF6B2C06);

  // 「除外」はデザインに無いため、警告系と区別できる赤系を当てている
  static const dropSoft = Color(0xFFFBEAEA);
  static const dropText = Color(0xFF8E1F1F);

  // 削除などの取り消せない操作
  static const dangerSoft = Color(0xFFFDECEA);
  static const danger = Color(0xFFA3231A);

  /// ボトムシートの背面（ink の 45%）
  static const scrim = Color(0x7316191D);
}

// ---------------------------------------------------------------------------
// ThemeExtension
// ---------------------------------------------------------------------------

/// ラベル（優先度・変更の種類など）の配色。色だけに頼らず必ず文字と組み合わせて使う。
@immutable
class LabelColors {
  const LabelColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  static LabelColors lerp(LabelColors a, LabelColors b, double t) =>
      LabelColors(
        background: Color.lerp(a.background, b.background, t)!,
        foreground: Color.lerp(a.foreground, b.foreground, t)!,
      );
}

/// お知らせ枠（警告・案内）の配色。
@immutable
class NoticeColors {
  const NoticeColors({
    required this.background,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color background;
  final Color icon;
  final Color title;
  final Color body;

  static NoticeColors lerp(NoticeColors a, NoticeColors b, double t) =>
      NoticeColors(
        background: Color.lerp(a.background, b.background, t)!,
        icon: Color.lerp(a.icon, b.icon, t)!,
        title: Color.lerp(a.title, b.title, t)!,
        body: Color.lerp(a.body, b.body, t)!,
      );
}

/// ColorScheme / TextTheme に収まらないデザインの値。
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    // 余白
    required this.space2,
    required this.space4,
    required this.space6,
    required this.space8,
    required this.space10,
    required this.space12,
    required this.space14,
    required this.space16,
    required this.space20,
    required this.space24,
    required this.space28,
    required this.screenPadding,
    // 角丸
    required this.radiusSegment,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.radiusXLarge,
    required this.radiusSheet,
    required this.radiusPill,
    // 高さ・サイズ
    required this.primaryButtonHeight,
    required this.secondaryButtonHeight,
    required this.inputHeight,
    required this.segmentHeight,
    required this.delayChoiceHeight,
    required this.sheetActionHeight,
    required this.iconButtonSize,
    required this.iconSize,
    required this.smallIconSize,
    required this.timeColumnWidth,
    required this.dateBadgeWidth,
    required this.planDateFieldWidth,
    required this.endpointLabelWidth,
    required this.endpointTimeWidth,
    required this.endpointFieldHeight,
    required this.borderWidth,
    required this.selectedBorderWidth,
    required this.legLineWidth,
    // 色
    required this.cardBorder,
    required this.cardDoneBackground,
    required this.tileBackground,
    required this.legLine,
    required this.selectedOutlineWant,
    required this.priorityMust,
    required this.priorityWant,
    required this.priorityOptional,
    required this.changeReplace,
    required this.changeRetime,
    required this.changeKeep,
    required this.changeDrop,
    required this.danger,
    required this.warning,
    required this.info,
  });

  final double space2;
  final double space4;
  final double space6;
  final double space8;
  final double space10;
  final double space12;
  final double space14;
  final double space16;
  final double space20;
  final double space24;
  final double space28;
  final double screenPadding;

  final double radiusSegment;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double radiusXLarge;
  final double radiusSheet;
  final double radiusPill;

  final double primaryButtonHeight;
  final double secondaryButtonHeight;
  final double inputHeight;
  final double segmentHeight;
  final double delayChoiceHeight;
  final double sheetActionHeight;
  final double iconButtonSize;
  final double iconSize;
  final double smallIconSize;
  final double timeColumnWidth;
  final double dateBadgeWidth;

  /// 新しい旅程：旅行日のボタンの幅
  final double planDateFieldWidth;

  /// 新しい旅程：「出発」「終わり」の見出しの幅
  final double endpointLabelWidth;

  /// 新しい旅程：出発・終わりの時刻ボタンの幅
  final double endpointTimeWidth;

  /// 新しい旅程：出発・終わりの時刻と場所のボタンの高さ
  final double endpointFieldHeight;
  final double borderWidth;
  final double selectedBorderWidth;
  final double legLineWidth;

  final Color cardBorder;
  final Color cardDoneBackground;
  final Color tileBackground;
  final Color legLine;
  final Color selectedOutlineWant;
  final LabelColors priorityMust;
  final LabelColors priorityWant;
  final LabelColors priorityOptional;
  final LabelColors changeReplace;
  final LabelColors changeRetime;
  final LabelColors changeKeep;
  final LabelColors changeDrop;
  final LabelColors danger;
  final NoticeColors warning;
  final NoticeColors info;

  static const light = AppTokens(
    space2: 2,
    space4: 4,
    space6: 6,
    space8: 8,
    space10: 10,
    space12: 12,
    space14: 14,
    space16: 16,
    space20: 20,
    space24: 24,
    space28: 28,
    screenPadding: 20,
    radiusSegment: 9,
    radiusSmall: 12,
    radiusMedium: 14,
    radiusLarge: 16,
    radiusXLarge: 18,
    radiusSheet: 22,
    radiusPill: 999,
    primaryButtonHeight: 60,
    secondaryButtonHeight: 48,
    inputHeight: 52,
    segmentHeight: 44,
    delayChoiceHeight: 76,
    sheetActionHeight: 56,
    iconButtonSize: 48,
    iconSize: 24,
    smallIconSize: 18,
    timeColumnWidth: 56,
    dateBadgeWidth: 56,
    planDateFieldWidth: 136,
    endpointLabelWidth: 52,
    endpointTimeWidth: 96,
    endpointFieldHeight: 44,
    borderWidth: 1,
    selectedBorderWidth: 2,
    legLineWidth: 2,
    cardBorder: _Palette.divider,
    cardDoneBackground: _Palette.surfaceDone,
    tileBackground: _Palette.surfaceMuted,
    legLine: _Palette.border,
    selectedOutlineWant: _Palette.accentOutline,
    priorityMust: LabelColors(
      background: _Palette.accent,
      foreground: _Palette.white,
    ),
    priorityWant: LabelColors(
      background: _Palette.accentSoft,
      foreground: _Palette.accentText,
    ),
    priorityOptional: LabelColors(
      background: _Palette.surfaceMuted,
      foreground: _Palette.inkNeutral,
    ),
    changeReplace: LabelColors(
      background: _Palette.warnSoft,
      foreground: _Palette.warnTitle,
    ),
    changeRetime: LabelColors(
      background: _Palette.accentSoft,
      foreground: _Palette.accentText,
    ),
    changeKeep: LabelColors(
      background: _Palette.surfaceMuted,
      foreground: _Palette.inkNeutral,
    ),
    changeDrop: LabelColors(
      background: _Palette.dropSoft,
      foreground: _Palette.dropText,
    ),
    danger: LabelColors(
      background: _Palette.dangerSoft,
      foreground: _Palette.danger,
    ),
    warning: NoticeColors(
      background: _Palette.warnSoft,
      icon: _Palette.warnIcon,
      title: _Palette.warnTitle,
      body: _Palette.warnBody,
    ),
    info: NoticeColors(
      background: _Palette.accentSoft,
      icon: _Palette.accentText,
      title: _Palette.accentStrong,
      body: _Palette.accentDeep,
    ),
  );

  @override
  AppTokens copyWith() => this;

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    // 余白やサイズはアニメーションさせないため、色だけ補間する
    return AppTokens(
      space2: space2,
      space4: space4,
      space6: space6,
      space8: space8,
      space10: space10,
      space12: space12,
      space14: space14,
      space16: space16,
      space20: space20,
      space24: space24,
      space28: space28,
      screenPadding: screenPadding,
      radiusSegment: radiusSegment,
      radiusSmall: radiusSmall,
      radiusMedium: radiusMedium,
      radiusLarge: radiusLarge,
      radiusXLarge: radiusXLarge,
      radiusSheet: radiusSheet,
      radiusPill: radiusPill,
      primaryButtonHeight: primaryButtonHeight,
      secondaryButtonHeight: secondaryButtonHeight,
      inputHeight: inputHeight,
      segmentHeight: segmentHeight,
      delayChoiceHeight: delayChoiceHeight,
      sheetActionHeight: sheetActionHeight,
      iconButtonSize: iconButtonSize,
      iconSize: iconSize,
      smallIconSize: smallIconSize,
      timeColumnWidth: timeColumnWidth,
      dateBadgeWidth: dateBadgeWidth,
      planDateFieldWidth: planDateFieldWidth,
      endpointLabelWidth: endpointLabelWidth,
      endpointTimeWidth: endpointTimeWidth,
      endpointFieldHeight: endpointFieldHeight,
      borderWidth: borderWidth,
      selectedBorderWidth: selectedBorderWidth,
      legLineWidth: legLineWidth,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardDoneBackground: Color.lerp(
        cardDoneBackground,
        other.cardDoneBackground,
        t,
      )!,
      tileBackground: Color.lerp(tileBackground, other.tileBackground, t)!,
      legLine: Color.lerp(legLine, other.legLine, t)!,
      selectedOutlineWant: Color.lerp(
        selectedOutlineWant,
        other.selectedOutlineWant,
        t,
      )!,
      priorityMust: LabelColors.lerp(priorityMust, other.priorityMust, t),
      priorityWant: LabelColors.lerp(priorityWant, other.priorityWant, t),
      priorityOptional: LabelColors.lerp(
        priorityOptional,
        other.priorityOptional,
        t,
      ),
      changeReplace: LabelColors.lerp(changeReplace, other.changeReplace, t),
      changeRetime: LabelColors.lerp(changeRetime, other.changeRetime, t),
      changeKeep: LabelColors.lerp(changeKeep, other.changeKeep, t),
      changeDrop: LabelColors.lerp(changeDrop, other.changeDrop, t),
      danger: LabelColors.lerp(danger, other.danger, t),
      warning: NoticeColors.lerp(warning, other.warning, t),
      info: NoticeColors.lerp(info, other.info, t),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
}

// ---------------------------------------------------------------------------
// ThemeData
// ---------------------------------------------------------------------------
abstract final class AppTheme {
  static const _fontFamily = 'Noto Sans JP';
  static const _lineHeight = 1.4;
  static const _bodyLineHeight = 1.6;
  static const _dragHandleWidth = 40.0;
  static const _dragHandleHeight = 5.0;

  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _Palette.accent,
    onPrimary: _Palette.white,
    primaryContainer: _Palette.accentSoft,
    onPrimaryContainer: _Palette.accentText,
    secondary: _Palette.accentText,
    onSecondary: _Palette.white,
    error: _Palette.warnIcon,
    onError: _Palette.white,
    errorContainer: _Palette.warnSoft,
    onErrorContainer: _Palette.warnTitle,
    surface: _Palette.white,
    onSurface: _Palette.ink,
    onSurfaceVariant: _Palette.inkMuted,
    surfaceContainer: _Palette.surfaceMuted,
    outline: _Palette.border,
    outlineVariant: _Palette.divider,
  );

  /// 本文は 15〜18px。焦っている場面でも読めるよう大きめにしている。
  static const textTheme = TextTheme(
    displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: _lineHeight,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: _lineHeight,
    ),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 15, height: _bodyLineHeight),
    bodySmall: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 13),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static ThemeData light() {
    const tokens = AppTokens.light;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
    );
    final texts = base.textTheme
        .merge(textTheme)
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );
    final largeShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radiusLarge),
    );
    final smallShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
    );

    return base.copyWith(
      textTheme: texts,
      extensions: const [tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: texts.titleMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(tokens.primaryButtonHeight),
          shape: largeShape,
          textStyle: texts.titleLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(tokens.secondaryButtonHeight),
          shape: smallShape,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          textStyle: texts.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size.fromHeight(tokens.secondaryButtonHeight),
          shape: smallShape,
          foregroundColor: colorScheme.onPrimaryContainer,
          textStyle: texts.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: tokens.space14),
        hintStyle: texts.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: tokens.borderWidth,
        space: tokens.borderWidth,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBarrierColor: _Palette.scrim,
        showDragHandle: true,
        dragHandleColor: colorScheme.outline,
        dragHandleSize: const Size(_dragHandleWidth, _dragHandleHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusSheet),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
