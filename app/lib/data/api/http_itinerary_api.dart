import 'package:dio/dio.dart';

import '../../constants/api_constraints.dart';
import '../models/models.dart';
import 'api_exception.dart';
import 'itinerary_api.dart';

/// Cloud Run 上の Go の API サーバーと通信する [ItineraryApi]。
///
/// TODO: サーバーの OpenAPI 定義ができたら、生成した Dart クライアントに置き換える。
class HttpItineraryApi implements ItineraryApi {
  HttpItineraryApi({
    required String baseUrl,
    required Future<String?> Function() idToken,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = _connectTimeout
      ..receiveTimeout = _receiveTimeout
      ..contentType = Headers.jsonContentType
      ..responseType = ResponseType.json;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await idToken();
          if (token != null) {
            options.headers[ApiHeaders.authorization] =
                '${ApiHeaders.bearerPrefix}$token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static const _connectTimeout = Duration(seconds: 10);
  // 組み直しは非機能要件で 10 秒以内に表示するため、少し余裕を持たせる
  static const _receiveTimeout = Duration(seconds: 15);

  final Dio _dio;

  Options _ifMatch(int version) =>
      Options(headers: {ApiHeaders.ifMatch: version.toString()});

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode,
        e.response?.data ?? e.message,
      );
    }
  }

  /// 本文のない応答（204）を返す API 用
  Future<void> _sendNoContent(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      await request();
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode,
        e.response?.data ?? e.message,
      );
    }
  }

  List<T> _list<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) => (json[key] as List<dynamic>)
      .map((e) => fromJson(e as Map<String, dynamic>))
      .toList();

  Map<String, dynamic> _near(LatLng? near) =>
      near == null ? const {} : {'lat': near.lat, 'lng': near.lng};

  @override
  Future<List<Place>> autocomplete(String query, {LatLng? near}) async {
    final json = await _send(
      () => _dio.get(
        '/places/autocomplete',
        queryParameters: {'q': query, ..._near(near)},
      ),
    );
    return _list(json, 'candidates', Place.fromJson);
  }

  @override
  Future<List<InterpretedCandidate>> interpret(
    String text, {
    LatLng? near,
  }) async {
    final json = await _send(
      () => _dio.post(
        '/places/interpret',
        data: {'text': text, if (near != null) 'near': near.toJson()},
      ),
    );
    return _list(json, 'candidates', InterpretedCandidate.fromJson);
  }

  @override
  Future<Itinerary> createItinerary(CreateItineraryRequest request) async =>
      Itinerary.fromJson(
        await _send(() => _dio.post('/itineraries', data: request.toJson())),
      );

  @override
  Future<ItineraryPage> myItineraries({int? limit, String? cursor}) async =>
      ItineraryPage.fromJson(
        await _send(
          () => _dio.get(
            '/me/itineraries',
            queryParameters: {'limit': ?limit, 'cursor': ?cursor},
          ),
        ),
      );

  @override
  Future<Itinerary> getItinerary(String id) async =>
      Itinerary.fromJson(await _send(() => _dio.get('/itineraries/$id')));

  @override
  Future<Itinerary> updatePlaces(
    String id,
    UpdatePlacesRequest request, {
    required int version,
  }) async => Itinerary.fromJson(
    await _send(
      () => _dio.put(
        '/itineraries/$id/places',
        data: request.toJson(),
        options: _ifMatch(version),
      ),
    ),
  );

  @override
  Future<ReplanResult> createReplan(String id, ReplanRequest request) async =>
      ReplanResult.fromJson(
        await _send(
          () => _dio.post('/itineraries/$id/replans', data: request.toJson()),
        ),
      );

  @override
  Future<Explanation> getExplanation(
    String id,
    String replanId, {
    required String optionId,
  }) async => Explanation.fromJson(
    await _send(
      () => _dio.get(
        '/itineraries/$id/replans/$replanId/explanation',
        queryParameters: {'optionId': optionId},
      ),
    ),
  );

  @override
  Future<Itinerary> acceptReplan(
    String id,
    String replanId, {
    required String optionId,
    required int version,
  }) async => Itinerary.fromJson(
    await _send(
      () => _dio.post(
        '/itineraries/$id/replans/$replanId/accept',
        data: {'optionId': optionId},
        options: _ifMatch(version),
      ),
    ),
  );

  @override
  Future<List<Suggestion>> suggestions(
    String id, {
    required DateTime from,
    required DateTime to,
    String? afterItemId,
  }) async {
    final json = await _send(
      () => _dio.get(
        '/itineraries/$id/suggestions',
        queryParameters: {
          'from': toRfc3339(from),
          'to': toRfc3339(to),
          'afterItemId': ?afterItemId,
        },
      ),
    );
    return _list(json, 'suggestions', Suggestion.fromJson);
  }

  @override
  Future<Itinerary> addItem(
    String id,
    AddItemRequest request, {
    required int version,
  }) async => Itinerary.fromJson(
    await _send(
      () => _dio.post(
        '/itineraries/$id/items',
        data: request.toJson(),
        options: _ifMatch(version),
      ),
    ),
  );

  @override
  Future<List<NearbyPlace>> nearbyPlaces({
    required LatLng center,
    int? radius,
    String? query,
  }) async {
    final json = await _send(
      () => _dio.get(
        '/places/nearby',
        queryParameters: {
          'lat': center.lat,
          'lng': center.lng,
          'radius': ?radius,
          'q': ?query,
        },
      ),
    );
    return _list(json, 'places', NearbyPlace.fromJson);
  }

  @override
  Future<PlaceDetail> placeDetail(String placeId, {String? date}) async =>
      PlaceDetail.fromJson(
        await _send(
          () => _dio.get(
            '/places/${Uri.encodeComponent(placeId)}',
            queryParameters: {'date': ?date},
          ),
        ),
      );

  @override
  Future<Itinerary> renameItinerary(
    String id, {
    required String title,
    required int version,
  }) async => Itinerary.fromJson(
    await _send(
      () => _dio.patch(
        '/itineraries/$id',
        data: {'title': title},
        options: _ifMatch(version),
      ),
    ),
  );

  @override
  Future<void> deleteItinerary(String id, {required int version}) =>
      _sendNoContent(
        () => _dio.delete('/itineraries/$id', options: _ifMatch(version)),
      );

  @override
  Future<Itinerary> copyItinerary(
    String id,
    CopyItineraryRequest request,
  ) async => Itinerary.fromJson(
    await _send(
      () => _dio.post('/itineraries/$id/copy', data: request.toJson()),
    ),
  );
}
