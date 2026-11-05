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

  /// 4. GET /me/itineraries（旅行日の新しい順）
  Future<List<ItineraryListEntry>> myItineraries();

  /// 5. GET /itineraries/:id（F-06）
  Future<Itinerary> getItinerary(String id);

  /// 6. PUT /itineraries/:id/places（F-01、F-02）
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
}
