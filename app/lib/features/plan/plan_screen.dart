import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/api_constraints.dart';
import '../../constants/app_strings.dart';
import '../../data/api/api_exception.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../routing/routes.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/common.dart';
import '../../widgets/labels.dart';
import 'place_search.dart';

// 入力の初期値
const _defaultDepartHour = 9;
const _defaultEndByHour = 17;
const _defaultStayMin = 60;
const _defaultPriority = Priority.want;
const _stayChoices = [30, 60, 90, 120, 180, 240];
const _datePickerRange = Duration(days: 365);

/// 行き先 1 件の入力
@immutable
class PlanEntry {
  const PlanEntry({
    required this.place,
    this.priority = _defaultPriority,
    this.stayMin = _defaultStayMin,
  });

  final Place place;
  final Priority priority;
  final int stayMin;

  PlanEntry copyWith({Priority? priority, int? stayMin}) => PlanEntry(
    place: place,
    priority: priority ?? this.priority,
    stayMin: stayMin ?? this.stayMin,
  );

  PlaceInput toInput() =>
      PlaceInput(placeId: place.placeId, priority: priority, stayMin: stayMin);
}

/// 3.1 行き先と優先度（F-01、F-02）
///
/// [itineraryId] があれば既存の旅程の行き先を編集して作り直す（PUT /itineraries/:id/places）。
class PlanScreen extends HookConsumerWidget {
  const PlanScreen({super.key, this.itineraryId});

  final String? itineraryId;

  bool get _isEdit => itineraryId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final api = ref.watch(itineraryApiProvider);

    final entries = useState<List<PlanEntry>>(const []);
    final start = useState<Place?>(null);
    // 編集のとき、出発地を選び直したか（選び直していなければ今の出発地を送り直す）
    final startPicked = useState(false);
    final date = useState(DateUtils.dateOnly(DateTime.now()));
    final departAt = useState(
      const TimeOfDay(hour: _defaultDepartHour, minute: 0),
    );
    final endBy = useState(const TimeOfDay(hour: _defaultEndByHour, minute: 0));
    final submitting = useState(false);
    final interpreting = useState(false);
    final interpreted = useState<List<InterpretedCandidate>>(const []);

    final input = useTextEditingController();
    final query = useValueListenable(input).text;
    final autocomplete = useAutocomplete(ref, query);

    // 編集のときは今の旅程で埋める
    final existing = _isEdit
        ? ref.watch(itineraryProvider(itineraryId!))
        : null;
    final prefilled = useState(false);
    useEffect(() {
      final itinerary = existing?.value;
      if (itinerary == null || prefilled.value) return null;
      prefilled.value = true;
      entries.value = [
        for (final item in itinerary.items)
          PlanEntry(
            place: Place(placeId: item.placeId, name: item.name),
            priority: item.priority,
            stayMin: item.stayMin,
          ),
      ];
      start.value = Place(
        placeId: itinerary.start.placeId ?? '',
        name: itinerary.start.name,
        location: itinerary.start.location,
      );
      date.value = DateTime.parse(itinerary.date);
      departAt.value = TimeOfDay.fromDateTime(
        itinerary.start.departAt.toLocal(),
      );
      final (h, m) = Format.parseHhmm(itinerary.end.arriveBy);
      endBy.value = TimeOfDay(hour: h, minute: m);
      return null;
    }, [existing?.value]);

    void addPlace(Place place) {
      if (entries.value.length >= ApiConstraints.placesMaxCount) {
        showMessageSnackBar(context, AppStrings.planTooMany);
        return;
      }
      if (entries.value.any((e) => e.place.placeId == place.placeId)) return;
      entries.value = [...entries.value, PlanEntry(place: place)];
      input.clear();
      interpreted.value = const [];
    }

    void updateEntry(int index, PlanEntry entry) {
      entries.value = [...entries.value]..[index] = entry;
    }

    void removeEntry(int index) {
      entries.value = [...entries.value]..removeAt(index);
    }

    // 自由文（「海が見えるカフェ」など）を Gemini で施設候補にする
    Future<void> interpret() async {
      final text = input.text.trim();
      if (text.isEmpty) return;
      interpreting.value = true;
      try {
        interpreted.value = await api.interpret(text);
      } catch (e) {
        if (context.mounted) showErrorSnackBar(context, e);
      } finally {
        interpreting.value = false;
      }
    }

    Future<void> pickStart() async {
      final place = await PlaceSearchSheet.show(
        context,
        title: AppStrings.planStartSearchTitle,
        hint: AppStrings.planAddHint,
      );
      if (place != null) {
        start.value = place;
        startPicked.value = true;
      }
    }

