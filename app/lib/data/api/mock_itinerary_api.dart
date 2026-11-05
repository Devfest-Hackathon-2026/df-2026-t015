import '../../constants/api_constraints.dart';
import '../models/models.dart';
import 'api_exception.dart';
import 'itinerary_api.dart';

/// サーバーなしで画面を作り込むための [ItineraryApi]。
///
/// デザイン（docs/iterinerary_ui.html）の「みなと町 日帰り旅」を今日の日付で用意する。
/// 計算はごく簡易で、本番のロジックとは一致しない。
class MockItineraryApi implements ItineraryApi {
  MockItineraryApi({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _seed();
  }

  // ---- モックの振る舞いを決める値 ----
  static const _latency = Duration(milliseconds: 300);
  static const _legMinutes = 15;
  static const _legMode = TransitMode.bus;
  static const _lineName = '12系統';
  static const _replanNeededFromMin = 20;
  static const _explanationPendingPolls = 2;
  static const _seedId = 'itn_mock';
  static const _seedDepartHour = 9;
  static const _seedEndBy = '17:00';
  static const _defaultStayMin = 60;
  static const _shortStayMin = 30;
  static const _replacementPrice = Price(amount: 500, kind: PriceKind.fixed);

  static const _catalog = <_MockPlace>[
    _MockPlace('p_station', 'みなと町駅', 'みなと町1-1', null),
    _MockPlace('p_asaichi', '朝市通り', 'みなと町1-2-3', 1500),
    _MockPlace('p_soko', '運河の倉庫街', 'みなと町2-4', 1200),
    _MockPlace('p_bijutsu', '海の美術館', 'みなと町3-1', 800),
    _MockPlace('p_toudai', '灯台の丘', 'みさき町5', 300),
    _MockPlace('p_shiryo', '港の資料館', 'みなと町3-8', 500),
    _MockPlace('p_tenbou', '夕日の展望台', 'みさき町6', 0),
    _MockPlace('p_cafe', '灯台の丘カフェ', 'みさき町5-2', 900),
  ];

  final DateTime Function() _clock;
  final _itineraries = <String, Itinerary>{};
  final _replans = <String, ReplanResult>{};
  final _explanationPolls = <String, int>{};
  var _seq = 0;

  String _nextId(String prefix) => '${prefix}_${++_seq}';

  Future<void> _wait() => Future<void>.delayed(_latency);

  _MockPlace _place(String placeId) => _catalog.firstWhere(
    (p) => p.id == placeId,
    orElse: () => _MockPlace(placeId, placeId, '', null),
  );

  String _today() {
    final now = _clock();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}';
  }

  DateTime _at(String date, String hhmm) => DateTime.parse('${date}T$hhmm:00');

  void _seed() {
    final date = _today();
    final departAt = DateTime.parse(date)
        .add(const Duration(hours: _seedDepartHour));
    final itinerary = _build(
      id: _seedId,
      version: 1,
      title: 'みなと町 日帰り旅',
      date: date,
      startPlaceId: 'p_station',
      departAt: departAt,
      endBy: _seedEndBy,
      places: const [
        PlaceInput(
          placeId: 'p_asaichi',
          priority: Priority.must,
          stayMin: _defaultStayMin,
        ),
        PlaceInput(
          placeId: 'p_soko',
          priority: Priority.want,
          stayMin: _defaultStayMin * 2,
        ),
        PlaceInput(
          placeId: 'p_bijutsu',
          priority: Priority.want,
          stayMin: _defaultStayMin,
        ),
        PlaceInput(
          placeId: 'p_toudai',
          priority: Priority.must,
          stayMin: _defaultStayMin,
        ),
      ],
    );
    _itineraries[itinerary.id] = itinerary;
  }

