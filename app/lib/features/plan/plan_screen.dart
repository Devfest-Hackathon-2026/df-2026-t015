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
const _japanUtcOffset = Duration(hours: 9);

/// 名前が空欄のとき、自動でつける名前に使う行き先の数
const _autoTitlePlaceCount = 2;

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

/// 出発地・終わる場所（API の Endpoint）。
///
/// 施設なら [placeId]、地図で施設ではない地点を選んだときは [location] と [name] で送る。
@immutable
class PlanEndpoint {
  const PlanEndpoint({required this.name, this.placeId, this.location});

  PlanEndpoint.fromPlace(Place place)
    : this(name: place.name, placeId: place.placeId, location: place.location);

  final String name;
  final String? placeId;
  final LatLng? location;

  StartInput toStart(String departAt) => placeId != null
      ? StartInput(placeId: placeId, departAt: departAt)
      : StartInput(location: location, name: name, departAt: departAt);

  EndInput toEnd(String arriveBy) => placeId != null
      ? EndInput(placeId: placeId, arriveBy: arriveBy)
      : EndInput(location: location, name: name, arriveBy: arriveBy);
}

/// 名前が空欄のとき、行き先からつける名前（例：朝市通り・海の美術館 ほか）
String autoTitle(List<PlanEntry> entries) {
  final names = entries.map((e) => e.place.name).toList();
  final head = names
      .take(_autoTitlePlaceCount)
      .join(AppStrings.planNamedSeparator);
  final title = names.length > _autoTitlePlaceCount
      ? '$head${AppStrings.planAutoTitleMoreSuffix}'
      : head;
  return title.length > ApiConstraints.titleMaxLength
      ? title.substring(0, ApiConstraints.titleMaxLength)
      : title;
}

/// 3.2 新しい旅程（出発・終わり・行き先と優先度）（F-01、F-02、F-09、F-10）
///
/// [itineraryId] があれば既存の旅程を編集して作り直す（PUT /itineraries/:id/places、
/// 名前が変わっていれば PATCH /itineraries/:id）。
class PlanScreen extends HookConsumerWidget {
  const PlanScreen({super.key, this.itineraryId});

  final String? itineraryId;

  bool get _isEdit => itineraryId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final api = ref.watch(itineraryApiProvider);

    final entries = useState<List<PlanEntry>>(const []);
    final start = useState<PlanEndpoint?>(null);
    // 終わる場所を選んでいなければ、出発地に戻る旅程にする
    final end = useState<PlanEndpoint?>(null);
    final date = useState(DateUtils.dateOnly(DateTime.now()));
    final departAt = useState(
      const TimeOfDay(hour: _defaultDepartHour, minute: 0),
    );
    final endBy = useState(const TimeOfDay(hour: _defaultEndByHour, minute: 0));
    final submitting = useState(false);
    final interpreting = useState(false);
    final interpreted = useState<List<InterpretedCandidate>>(const []);

    final titleInput = useTextEditingController();
    final input = useTextEditingController();
    final query = useValueListenable(input).text;
    final autocomplete = useAutocomplete(ref, query);

    // 編集のときは今の旅程で埋める
    final existing = _isEdit
        ? ref.watch(itineraryProvider(itineraryId!))
        : null;
    final current = existing?.value;
    final tripStarted =
        current?.items.any((item) => item.status != ItemStatus.upcoming) ??
        false;

