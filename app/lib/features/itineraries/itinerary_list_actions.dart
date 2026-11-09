import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/api_constraints.dart';
import '../../constants/app_strings.dart';
import '../../data/api/itinerary_api.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../theme.dart';
import '../../utils/format.dart';

/// 日付を選べる範囲（今日から）
const _datePickerRange = Duration(days: 365);

/// 各旅程の「…」から選べる操作
enum ItineraryMenuAction { edit, copy, delete }

// ---------------------------------------------------------------------------
// API 呼び出し（F-09、F-11）
// ---------------------------------------------------------------------------

/// 一覧の 1 件には version が無いため、変更系の API の前に旅程を取得する。
/// 変更後は一覧と旅程 1 件の provider を読み直す。
class ItineraryListActions {
  const ItineraryListActions(this._ref);

  final WidgetRef _ref;

  ItineraryApi get _api => _ref.read(itineraryApiProvider);

  void _refresh(String id) {
    _ref.invalidate(myItinerariesProvider);
    _ref.invalidate(itineraryProvider(id));
  }

  /// 名前は PATCH、日付は PUT /places（時刻表が変わるので旅程全体を作り直す）
  Future<void> edit(
    String id, {
    required String title,
    required String date,
  }) async {
    var itinerary = await _api.getItinerary(id);
    if (title != itinerary.title) {
      itinerary = await _api.renameItinerary(
        id,
        title: title,
        version: itinerary.version,
      );
    }
    if (date != itinerary.date) {
      await _api.updatePlaces(
        id,
        UpdatePlacesRequest(
          date: date,
          places: [
            for (final item in itinerary.items)
              PlaceInput(
                placeId: item.placeId,
                priority: item.priority,
                stayMin: item.stayMin,
              ),
          ],
        ),
        version: itinerary.version,
      );
    }
    _refresh(id);
  }

  Future<void> copy(String id, {required String date}) async {
    await _api.copyItinerary(id, CopyItineraryRequest(date: date));
    _ref.invalidate(myItinerariesProvider);
  }

  Future<void> delete(String id) async {
    final itinerary = await _api.getItinerary(id);
    await _api.deleteItinerary(id, version: itinerary.version);
    _refresh(id);
  }
}

// ---------------------------------------------------------------------------
// 画面部品
// ---------------------------------------------------------------------------

/// 旅行日を選ぶ。過去の日付の旅程を開いた場合も、その日を初期値にできるようにする。
Future<String?> pickTripDate(
  BuildContext context, {
  required String initialDate,
  String? helpText,
}) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final initial = DateTime.parse(initialDate);
  final first = initial.isBefore(today) ? initial : today;
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first,
    lastDate: today.add(_datePickerRange),
    helpText: helpText,
  );
  return picked == null ? null : Format.isoDate(picked);
}

/// 「…」から開く操作のシート。削除は同じシートの中で確認してから返す。
Future<ItineraryMenuAction?> showItineraryMenu(
  BuildContext context,
  ItineraryListEntry entry,
) => showModalBottomSheet<ItineraryMenuAction>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _ItineraryMenuSheet(entry: entry),
);

class _ItineraryMenuSheet extends HookWidget {
  const _ItineraryMenuSheet({required this.entry});

  final ItineraryListEntry entry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final texts = context.texts;
    final confirming = useState(false);
    void close([ItineraryMenuAction? action]) =>
        Navigator.of(context).pop(action);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          0,
          tokens.screenPadding,
          tokens.space24,
        ),
        child: Semantics(
          label: entry.title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: tokens.space6,
            children: [
              Text(
                Format.dateJa(entry.date),
                style: texts.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: tokens.space8),
                child: Text(entry.title, style: texts.displaySmall),
              ),
              if (!confirming.value) ...[
                _SheetAction(
                  icon: Icons.edit_outlined,
                  label: AppStrings.listActionEdit,
                  onTap: () => close(ItineraryMenuAction.edit),
                ),
                _SheetAction(
                  icon: Icons.copy_outlined,
                  label: AppStrings.listActionCopy,
                  onTap: () => close(ItineraryMenuAction.copy),
                ),
                _SheetAction(
                  icon: Icons.delete_outline,
                  label: AppStrings.listActionDelete,
                  danger: true,
                  onTap: () => confirming.value = true,
                ),
                Padding(
                  padding: EdgeInsets.only(top: tokens.space4),
                  child: OutlinedButton(
                    onPressed: close,
                    child: const Text(AppStrings.listClose),
                  ),
                ),
              ] else ...[
                Text(AppStrings.listDeleteConfirm, style: texts.bodyLarge),
                SizedBox(height: tokens.space4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.danger.foreground,
                    foregroundColor: context.colors.onPrimary,
                  ),
                  onPressed: () => close(ItineraryMenuAction.delete),
                  child: const Text(AppStrings.listDeleteButton),
                ),
                OutlinedButton(
                  onPressed: close,
                  child: const Text(AppStrings.listCancel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final foreground = danger
        ? tokens.danger.foreground
        : context.colors.onSurface;
    final radius = BorderRadius.circular(tokens.radiusMedium);
    return Material(
      color: danger ? tokens.danger.background : tokens.tileBackground,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          height: tokens.sheetActionHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space16),
            child: Row(
              spacing: tokens.space14,
              children: [
                Icon(icon, size: tokens.iconSize, color: foreground),
                Text(
                  label,
                  style: context.texts.titleMedium?.copyWith(
                    color: foreground,
                    fontWeight: danger ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 「名前と日付を変える」のダイアログ。変更後の (名前, 日付) を返す。
Future<({String title, String date})?> showEditItineraryDialog(
  BuildContext context,
  ItineraryListEntry entry,
) => showDialog<({String title, String date})>(
  context: context,
  builder: (_) => _EditItineraryDialog(entry: entry),
);

class _EditItineraryDialog extends HookWidget {
  const _EditItineraryDialog({required this.entry});

  final ItineraryListEntry entry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final controller = useTextEditingController(text: entry.title);
    final date = useState(entry.date);
    useListenable(controller);
    final title = controller.text.trim();
    final valid = title.length >= ApiConstraints.titleMinLength;

    return AlertDialog(
      title: const Text(AppStrings.listEditTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space16,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: ApiConstraints.titleMaxLength,
            decoration: const InputDecoration(
              labelText: AppStrings.listEditNameLabel,
            ),
          ),
          OutlinedButton.icon(
            icon: Icon(
              Icons.calendar_today_outlined,
              size: tokens.smallIconSize,
            ),
            label: Text(
              '${AppStrings.listEditDateLabel}：${Format.dateJa(date.value)}',
            ),
            onPressed: () async {
              final picked = await pickTripDate(
                context,
                initialDate: date.value,
              );
              if (picked != null) date.value = picked;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.listCancel),
        ),
        TextButton(
          onPressed: valid
              ? () =>
                    Navigator.of(context).pop((title: title, date: date.value))
              : null,
          child: const Text(AppStrings.listEditSave),
        ),
      ],
    );
  }
}