  /// 行き先を順番に並べ、間に一定時間の移動を挟むだけの簡易スケジューラ。
  Itinerary _build({
    required String id,
    required int version,
    required String title,
    required String date,
    required String startPlaceId,
    required DateTime departAt,
    required String endBy,
    required List<PlaceInput> places,
  }) {
    final now = _clock();
    final items = <Item>[];
    final legs = <Leg>[];
    var cursor = departAt;
    var prevId = Leg.startItemId;
    for (final p in places) {
      final arrive = cursor.add(const Duration(minutes: _legMinutes));
      final itemId = 'it_${items.length + 1}';
      legs.add(
        Leg(
          fromItemId: prevId,
          toItemId: itemId,
          mode: _legMode,
          durationMin: _legMinutes,
          departAt: cursor,
          arriveAt: arrive,
          lineName: _lineName,
        ),
      );
      final end = arrive.add(Duration(minutes: p.stayMin));
      final catalog = _place(p.placeId);
      items.add(
        Item(
          itemId: itemId,
          placeId: p.placeId,
          name: catalog.name,
          priority: p.priority,
          stayMin: p.stayMin,
          startAt: arrive,
          endAt: end,
          price: Price(
            amount: catalog.price,
            kind: catalog.price == null
                ? PriceKind.unknown
                : PriceKind.estimate,
          ),
          status: now.isAfter(end)
              ? ItemStatus.done
              : (now.isAfter(arrive)
                    ? ItemStatus.current
                    : ItemStatus.upcoming),
        ),
      );
      cursor = end;
      prevId = itemId;
    }
    final start = _place(startPlaceId);
    return Itinerary(
      id: id,
      version: version,
      title: title,
      date: date,
      start: ItineraryStart(
        placeId: start.id,
        name: start.name,
        departAt: departAt,
      ),
      endBy: endBy,
      items: items,
      legs: legs,
      summary: _summarize(items, legs, departAt),
      expiresAt: DateTime.parse(date).add(ApiConstraints.itineraryTtl),
    );
  }

  Summary _summarize(List<Item> items, List<Leg> legs, DateTime fallbackEnd) {
    final known = items.where((i) => i.price.amount != null);
    return Summary(
      moveMin: legs.fold(0, (sum, l) => sum + l.durationMin),
      priceTotal: PriceTotal(
        amount: known.fold(0, (sum, i) => sum + i.price.amount!),
        hasEstimate: items.any((i) => i.price.kind != PriceKind.fixed),
      ),
      endAt: items.isEmpty ? fallbackEnd : items.last.endAt,
    );
  }

  Itinerary _require(String id) =>
      _itineraries[id] ??
      (throw const ApiException(
        statusCode: 404,
        code: ApiErrorCode.notFound,
        message: '旅程が見つかりません',
      ));

  void _checkVersion(Itinerary itinerary, int version) {
    if (itinerary.version != version) {
      throw const ApiException(
        statusCode: 409,
        code: ApiErrorCode.versionConflict,
        message: '旅程がほかの操作で更新されています',
      );
    }
  }

  // ---------------------------------------------------------------------------

  @override
  Future<List<Place>> autocomplete(String query, {LatLng? near}) async {
    await _wait();
    return _catalog
        .where((p) => p.name.contains(query))
        .map((p) => Place(placeId: p.id, name: p.name, address: p.address))
        .toList();
  }

  @override
  Future<List<InterpretedCandidate>> interpret(
    String text, {
    LatLng? near,
  }) async {
    await _wait();
    final cafe = _place('p_cafe');
    final tenbou = _place('p_tenbou');
    return [
      InterpretedCandidate(
        place: Place(placeId: cafe.id, name: cafe.name, address: cafe.address),
        reason: '海に面したテラス席がある',
      ),
      InterpretedCandidate(
        place: Place(
          placeId: tenbou.id,
          name: tenbou.name,
          address: tenbou.address,
        ),
        reason: '夕方の海の景色が見られる',
      ),
    ];
  }

  @override
  Future<Itinerary> createItinerary(CreateItineraryRequest request) async {
    await _wait();
    final itinerary = _build(
      id: _nextId('itn'),
      version: 1,
      title: request.title,
      date: request.date,
      startPlaceId: request.start.placeId,
      departAt: _at(request.date, request.start.departAt),
      endBy: request.endBy,
      places: request.places,
    );
    _itineraries[itinerary.id] = itinerary;
    return itinerary;
  }

