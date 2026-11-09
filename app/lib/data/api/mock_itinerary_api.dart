import '../../constants/api_constraints.dart';
import '../models/models.dart';
import 'api_exception.dart';
import 'itinerary_api.dart';

/// サーバーなしで画面を作り込むための [ItineraryApi]。
///
/// デザイン（docs/iterinerary_ui.html）に合わせて、今日の「みなと町 日帰り旅」と、
/// 旅程一覧に出す「これから」「終わった旅」の旅程を、端末の日付を基準に用意する。
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
  static const _seedDepartAt = '09:00';
  static const _seedLateDepartAt = '10:00';
  static const _seedArriveBy = '17:00';

  /// 旅程一覧用の旅程の旅行日（今日からの日数。負なら過去）
  static const _onsenDaysFromToday = 9;
  static const _jokaDaysFromToday = 21;
  static const _shimaDaysFromToday = -11;
  static const _defaultStayMin = 60;
  static const _shortStayMin = 30;
  static const _replacementPrice = Price(amount: 500, kind: PriceKind.fixed);
  static const _openingHours = OpeningHours(
    opensAt: '09:00',
    closesAt: '18:00',
  );

  /// 1 度の近さを m にしたおおよその値（近くの施設の絞り込み用）
  static const _metersPerDegree = 111000;

  static const _catalog = <_MockPlace>[
    _MockPlace('p_station', 'みなと町駅', 'みなと町1-1', null, '駅', 34.570, 135.480),
    _MockPlace('p_asaichi', '朝市通り', 'みなと町1-2-3', 1500, '市場', 34.572, 135.482),
    _MockPlace('p_soko', '運河の倉庫街', 'みなと町2-4', 1200, '街並み', 34.566, 135.478),
    _MockPlace('p_bijutsu', '海の美術館', 'みなと町3-1', 800, '美術館', 34.563, 135.476),
    _MockPlace('p_toudai', '灯台の丘', 'みさき町5', 300, '名所', 34.558, 135.470),
    _MockPlace('p_shiryo', '港の資料館', 'みなと町3-8', 500, '資料館', 34.564, 135.479),
    _MockPlace('p_tenbou', '夕日の展望台', 'みさき町6', 0, '展望台', 34.556, 135.468),
    _MockPlace('p_cafe', '灯台の丘カフェ', 'みさき町5-2', 900, 'カフェ', 34.559, 135.471),
    // 山あいの温泉町（旅程一覧の「これから」）
    _MockPlace('p_yama_station', '山あいの駅', '湯の里町1', null, '駅', 35.210, 136.020),
    _MockPlace('p_onsen', '湯けむり通りの共同浴場', '湯の里町2-5', 600, '温泉', 35.212, 136.024),
    _MockPlace('p_tsuribashi', '渓谷の吊り橋', '湯の里町奥谷', 0, '名所', 35.218, 136.030),
    _MockPlace('p_yama_tera', '山寺の展望台', '湯の里町山上', 300, '寺', 35.215, 136.016),
    // 城下町（旅程一覧の「これから」）
    _MockPlace('p_joka_station', '城下町駅', '城下町本町1', null, '駅', 35.480, 136.760),
    _MockPlace('p_shiro', 'お城の天守', '城下町城山1', 500, '城', 35.484, 136.764),
    _MockPlace('p_bukeyashiki', '武家屋敷通り', '城下町西町', 0, '街並み', 35.482, 136.756),
    _MockPlace('p_wagashi', '老舗の和菓子店', '城下町本町3-2', 700, '和菓子', 35.479, 136.762),
    _MockPlace('p_teien', '堀端の庭園', '城下町堀端2', 400, '庭園', 35.486, 136.758),
    _MockPlace('p_shoka', '古い商家の資料館', '城下町東町4', 300, '資料館', 35.478, 136.766),
    // 島の港町（旅程一覧の「終わった旅」）
    _MockPlace('p_shima_port', '島の港', 'しま町港1', null, '港', 34.320, 134.050),
    _MockPlace('p_shima_toudai', '岬の白い灯台', 'しま町岬', 0, '名所', 34.314, 134.044),
    _MockPlace(
      'p_shima_shokudo',
      '港の海鮮食堂',
      'しま町港3',
      1800,
      '食堂',
      34.321,
      134.052,
    ),
  ];

  final DateTime Function() _clock;
  final _itineraries = <String, Itinerary>{};
  final _updatedAt = <String, DateTime>{};
  final _replans = <String, ReplanResult>{};

  /// replanId → 旅程 ID
  final _replanOwners = <String, String>{};
  final _explanationPolls = <String, int>{};
  var _seq = 0;

  String _nextId(String prefix) => '${prefix}_${++_seq}';

  Future<void> _wait() => Future<void>.delayed(_latency);

  _MockPlace _place(String placeId) => _catalog.firstWhere(
    (p) => p.id == placeId,
    orElse: () => _MockPlace(placeId, placeId, '', null, '', 0, 0),
  );

  String _today() => _dateFromToday(0);

  /// 今日から [days] 日後（負なら前）の日付（YYYY-MM-DD）
  String _dateFromToday(int days) {
    final now = _clock();
    final d = DateTime(now.year, now.month, now.day + days);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  DateTime _at(String date, String hhmm) => DateTime.parse('${date}T$hhmm:00');

  /// 出発地・終わる場所の入力を、施設なら名前と位置で埋める
  _Endpoint _endpoint(String? placeId, LatLng? location, String? name) {
    if (placeId == null) {
      return _Endpoint(null, name ?? '', location);
    }
    final place = _place(placeId);
    return _Endpoint(placeId, place.name, place.location);
  }

  _Endpoint _endpointOfStart(ItineraryStart s) =>
      _Endpoint(s.placeId, s.name, s.location);

  _Endpoint _endpointOfEnd(ItineraryEnd e) =>
      _Endpoint(e.placeId, e.name, e.location);

  List<PlaceInput> _inputsOf(Itinerary itinerary) => [
    for (final item in itinerary.items)
      PlaceInput(
        placeId: item.placeId,
        priority: item.priority,
        stayMin: item.stayMin,
      ),
  ];

  void _seed() {
    final station = _endpoint('p_station', null, null);
    final itinerary = _build(
      id: _seedId,
      version: 1,
      title: 'みなと町 日帰り旅',
      date: _today(),
      start: station,
      departAt: _seedDepartAt,
      end: station,
      arriveBy: _seedArriveBy,
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
    _save(itinerary);
    _seedListSamples();
  }

  /// 旅程一覧の「これから」「終わった旅」に出す旅程
  void _seedListSamples() {
    PlaceInput input(String placeId, Priority priority, int stayMin) =>
        PlaceInput(placeId: placeId, priority: priority, stayMin: stayMin);

    final yama = _endpoint('p_yama_station', null, null);
    _save(
      _build(
        id: _nextId('itn'),
        version: 1,
        title: '山あいの温泉町めぐり',
        date: _dateFromToday(_onsenDaysFromToday),
        start: yama,
        departAt: _seedLateDepartAt,
        end: yama,
        arriveBy: _seedArriveBy,
        places: [
          input('p_onsen', Priority.must, _defaultStayMin * 2),
          input('p_tsuribashi', Priority.want, _defaultStayMin),
          input('p_yama_tera', Priority.optional, _defaultStayMin),
        ],
      ),
    );

    final joka = _endpoint('p_joka_station', null, null);
    _save(
      _build(
        id: _nextId('itn'),
        version: 1,
        title: '城下町さんぽ',
        date: _dateFromToday(_jokaDaysFromToday),
        start: joka,
        departAt: _seedDepartAt,
        end: joka,
        arriveBy: _seedArriveBy,
        places: [
          input('p_shiro', Priority.must, _defaultStayMin),
          input('p_bukeyashiki', Priority.want, _defaultStayMin),
          input('p_wagashi', Priority.optional, _shortStayMin),
          input('p_teien', Priority.want, _defaultStayMin),
          input('p_shoka', Priority.optional, _shortStayMin),
        ],
      ),
    );

    final port = _endpoint('p_shima_port', null, null);
    _save(
      _build(
        id: _nextId('itn'),
        version: 1,
        title: '島の港町 日帰り',
        date: _dateFromToday(_shimaDaysFromToday),
        start: port,
        departAt: _seedLateDepartAt,
        end: port,
        arriveBy: _seedArriveBy,
        places: [
          input('p_shima_toudai', Priority.must, _defaultStayMin),
          input('p_shima_shokudo', Priority.want, _defaultStayMin),
        ],
      ),
    );
  }

  void _save(Itinerary itinerary) {
    _itineraries[itinerary.id] = itinerary;
    _updatedAt[itinerary.id] = _clock();
  }

  /// 行き先を順番に並べ、間と終わる場所までに一定時間の移動を挟むだけの簡易スケジューラ。
  Itinerary _build({
    required String id,
    required int version,
    required String title,
    required String date,
    required _Endpoint start,

    /// HH:mm
    required String departAt,
    required _Endpoint end,

    /// HH:mm
    required String arriveBy,
    required List<PlaceInput> places,
  }) {
    final now = _clock();
    final departDateTime = _at(date, departAt);
    final items = <Item>[];
    final legs = <Leg>[];
    var cursor = departDateTime;
    var prevId = Leg.startItemId;

    Leg leg(String toItemId) => Leg(
      fromItemId: prevId,
      toItemId: toItemId,
      mode: _legMode,
      durationMin: _legMinutes,
      departAt: cursor,
      arriveAt: cursor.add(const Duration(minutes: _legMinutes)),
      lineName: _lineName,
    );

    for (final p in places) {
      final itemId = 'it_${items.length + 1}';
      final toItem = leg(itemId);
      legs.add(toItem);
      final arrive = toItem.arriveAt;
      final leave = arrive.add(Duration(minutes: p.stayMin));
      final catalog = _place(p.placeId);
      items.add(
        Item(
          itemId: itemId,
          placeId: p.placeId,
          name: catalog.name,
          priority: p.priority,
          stayMin: p.stayMin,
          startAt: arrive,
          endAt: leave,
          price: Price(
            amount: catalog.price,
            kind: catalog.price == null
                ? PriceKind.unknown
                : PriceKind.estimate,
          ),
          openingHours: _openingHours,
          status: now.isAfter(leave)
              ? ItemStatus.done
              : (now.isAfter(arrive)
                    ? ItemStatus.current
                    : ItemStatus.upcoming),
        ),
      );
      cursor = leave;
      prevId = itemId;
    }
    final toEnd = leg(Leg.endItemId);
    legs.add(toEnd);

    return Itinerary(
      id: id,
      version: version,
      title: title,
      date: date,
      start: ItineraryStart(
        placeId: start.placeId,
        name: start.name,
        location: start.location,
        departAt: departDateTime,
      ),
      end: ItineraryEnd(
        placeId: end.placeId,
        name: end.name,
        location: end.location,
        arriveBy: arriveBy,
        arriveAt: toEnd.arriveAt,
      ),
      items: items,
      legs: legs,
      summary: _summarize(items, legs, toEnd.arriveAt),
      expiresAt: DateTime.parse(date).add(ApiConstraints.itineraryTtl),
    );
  }

  /// [endAt] は終わる場所に着く時刻
  Summary _summarize(List<Item> items, List<Leg> legs, DateTime endAt) {
    final known = items.where((i) => i.price.amount != null);
    return Summary(
      moveMin: legs.fold(0, (sum, l) => sum + l.durationMin),
      priceTotal: PriceTotal(
        amount: known.fold(0, (sum, i) => sum + i.price.amount!),
        hasEstimate: items.any((i) => i.price.kind != PriceKind.fixed),
      ),
      endAt: endAt,
    );
  }

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool _isLate(Itinerary itinerary, DateTime arriveAt) =>
      arriveAt.isAfter(_at(itinerary.date, itinerary.end.arriveBy));

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

  void _checkLimit() {
    if (_itineraries.length >= ApiConstraints.itineraryMaxCount) {
      throw const ApiException(
        statusCode: 422,
        code: ApiErrorCode.itineraryLimit,
        message: '保存できる旅程は ${ApiConstraints.itineraryMaxCount} 件までです',
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
      InterpretedCandidate(place: cafe.toPlace(), reason: '海に面したテラス席がある'),
      InterpretedCandidate(place: tenbou.toPlace(), reason: '夕方の海の景色が見られる'),
    ];
  }

  @override
  Future<Itinerary> createItinerary(CreateItineraryRequest request) async {
    await _wait();
    _checkLimit();
    final s = request.start;
    final e = request.end;
    final itinerary = _build(
      id: _nextId('itn'),
      version: 1,
      title: request.title,
      date: request.date,
      start: _endpoint(s.placeId, s.location, s.name),
      departAt: s.departAt,
      end: _endpoint(e.placeId, e.location, e.name),
      arriveBy: e.arriveBy,
      places: request.places,
    );
    _save(itinerary);
    return itinerary;
  }

  @override
  Future<ItineraryPage> myItineraries({int? limit, String? cursor}) async {
    await _wait();
    final sorted = _itineraries.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final offset = cursor == null ? 0 : int.parse(cursor);
    final size = limit ?? ApiConstraints.myItinerariesLimitDefault;
    final page = sorted.skip(offset).take(size).toList();
    final next = offset + page.length;
    return ItineraryPage(
      itineraries: [
        for (final i in page)
          ItineraryListEntry(
            id: i.id,
            title: i.title,
            date: i.date,
            start: ItineraryListStart(
              name: i.start.name,
              departAt: i.start.departAt,
            ),
            end: ItineraryListEnd(name: i.end.name, arriveAt: i.end.arriveAt),
            placeCount: i.items.length,
            placeNames: i.items
                .take(ApiConstraints.listPlaceNamesMaxCount)
                .map((item) => item.name)
                .toList(),
            updatedAt: _updatedAt[i.id] ?? _clock(),
            expiresAt: i.expiresAt,
          ),
      ],
      nextCursor: next < sorted.length ? '$next' : null,
    );
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
    final s = request.start;
    final e = request.end;
    final updated = _build(
      id: id,
      version: current.version + 1,
      title: current.title,
      date: request.date ?? current.date,
      start: s == null
          ? _endpointOfStart(current.start)
          : _endpoint(s.placeId, s.location, s.name),
      departAt: s?.departAt ?? _hhmm(current.start.departAt),
      end: e == null
          ? _endpointOfEnd(current.end)
          : _endpoint(e.placeId, e.location, e.name),
      arriveBy: e?.arriveBy ?? current.end.arriveBy,
      places: request.places,
    );
    _save(updated);
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
    // 簡易的に、遅れた分だけ終わる場所に着く時刻も遅れるとする
    final endAtAfter = itinerary.end.arriveAt.add(delay);

    final replanId = _nextId('rp');
    final option = ReplanOption(
      optionId: 'op_1',
      changes: changes,
      summaryBefore: itinerary.summary,
      summaryAfter: _summarize(previewItems, itinerary.legs, endAtAfter),
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
        if (_isLate(itinerary, endAtAfter))
          ReplanWarning(
            type: ReplanWarningType.endAtRisk,
            message:
                '${itinerary.end.arriveBy} までに${itinerary.end.name}に戻れません。',
          ),
      ],
      options: [option],
      explanation: const Explanation(status: ExplanationStatus.pending),
    );
    _replans[replanId] = result;
    _replanOwners[replanId] = id;
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
      end: itinerary.end.copyWith(arriveAt: option.summaryAfter.endAt),
      items: option.preview.items,
      legs: option.preview.legs,
      summary: option.summaryAfter,
    );
    _save(updated);
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
        place: tenbou.toPlace(),
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
    final added = PlaceInput(
      placeId: request.placeId,
      priority: request.priority,
      stayMin: request.stayMin,
    );
    final places = [
      for (final item in itinerary.items) ...[
        PlaceInput(
          placeId: item.placeId,
          priority: item.priority,
          stayMin: item.stayMin,
        ),
        if (item.itemId == request.insertAfterItemId) added,
      ],
      if (request.insertAfterItemId == null) added,
    ];
    final before = _itineraries[id];
    final updated = await updatePlaces(
      id,
      UpdatePlacesRequest(places: places),
      version: version,
    );
    if (_isLate(updated, updated.end.arriveAt)) {
      // 追加すると終わる場所に間に合わないので、元に戻して 422 にする
      _itineraries[id] = before!;
      throw ApiException(
        statusCode: 422,
        code: ApiErrorCode.endInfeasible,
        message:
            '追加すると ${itinerary.end.arriveBy} までに${itinerary.end.name}に着けません',
      );
    }
    return updated;
  }

  @override
  Future<List<NearbyPlace>> nearbyPlaces({
    required LatLng center,
    int? radius,
    String? query,
  }) async {
    await _wait();
    final r = (radius ?? ApiConstraints.nearbyRadiusDefault) / _metersPerDegree;
    return _catalog
        .where(
          (p) =>
              (p.lat - center.lat).abs() <= r &&
              (p.lng - center.lng).abs() <= r &&
              (query == null || p.name.contains(query)),
        )
        .take(ApiConstraints.nearbyMaxResults)
        .map(
          (p) => NearbyPlace(
            placeId: p.id,
            name: p.name,
            address: p.address,
            location: p.location,
            typeLabel: p.typeLabel,
          ),
        )
        .toList();
  }

  @override
  Future<PlaceDetail> placeDetail(String placeId, {String? date}) async {
    await _wait();
    final p = _catalog.firstWhere(
      (p) => p.id == placeId,
      orElse: () => throw const ApiException(
        statusCode: 404,
        code: ApiErrorCode.notFound,
        message: '施設が見つかりません',
      ),
    );
    return PlaceDetail(
      place: p.toPlace(),
      typeLabel: p.typeLabel,
      openingHours: _openingHours,
      price: Price(
        amount: p.price,
        kind: p.price == null ? PriceKind.unknown : PriceKind.estimate,
      ),
    );
  }

  @override
  Future<Itinerary> renameItinerary(
    String id, {
    required String title,
    required int version,
  }) async {
    await _wait();
    final current = _require(id);
    _checkVersion(current, version);
    final updated = current.copyWith(
      version: current.version + 1,
      title: title,
    );
    _save(updated);
    return updated;
  }

  @override
  Future<void> deleteItinerary(String id, {required int version}) async {
    await _wait();
    final current = _require(id);
    _checkVersion(current, version);
    _itineraries.remove(id);
    _updatedAt.remove(id);
    // 組み直し案も一緒に削除する
    final replanIds = _replanOwners.entries
        .where((e) => e.value == id)
        .map((e) => e.key)
        .toList();
    for (final replanId in replanIds) {
      _replans.remove(replanId);
      _replanOwners.remove(replanId);
    }
  }

  @override
  Future<Itinerary> copyItinerary(
    String id,
    CopyItineraryRequest request,
  ) async {
    await _wait();
    final source = _require(id);
    _checkLimit();
    final copy = _build(
      id: _nextId('itn'),
      version: 1,
      title: request.title ?? source.title,
      date: request.date,
      start: _endpointOfStart(source.start),
      departAt: _hhmm(source.start.departAt),
      end: _endpointOfEnd(source.end),
      arriveBy: source.end.arriveBy,
      places: _inputsOf(source),
    );
    _save(copy);
    return copy;
  }
}

class _MockPlace {
  const _MockPlace(
    this.id,
    this.name,
    this.address,
    this.price,
    this.typeLabel,
    this.lat,
    this.lng,
  );

  final String id;
  final String name;
  final String address;
  final int? price;
  final String typeLabel;
  final double lat;
  final double lng;

  LatLng get location => LatLng(lat: lat, lng: lng);

  Place toPlace() =>
      Place(placeId: id, name: name, address: address, location: location);
}

/// 出発地・終わる場所（施設でなければ placeId が null）
class _Endpoint {
  const _Endpoint(this.placeId, this.name, this.location);

  final String? placeId;
  final String name;
  final LatLng? location;
}
