import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/api_constraints.dart';
import '../../constants/app_strings.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// 入力が止まってから補完を取りに行くまでの時間
const _autocompleteDebounce = Duration(milliseconds: 300);

/// 施設名の入力補完（GET /places/autocomplete）。入力が空の間は空リスト。
AsyncValue<List<Place>> useAutocomplete(WidgetRef ref, String query) {
  final result = useState<AsyncValue<List<Place>>>(const AsyncData([]));
  final trimmed = query.trim();
  useEffect(() {
    if (trimmed.length < ApiConstraints.autocompleteQueryMinLength) {
      result.value = const AsyncData([]);
      return null;
    }
    result.value = const AsyncLoading();
    var cancelled = false;
    final timer = Timer(_autocompleteDebounce, () async {
      final next = await AsyncValue.guard(
        () => ref.read(itineraryApiProvider).autocomplete(trimmed),
      );
      if (!cancelled) result.value = next;
    });
    return () {
      cancelled = true;
      timer.cancel();
    };
  }, [trimmed]);
  return result.value;
}

/// 施設を 1 件選ぶボトムシート。選んだ [Place] を返す。
class PlaceSearchSheet extends HookConsumerWidget {
  const PlaceSearchSheet({super.key, required this.title, required this.hint});

  final String title;
  final String hint;

  static Future<Place?> show(
    BuildContext context, {
    required String title,
    required String hint,
  }) => showModalBottomSheet<Place>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => PlaceSearchSheet(title: title, hint: hint),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final controller = useTextEditingController();
    final text = useValueListenable(controller).text;
    final candidates = useAutocomplete(ref, text);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        0,
        tokens.screenPadding,
        tokens.screenPadding + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space12,
        children: [
          Text(title, style: context.texts.titleLarge),
          SizedTextField(
            height: tokens.inputHeight,
            controller: controller,
            autofocus: true,
            maxLength: ApiConstraints.autocompleteQueryMaxLength,
            textInputAction: TextInputAction.search,
            hintText: hint,
          ),
          Flexible(
            child: SingleChildScrollView(
              child: switch (candidates) {
                AsyncError() => const Text(AppStrings.planSearchError),
                AsyncData(:final value)
                    when value.isEmpty &&
                        text.trim().length >=
                            ApiConstraints.autocompleteQueryMinLength =>
                  const Text(AppStrings.planSearchEmpty),
                _ => PlaceCandidateList(
                  candidates: candidates,
                  onPick: (place) => Navigator.of(context).pop(place),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 補完候補の一覧
class PlaceCandidateList extends StatelessWidget {
  const PlaceCandidateList({
    super.key,
    required this.candidates,
    required this.onPick,
  });

  final AsyncValue<List<Place>> candidates;
  final ValueChanged<Place> onPick;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return switch (candidates) {
      AsyncData(:final value) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final place in value)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.place_outlined, size: tokens.iconSize),
              title: Text(place.name, style: context.texts.bodyLarge),
              subtitle: place.address.isEmpty
                  ? null
                  : Text(
                      place.address,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
              onTap: () => onPick(place),
            ),
        ],
      ),
      AsyncError() => const SizedBox.shrink(),
      _ => Padding(
        padding: EdgeInsets.all(tokens.space12),
        child: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}