  @override
  Future<List<ItineraryListEntry>> myItineraries() async {
    await _wait();
    final list = _itineraries.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list
        .map(
          (i) => ItineraryListEntry(
            id: i.id,
            title: i.title,
            date: i.date,
            updatedAt: _clock(),
          ),
        )
        .toList();
  }

  @override
  Future<Itinerary> getItinerary(String id) async {
    await _wait();
    return _require(id);
  }

  @override
  Future<Itinerary> updatePlaces(
    String id,
    UpdatePlacesRequest request, {
    required int version,
  }) async {
    await _wait();
    final current = _require(id);
    _checkVersion(current, version);
    final updated = _build(
      id: id,
      version: current.version + 1,
      title: current.title,
      date: current.date,
      startPlaceId: current.start.placeId,
      departAt: current.start.departAt,
      endBy: request.endBy ?? current.endBy,
      places: request.places,
    );
    _itineraries[id] = updated;
    return updated;
  }

  @override
  Future<ReplanResult> createReplan(String id, ReplanRequest request) async {
    await _wait();
    final itinerary = _require(id);
    final delayMin = request.delayMin ?? _delayFromNow(itinerary, request);
    if (delayMin < _replanNeededFromMin) {
      return const ReplanResult(needsChange: false);
    }
    final current = itinerary.items.firstWhere(
      (i) => i.itemId == request.currentItemId,
      orElse: () => itinerary.items.first,
    );
    final index = itinerary.items.indexOf(current);
    final next = index + 1 < itinerary.items.length
        ? itinerary.items[index + 1]
        : null;
    final delay = Duration(minutes: delayMin);

    final changes = <ReplanChange>[
      ReplanChange(
        type: ChangeType.retime,
        itemId: current.itemId,
        before: ChangeSnapshot(endAt: current.endAt),
        after: ChangeSnapshot(endAt: current.endAt.add(delay)),
      ),
      if (next != null)
        ReplanChange(
          type: ChangeType.replace,
          itemId: next.itemId,
          before: ChangeSnapshot(
            name: next.name,
            startAt: next.startAt,
            endAt: next.endAt,
          ),
          after: ChangeSnapshot(
            placeId: 'p_shiryo',
            name: _place('p_shiryo').name,
            startAt: next.startAt.add(delay),
            endAt: next.startAt
                .add(delay)
                .add(const Duration(minutes: _shortStayMin)),
            price: _replacementPrice,
          ),
          note: '徒歩5分・港の歴史の展示',
        ),
      for (final keep in itinerary.items.skip(index + 2))
        ReplanChange(
          type: ChangeType.keep,
          itemId: keep.itemId,
          before: ChangeSnapshot(name: keep.name, startAt: keep.startAt),
          note: keep.priority == Priority.must ? '必須のため残す' : null,
        ),
    ];

    final previewItems = [
      for (final item in itinerary.items)
        if (item.itemId == current.itemId)
          item.copyWith(endAt: item.endAt.add(delay))
        else if (item.itemId == next?.itemId)
          item.copyWith(
            placeId: 'p_shiryo',
            name: _place('p_shiryo').name,
            stayMin: _shortStayMin,
            startAt: item.startAt.add(delay),
            endAt: item.startAt
                .add(delay)
                .add(const Duration(minutes: _shortStayMin)),
            price: _replacementPrice,
          )
        else
          item,
    ];

    final replanId = _nextId('rp');
    final option = ReplanOption(
      optionId: 'op_1',
      changes: changes,
      summaryBefore: itinerary.summary,
      summaryAfter: _summarize(
        previewItems,
        itinerary.legs,
        itinerary.summary.endAt,
      ),
      preview: ReplanPreview(items: previewItems, legs: itinerary.legs),
    );
    final result = ReplanResult(
      replanId: replanId,
      basedOnVersion: itinerary.version,
      needsChange: true,
      expiresAt: _clock().add(ApiConstraints.replanTtl),
      warnings: [
        ReplanWarning(
          type: ReplanWarningType.missTransit,
          itemId: next?.itemId,
          message: '$delayMin分の遅れで、次のバスに乗れません。',
        ),
      ],
      options: [option],
      explanation: const Explanation(status: ExplanationStatus.pending),
    );
    _replans[replanId] = result;
    return result;
  }

