import '../models/models.dart';

/// サーバー API（docs/iterinerary_API.docx）のクライアント。
///
/// 旅程を変更するメソッドは、楽観ロックのため旅程の [version] を受け取り
/// If-Match ヘッダーに載せる。失敗時は [ApiException] を投げる。
abstract interface class ItineraryApi {
  /// 1. GET /places/autocomplete（F-01）
  Future<List<Place>> autocomplete(String query, {LatLng? near});

  /// 2. POST /places/interpret（F-01、Gemini）
  Future<List<InterpretedCandidate>> interpret(String text, {LatLng? near});

  /// 3. POST /itineraries（F-02）
  Future<Itinerary> createItinerary(CreateItineraryRequest request);

  /// 4. GET /me/itineraries（F-08、旅行日の新しい順）
  ///
  /// 続きは前の応答の [ItineraryPage.nextCursor] を [cursor] に渡して取得する。
  Future<ItineraryPage> myItineraries({int? limit, String? cursor});

  /// 5. GET /itineraries/:id（F-06）
  Future<Itinerary> getItinerary(String id);

  /// 6. PUT /itineraries/:id/places（F-01、F-02、F-09、F-10）
  ///
  /// 行き先・優先度に加え、出発と終わり・旅行日も変えられる。
  Future<Itinerary> updatePlaces(
    String id,
    UpdatePlacesRequest request, {
    required int version,
  });

  /// 7. POST /itineraries/:id/replans（F-03、F-04）
  Future<ReplanResult> createReplan(String id, ReplanRequest request);

  /// 8. GET /itineraries/:id/replans/:replanId/explanation（F-05、Gemini）
  Future<Explanation> getExplanation(
    String id,
    String replanId, {
    required String optionId,
  });

  /// 9. POST /itineraries/:id/replans/:replanId/accept（F-04）
  Future<Itinerary> acceptReplan(
    String id,
    String replanId, {
    required String optionId,
    required int version,
  });

  /// 10. GET /itineraries/:id/suggestions（F-07）
  Future<List<Suggestion>> suggestions(
    String id, {
    required DateTime from,
    required DateTime to,
    String? afterItemId,
  });

  /// 11. POST /itineraries/:id/items（F-07）
  Future<Itinerary> addItem(
    String id,
    AddItemRequest request, {
    required int version,
  });

  /// 12. GET /places/nearby（F-10）。地図の中心 [center] の近くの施設（最大 20 件）。
  ///
  /// [radius] は m 単位、[query] は名前での絞り込み。
  Future<List<NearbyPlace>> nearbyPlaces({
    required LatLng center,
    int? radius,
    String? query,
  });

  /// 13. GET /places/:placeId（F-10）。[date]（YYYY-MM-DD）の営業時間を返す。
  Future<PlaceDetail> placeDetail(String placeId, {String? date});

  /// 14. PATCH /itineraries/:id（F-09）。旅程の名前を変える。
  Future<Itinerary> renameItinerary(
    String id, {
    required String title,
    required int version,
  });

  /// 15. DELETE /itineraries/:id（F-09）。組み直し案も一緒に消える。
  Future<void> deleteItinerary(String id, {required int version});

  /// 16. POST /itineraries/:id/copy（F-11）。新しい日付で作り直した旅程を返す。
  Future<Itinerary> copyItinerary(String id, CopyItineraryRequest request);
}