    void restoreStart(ItineraryStart original) {
      start.value = PlanEndpoint(
        name: original.name,
        placeId: original.placeId,
        location: original.location,
      );
      final departure = original.departAt;
      // API の日時は UTC に変換されて届く。入力する時刻はサーバーと同じ日本時間。
      departAt.value = TimeOfDay.fromDateTime(
        departure.isUtc ? departure.add(_japanUtcOffset) : departure,
      );
    }

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
      titleInput.text = itinerary.title;
      restoreStart(itinerary.start);
      end.value = PlanEndpoint(
        name: itinerary.end.name,
        placeId: itinerary.end.placeId,
        location: itinerary.end.location,
      );
      date.value = DateTime.parse(itinerary.date);
      final (h, m) = Format.parseHhmm(itinerary.end.arriveBy);
      endBy.value = TimeOfDay(hour: h, minute: m);
      return null;
    }, [existing?.value]);
    final startLocked =
        tripStarted && Format.isoDate(date.value) == current?.date;

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

    // 地図から選ぶ画面（3.3）ができるまでは、施設名の検索で選ぶ
    Future<Place?> searchPlace(String title) => PlaceSearchSheet.show(
      context,
      title: title,
      hint: AppStrings.planSearchHint,
    );

    Future<void> pickStart() async {
      final place = await searchPlace(AppStrings.planStartSearchTitle);
      if (context.mounted && place != null) {
        start.value = PlanEndpoint.fromPlace(place);
      }
    }

    Future<void> pickEnd() async {
      final place = await searchPlace(AppStrings.planEndSearchTitle);
      if (context.mounted && place != null) {
        end.value = PlanEndpoint.fromPlace(place);
      }
    }

    Future<void> pickDestination() async {
      final place = await searchPlace(AppStrings.planPlaceSearchTitle);
      if (context.mounted && place != null) addPlace(place);
    }

    Future<void> pickDate() async {
      final today = DateUtils.dateOnly(DateTime.now());
      final picked = await showDatePicker(
        context: context,
        initialDate: date.value,
        // 編集のとき、過ぎた旅行日のままでも開けるようにする
        firstDate: date.value.isBefore(today) ? date.value : today,
        lastDate: today.add(_datePickerRange),
      );
      if (!context.mounted || picked == null) return;
      if (current != null &&
          tripStarted &&
          Format.isoDate(picked) == current.date) {
        restoreStart(current.start);
      }
      date.value = picked;
    }

    Future<void> pickDepart() async {
      final time = await showTimePicker(
        context: context,
        initialTime: departAt.value,
      );
      if (context.mounted && time != null) departAt.value = time;
    }

    Future<void> pickEndBy() async {
      final time = await showTimePicker(
        context: context,
        initialTime: endBy.value,
      );
      if (context.mounted && time != null) endBy.value = time;
    }

    void close() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(_isEdit ? Routes.today(itineraryId!) : Routes.itineraries);
      }
    }

    Future<void> submit() async {
      if (submitting.value) return;
      final startPoint = start.value;
      if (startPoint == null) {
        showMessageSnackBar(context, AppStrings.planNeedStart);
        return;
      }
      if (endBy.value.compareTo(departAt.value) <= 0) {
        showMessageSnackBar(context, AppStrings.planInvalidTimeRange);
        return;
      }
      final endPoint = end.value ?? startPoint;
      submitting.value = true;
      try {
        final places = entries.value.map((e) => e.toInput()).toList();
        final departText = Format.hhmm(
          departAt.value.hour,
          departAt.value.minute,
        );
        final endByText = Format.hhmm(endBy.value.hour, endBy.value.minute);
        final dateText = Format.isoDate(date.value);
        final title = titleInput.text.trim();
        final Itinerary itinerary;
        if (_isEdit) {
          if (current == null) return;
          final notifier = ref.read(itineraryProvider(itineraryId!).notifier);
          var updated = await notifier.updatePlaces(
            UpdatePlacesRequest(
              // 旅行日を変えると時刻表が変わるので、変えたときだけ送る
              date: dateText == current.date ? null : dateText,
              start: startLocked ? null : startPoint.toStart(departText),
              end: endPoint.toEnd(endByText),
              places: places,
            ),
          );
          if (!context.mounted) return;
          // 名前を空欄にしたときは今の名前のままにする
          if (title.isNotEmpty && title != updated.title) {
            updated = await notifier.rename(title);
          }
          itinerary = updated;
        } else {
          itinerary = await api.createItinerary(
            CreateItineraryRequest(
              title: title.isEmpty ? autoTitle(entries.value) : title,
              date: dateText,
              start: startPoint.toStart(departText),
              end: endPoint.toEnd(endByText),
              places: places,
            ),
          );
        }
        // 旅程の画面が、旅行日の前（3.5）か当日（3.4）かを出し分ける
        if (context.mounted) {
          ref.invalidate(myItinerariesProvider);
          context.go(Routes.today(itinerary.id));
        }
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
      } catch (error) {
        if (context.mounted) showErrorSnackBar(context, error);
      } finally {
        if (context.mounted) submitting.value = false;
      }
    }

    final canSubmit =
        entries.value.length >= ApiConstraints.placesMinCount &&
        !submitting.value;
    final endName = (end.value ?? start.value)?.name;
    final loadState = switch (existing) {
      null || AsyncValue(hasValue: true) => null,
      AsyncError(:final error, isLoading: false) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(itineraryProvider(itineraryId!)),
      ),
      _ => const LoadingView(),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackTopBar(
              title: _isEdit
                  ? AppStrings.planTopBarEdit
                  : AppStrings.planTopBarNew,
              backLabel: _isEdit
                  ? AppStrings.planCloseEdit
                  : AppStrings.planCloseNew,
              icon: Icons.close,
              onBack: close,
            ),
            Expanded(
              child:
                  loadState ??
                  ListView(
                    padding: EdgeInsets.fromLTRB(
                      tokens.screenPadding,
                      tokens.space8,
                      tokens.screenPadding,
                      tokens.space8,
                    ),
                    children: [
                      _DateAndTitle(
                        date: date.value,
                        onPickDate: pickDate,
                        titleController: titleInput,
                      ),
                      SizedBox(height: tokens.space14),
                      _EndpointsCard(
                        departAt: Format.hhmm(
                          departAt.value.hour,
                          departAt.value.minute,
                        ),
                        startName: start.value?.name,
                        endBy: Format.hhmm(
                          endBy.value.hour,
                          endBy.value.minute,
                        ),
                        endName: endName,
                        onPickDepart: startLocked ? null : pickDepart,
                        onPickStart: startLocked ? null : pickStart,
                        onPickEndBy: pickEndBy,
                        onPickEnd: pickEnd,
                      ),
                      if (startLocked)
                        Padding(
                          padding: EdgeInsets.only(top: tokens.space8),
                          child: const Text(AppStrings.planStartLocked),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: tokens.space16,
                          bottom: tokens.space8,
                        ),
                        child: Text(
                          AppStrings.planPlacesHeader,
                          style: context.texts.titleSmall,
                        ),
                      ),
                      _AddPlaceField(
                        controller: input,
                        loading: interpreting.value,
                        onSubmit: interpret,
                        onSearch: pickDestination,
                      ),
                      SizedBox(height: tokens.space14),
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
                          padding: EdgeInsets.symmetric(
                            vertical: tokens.space24,
                          ),
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
            if (loadState == null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.screenPadding,
                  tokens.space14,
                  tokens.screenPadding,
                  tokens.space24,
                ),
                child: PrimaryButton(
                  label: _isEdit
                      ? AppStrings.planUpdate
                      : AppStrings.planSubmit,
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

/// 枠線付きのボタン（旅行日・時刻・場所）
class _OutlinedField extends StatelessWidget {
  const _OutlinedField({
    required this.height,
    required this.radius,
    required this.onTap,
    required this.semanticLabel,
    required this.child,
    this.width,
    this.padding,
  });

  final double height;
  final double? width;
  final double radius;
  final VoidCallback? onTap;
  final String semanticLabel;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: context.colors.outline,
        width: tokens.borderWidth,
      ),
    );
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: width,
        child: Material(
          color: context.colors.surface,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ),
      ),
    );
  }
}