  int _delayFromNow(Itinerary itinerary, ReplanRequest request) {
    final current = itinerary.items.firstWhere(
      (i) => i.itemId == request.currentItemId,
      orElse: () => itinerary.items.first,
    );
    return request.now!.difference(current.endAt).inMinutes;
  }

  @override
  Future<Explanation> getExplanation(
    String id,
    String replanId, {
    required String optionId,
  }) async {
    await _wait();
    final key = '$replanId/$optionId';
    final polls = (_explanationPolls[key] ?? 0) + 1;
    _explanationPolls[key] = polls;
    if (polls <= _explanationPendingPolls) {
      return const Explanation(status: ExplanationStatus.pending);
    }
    return const Explanation(
      status: ExplanationStatus.ready,
      text: '遅れで次のバスに乗れなくなるため、必須の灯台の丘に間に合うよう、海の美術館を近くの港の資料館に変えました。',
    );
  }

  @override
  Future<Itinerary> acceptReplan(
    String id,
    String replanId, {
    required String optionId,
    required int version,
  }) async {
    await _wait();
    final itinerary = _require(id);
    _checkVersion(itinerary, version);
    final replan = _replans[replanId];
    if (replan == null) {
      throw const ApiException(
        statusCode: 404,
        code: ApiErrorCode.notFound,
        message: '組み直し案がありません',
      );
    }
    if (replan.expiresAt != null && _clock().isAfter(replan.expiresAt!)) {
      throw const ApiException(
        statusCode: 410,
        code: ApiErrorCode.replanExpired,
        message: '組み直し案の期限が切れました',
      );
    }
    final option = replan.options.firstWhere((o) => o.optionId == optionId);
    final updated = itinerary.copyWith(
      version: itinerary.version + 1,
      items: option.preview.items,
      legs: option.preview.legs,
      summary: option.summaryAfter,
    );
    _itineraries[id] = updated;
    return updated;
  }

  @override
  Future<List<Suggestion>> suggestions(
    String id, {
    required DateTime from,
    required DateTime to,
    String? afterItemId,
  }) async {
    await _wait();
    final tenbou = _place('p_tenbou');
    return [
      Suggestion(
        place: Place(
          placeId: tenbou.id,
          name: tenbou.name,
          address: tenbou.address,
        ),
        reason: '灯台の丘から徒歩10分で、夕方の景色が見られる',
        stayMin: _shortStayMin,
        price: const Price(amount: 0, kind: PriceKind.estimate),
        insertAfterItemId: afterItemId,
        legFromPrev: const LegFromPrev(mode: TransitMode.walk, durationMin: 10),
      ),
    ];
  }

  @override
  Future<Itinerary> addItem(
    String id,
    AddItemRequest request, {
    required int version,
  }) async {
    final itinerary = _require(id);
    final places = [
      for (final item in itinerary.items) ...[
        PlaceInput(
          placeId: item.placeId,
          priority: item.priority,
          stayMin: item.stayMin,
        ),
        if (item.itemId == request.insertAfterItemId)
          PlaceInput(
            placeId: request.placeId,
            priority: request.priority,
            stayMin: request.stayMin,
          ),
      ],
      if (request.insertAfterItemId == null)
        PlaceInput(
          placeId: request.placeId,
          priority: request.priority,
          stayMin: request.stayMin,
        ),
    ];
    return updatePlaces(
      id,
      UpdatePlacesRequest(places: places),
      version: version,
    );
  }
}

class _MockPlace {
  const _MockPlace(this.id, this.name, this.address, this.price);

  final String id;
  final String name;
  final String address;
  final int? price;
}