    Future<void> pickDepart() async {
      if (!_isEdit) {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date.value,
          firstDate: DateUtils.dateOnly(now),
          lastDate: now.add(_datePickerRange),
        );
        if (picked == null || !context.mounted) return;
        date.value = picked;
      }
      final time = await showTimePicker(
        context: context,
        initialTime: departAt.value,
      );
      if (time != null) departAt.value = time;
    }

    Future<void> pickEndBy() async {
      final time = await showTimePicker(
        context: context,
        initialTime: endBy.value,
      );
      if (time != null) endBy.value = time;
    }

    Future<void> submit() async {
      final startPlace = start.value;
      if (startPlace == null) {
        showMessageSnackBar(context, AppStrings.planNeedStart);
        return;
      }
      submitting.value = true;
      try {
        final places = entries.value.map((e) => e.toInput()).toList();
        final endByText = Format.hhmm(endBy.value.hour, endBy.value.minute);
        final departText = Format.hhmm(
          departAt.value.hour,
          departAt.value.minute,
        );
        final current = existing?.value;
        final Itinerary itinerary;
        if (_isEdit && current != null) {
          itinerary = await ref
              .read(itineraryProvider(itineraryId!).notifier)
              .updatePlaces(
                UpdatePlacesRequest(
                  start: startPicked.value
                      ? StartInput(
                          placeId: startPlace.placeId,
                          departAt: departText,
                        )
                      : StartInput.fromEndpoint(
                          current.start,
                          departAt: departText,
                        ),
                  end: EndInput.fromEndpoint(current.end, arriveBy: endByText),
                  places: places,
                ),
              );
        } else {
          itinerary = await api.createItinerary(
            CreateItineraryRequest(
              title: '${startPlace.name}${AppStrings.planDefaultTitleSuffix}',
              date: Format.isoDate(date.value),
              start: StartInput(
                placeId: startPlace.placeId,
                departAt: departText,
              ),
              // 終わる場所を選ぶ画面ができるまでは、出発地に戻る旅程にする
              end: EndInput(placeId: startPlace.placeId, arriveBy: endByText),
              places: places,
            ),
          );
          ref.invalidate(myItinerariesProvider);
        }
        if (context.mounted) context.go(Routes.today(itinerary.id));
      } on ApiException catch (e) {
        if (!context.mounted) return;
        showErrorSnackBar(
          context,
          e,
          fallback: switch (e.code) {
            ApiErrorCode.mustItemsInfeasible => AppStrings.planMustInfeasible,
            ApiErrorCode.endInfeasible => AppStrings.planEndInfeasible,
            ApiErrorCode.itineraryLimit => AppStrings.planItineraryLimit,
            _ => null,
          },
        );
      } finally {
        submitting.value = false;
      }
    }

    final canSubmit =
        entries.value.length >= ApiConstraints.placesMinCount &&
        !submitting.value;
    final departLabel = [
      if (!_isEdit) '${date.value.month}/${date.value.day}',
      Format.hhmm(departAt.value.hour, departAt.value.minute),
      start.value?.name ?? AppStrings.planStartUnset,
    ].join(' ');

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.screenPadding,
                tokens.space28,
                tokens.screenPadding,
                tokens.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: tokens.space4,
                children: [
                  Text(
                    AppStrings.planTitle,
                    style: context.texts.headlineSmall,
                  ),
                  Text(
                    AppStrings.planSubtitle,
                    style: context.texts.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
              child: _AddPlaceField(
                controller: input,
                loading: interpreting.value,
                onSubmit: interpret,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  tokens.screenPadding,
                  tokens.space8,
                  tokens.screenPadding,
                  tokens.space8,
                ),
                children: [
                  PlaceCandidateList(
                    candidates: autocomplete,
                    onPick: addPlace,
                  ),
                  if (interpreted.value.isNotEmpty)
                    _InterpretedList(
                      candidates: interpreted.value,
                      onPick: addPlace,
                    ),
                  if (entries.value.isEmpty && query.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: tokens.space24),
                      child: Text(
                        AppStrings.planEmpty,
                        textAlign: TextAlign.center,
                        style: context.texts.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  for (final (i, entry) in entries.value.indexed)
                    Padding(
                      padding: EdgeInsets.only(bottom: tokens.space10),
                      child: _PlanEntryCard(
                        entry: entry,
                        onChanged: (e) => updateEntry(i, e),
                        onRemove: () => removeEntry(i),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.screenPadding,
                tokens.space14,
                tokens.screenPadding,
                0,
              ),
              child: Row(
                spacing: tokens.space8,
                children: [
                  Expanded(
                    child: SummaryTile(
                      label: AppStrings.planStart,
                      value: departLabel,
                      onTap: () async {
                        if (!_isEdit) await pickStart();
                        if (context.mounted) await pickDepart();
                      },
                    ),
                  ),
                  Expanded(
                    child: SummaryTile(
                      label: AppStrings.planEndBy,
                      value: Format.hhmm(endBy.value.hour, endBy.value.minute),
                      onTap: pickEndBy,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.screenPadding,
                tokens.space14,
                tokens.screenPadding,
                tokens.space24,
              ),
              child: PrimaryButton(
                label: _isEdit ? AppStrings.planUpdate : AppStrings.planSubmit,
                loading: submitting.value,
                onPressed: canSubmit ? submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlaceField extends StatelessWidget {
  const _AddPlaceField({
    required this.controller,
    required this.loading,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.space4,
      children: [
        Text(
          AppStrings.planAddLabel,
          style: context.texts.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Row(
          spacing: tokens.space8,
          children: [
            Expanded(
              child: SizedBox(
                height: tokens.inputHeight,
                child: TextField(
                  controller: controller,
                  maxLength: ApiConstraints.interpretTextMaxLength,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSubmit(),
                  style: context.texts.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: AppStrings.planAddHint,
                    counterText: '',
                  ),
                ),
              ),
            ),
            SizedBox.square(
              dimension: tokens.inputHeight,
              child: IconButton.filled(
                tooltip: AppStrings.planAddButton,
                onPressed: loading ? null : onSubmit,
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMedium),
                  ),
                ),
                icon: loading
                    ? SizedBox.square(
                        dimension: tokens.iconSize,
                        child: const CircularProgressIndicator(),
                      )
                    : Icon(Icons.add, size: tokens.iconSize),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InterpretedList extends StatelessWidget {
  const _InterpretedList({required this.candidates, required this.onPick});

  final List<InterpretedCandidate> candidates;
  final ValueChanged<Place> onPick;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final muted = context.colors.onSurfaceVariant;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.planInterpretHeader,
            style: context.texts.labelLarge?.copyWith(color: muted),
          ),
          for (final c in candidates)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.auto_awesome_outlined, size: tokens.iconSize),
              title: Text(c.place.name, style: context.texts.bodyLarge),
              subtitle: Text(
                c.reason,
                style: context.texts.bodySmall?.copyWith(color: muted),
              ),
              trailing: Icon(Icons.add, size: tokens.iconSize),
              onTap: () => onPick(c.place),
            ),
        ],
      ),
    );
  }
}

class _PlanEntryCard extends StatelessWidget {
  const _PlanEntryCard({
    required this.entry,
    required this.onChanged,
    required this.onRemove,
  });

  final PlanEntry entry;
  final ValueChanged<PlanEntry> onChanged;
  final VoidCallback onRemove;

  Future<void> _pickStay(BuildContext context) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.planStayPickerTitle,
              style: context.texts.titleLarge,
            ),
            for (final minutes in _stayChoices)
              if (minutes >= ApiConstraints.stayMinMin &&
                  minutes <= ApiConstraints.stayMinMax)
                ListTile(
                  title: Text(
                    Format.duration(minutes),
                    style: context.texts.bodyLarge,
                  ),
                  trailing: minutes == entry.stayMin
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.of(context).pop(minutes),
                ),
          ],
        ),
      ),
    );
    if (picked != null) onChanged(entry.copyWith(stayMin: picked));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final muted = context.colors.onSurfaceVariant;
    return OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.space8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(entry.place.name, style: context.texts.titleLarge),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  foregroundColor: muted,
                ),
                onPressed: () => _pickStay(context),
                child: Text(
                  '${AppStrings.planStayPrefix}${Format.duration(entry.stayMin)}',
                ),
              ),
              IconButton(
                tooltip: AppStrings.planRemove,
                onPressed: onRemove,
                icon: Icon(
                  Icons.close,
                  size: tokens.smallIconSize,
                  color: muted,
                ),
              ),
            ],
          ),
          PrioritySegment(
            value: entry.priority,
            onChanged: (p) => onChanged(entry.copyWith(priority: p)),
          ),
        ],
      ),
    );
  }
}