/// 旅行日と旅程の名前
class _DateAndTitle extends StatelessWidget {
  const _DateAndTitle({
    required this.date,
    required this.onPickDate,
    required this.titleController,
  });

  final DateTime date;
  final VoidCallback onPickDate;
  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final muted = context.colors.onSurfaceVariant;
    final labelStyle = context.texts.labelMedium?.copyWith(color: muted);
    final dateText = Format.monthDayWeekday(date);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: tokens.space8,
      children: [
        SizedBox(
          width: tokens.planDateFieldWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.space4,
            children: [
              Text(AppStrings.planDateLabel, style: labelStyle),
              _OutlinedField(
                height: tokens.inputHeight,
                radius: tokens.radiusMedium,
                onTap: onPickDate,
                semanticLabel:
                    '${AppStrings.planDateLabel} $dateText${AppStrings.planChangeSuffix}',
                padding: EdgeInsets.symmetric(horizontal: tokens.space10),
                child: Row(
                  spacing: tokens.space6,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: tokens.smallIconSize,
                      color: muted,
                    ),
                    Expanded(
                      child: Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: tokens.space4,
            children: [
              Text(AppStrings.planTitleLabel, style: labelStyle),
              SizedBox(
                height: tokens.inputHeight,
                child: TextField(
                  controller: titleController,
                  maxLength: ApiConstraints.titleMaxLength,
                  textInputAction: TextInputAction.done,
                  style: context.texts.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: AppStrings.planTitleHint,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 出発と終わり（時刻と場所）
class _EndpointsCard extends StatelessWidget {
  const _EndpointsCard({
    required this.departAt,
    required this.startName,
    required this.endBy,
    required this.endName,
    required this.onPickDepart,
    required this.onPickStart,
    required this.onPickEndBy,
    required this.onPickEnd,
  });

  final String departAt;
  final String? startName;
  final String endBy;
  final String? endName;
  final VoidCallback? onPickDepart;
  final VoidCallback? onPickStart;
  final VoidCallback onPickEndBy;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      label: AppStrings.planEndpoints,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: tokens.cardBorder,
            width: tokens.borderWidth,
          ),
          borderRadius: BorderRadius.circular(tokens.radiusLarge),
        ),
        child: Column(
          children: [
            _EndpointRow(
              label: AppStrings.planStart,
              time: departAt,
              timeLabel: AppStrings.planStartTimeLabel,
              onPickTime: onPickDepart,
              placeIcon: Icons.place_outlined,
              placeName: startName,
              placeLabel: AppStrings.planStartPlaceLabel,
              placeUnset: AppStrings.planStartUnset,
              onPickPlace: onPickStart,
            ),
            Divider(indent: tokens.space12, endIndent: tokens.space12),
            _EndpointRow(
              label: AppStrings.planEnd,
              time: endBy,
              timeSuffix: AppStrings.planEndBySuffix,
              timeLabel: AppStrings.planEndTimeLabel,
              onPickTime: onPickEndBy,
              placeIcon: Icons.flag_outlined,
              placeName: endName,
              placeLabel: AppStrings.planEndPlaceLabel,
              placeUnset: AppStrings.planEndUnset,
              onPickPlace: onPickEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _EndpointRow extends StatelessWidget {
  const _EndpointRow({
    required this.label,
    required this.time,
    required this.timeLabel,
    required this.onPickTime,
    required this.placeIcon,
    required this.placeName,
    required this.placeLabel,
    required this.placeUnset,
    required this.onPickPlace,
    this.timeSuffix,
  });

  final String label;
  final String time;
  final String? timeSuffix;
  final String timeLabel;
  final VoidCallback? onPickTime;
  final IconData placeIcon;
  final String? placeName;
  final String placeLabel;
  final String placeUnset;
  final VoidCallback? onPickPlace;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final texts = context.texts;
    final muted = context.colors.onSurfaceVariant;
    final name = placeName;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space12,
        tokens.space6,
        tokens.space8,
        tokens.space6,
      ),
      child: Row(
        spacing: tokens.space8,
        children: [
          SizedBox(
            width: tokens.endpointLabelWidth,
            child: Text(
              label,
              style: texts.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _OutlinedField(
            width: tokens.endpointTimeWidth,
            height: tokens.endpointFieldHeight,
            radius: tokens.radiusSmall,
            onTap: onPickTime,
            semanticLabel:
                '$timeLabel $time${timeSuffix ?? ''}'
                '${onPickTime == null ? '' : AppStrings.planChangeSuffix}',
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: time,
                  children: [
                    if (timeSuffix != null)
                      TextSpan(
                        text: timeSuffix,
                        style: texts.labelMedium?.copyWith(color: muted),
                      ),
                  ],
                ),
                style: texts.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: _OutlinedField(
              height: tokens.endpointFieldHeight,
              radius: tokens.radiusSmall,
              onTap: onPickPlace,
              semanticLabel:
                  '$placeLabel ${name ?? ''}'
                  '${onPickPlace == null ? '' : AppStrings.planSearchSuffix}',
              padding: EdgeInsets.symmetric(horizontal: tokens.space10),
              child: Row(
                spacing: tokens.space6,
                children: [
                  Icon(placeIcon, size: tokens.smallIconSize, color: muted),
                  Expanded(
                    child: Text(
                      name ?? placeUnset,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: name == null
                          ? texts.labelLarge?.copyWith(color: muted)
                          : texts.titleSmall,
                    ),
                  ),
                  if (onPickPlace != null)
                    Icon(
                      Icons.search,
                      size: tokens.smallIconSize,
                      color: muted,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 行き先の入力欄と、地図から選ぶボタン・追加ボタン
class _AddPlaceField extends StatelessWidget {
  const _AddPlaceField({
    required this.controller,
    required this.loading,
    required this.onSubmit,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
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
        _OutlinedField(
          width: tokens.inputHeight,
          height: tokens.inputHeight,
          radius: tokens.radiusMedium,
          onTap: onSearch,
          semanticLabel: AppStrings.planSearchPlaceButton,
          child: Center(child: Icon(Icons.search, size: tokens.iconSize)),
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
      label: AppStrings.planPriorityLabel,
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
