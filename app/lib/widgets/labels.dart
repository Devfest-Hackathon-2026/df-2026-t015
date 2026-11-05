import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../data/models/models.dart';
import '../theme.dart';

/// 色だけに頼らず、必ず文字のラベルで区別する。
extension PriorityText on Priority {
  String get label => switch (this) {
    Priority.must => AppStrings.priorityMust,
    Priority.want => AppStrings.priorityWant,
    Priority.optional => AppStrings.priorityOptional,
  };

  LabelColors colors(AppTokens tokens) => switch (this) {
    Priority.must => tokens.priorityMust,
    Priority.want => tokens.priorityWant,
    Priority.optional => tokens.priorityOptional,
  };
}

extension ChangeTypeText on ChangeType {
  String get label => switch (this) {
    ChangeType.replace => AppStrings.replanReplace,
    ChangeType.retime => AppStrings.replanRetime,
    ChangeType.keep => AppStrings.replanKeep,
    ChangeType.drop => AppStrings.replanDrop,
  };

  LabelColors colors(AppTokens tokens) => switch (this) {
    ChangeType.replace => tokens.changeReplace,
    ChangeType.retime => tokens.changeRetime,
    ChangeType.keep => tokens.changeKeep,
    ChangeType.drop => tokens.changeDrop,
  };
}

extension TransitModeText on TransitMode {
  String get label => switch (this) {
    TransitMode.walk => AppStrings.walk,
    TransitMode.bus => AppStrings.bus,
    TransitMode.train => AppStrings.train,
    TransitMode.taxi => AppStrings.taxi,
  };

  IconData get icon => switch (this) {
    TransitMode.walk => Icons.directions_walk,
    TransitMode.bus => Icons.directions_bus_outlined,
    TransitMode.train => Icons.train_outlined,
    TransitMode.taxi => Icons.local_taxi_outlined,
  };
}

/// 丸いラベル（必須／できれば、置き換え／時刻を調整 など）
class LabelChip extends StatelessWidget {
  const LabelChip({super.key, required this.text, required this.colors});

  factory LabelChip.priority(Priority priority, AppTokens tokens) =>
      LabelChip(text: priority.label, colors: priority.colors(tokens));

  factory LabelChip.change(ChangeType type, AppTokens tokens) =>
      LabelChip(text: type.label, colors: type.colors(tokens));

  final String text;
  final LabelColors colors;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space2,
        ),
        child: Text(
          text,
          style: context.texts.labelSmall?.copyWith(color: colors.foreground),
        ),
      ),
    );
  }
}