/// 「必須／できれば／余裕があれば」の 3 段階ボタン
class PrioritySegment extends StatelessWidget {
  const PrioritySegment({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Priority value;
  final ValueChanged<Priority> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Semantics(
      label: AppStrings.planSubtitle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.tileBackground,
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.space4),
          child: Row(
            spacing: tokens.space4,
            children: [
              for (final p in Priority.values)
                Expanded(
                  child: _SegmentButton(
                    label: p.label,
                    selected: p == value,
                    onTap: () => onChanged(p),
                    selectedStyle: switch (p) {
                      Priority.must => (
                        background: colors.primary,
                        foreground: colors.onPrimary,
                        outline: null,
                      ),
                      Priority.want => (
                        background: colors.surface,
                        foreground: colors.onPrimaryContainer,
                        outline: tokens.selectedOutlineWant,
                      ),
                      Priority.optional => (
                        background: colors.surface,
                        foreground: colors.onSurface,
                        outline: colors.outline,
                      ),
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _SegmentStyle = ({Color background, Color foreground, Color? outline});

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedStyle,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final _SegmentStyle selectedStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = BorderRadius.circular(tokens.radiusSegment);
    final outline = selectedStyle.outline;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? selectedStyle.background : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: selected && outline != null
              ? BorderSide(color: outline, width: tokens.selectedBorderWidth)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: tokens.segmentHeight,
            child: Center(
              child: Text(
                label,
                style: context.texts.bodyMedium?.copyWith(
                  color: selected
                      ? selectedStyle.foreground
                      : context.colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
