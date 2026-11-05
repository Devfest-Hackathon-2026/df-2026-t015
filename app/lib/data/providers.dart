import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../config/app_config.dart';
import 'api/http_itinerary_api.dart';
import 'api/itinerary_api.dart';
import 'api/mock_itinerary_api.dart';
import 'auth/auth_repository.dart';
import 'models/models.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockApi) return const FakeAuthRepository();
  return FirebaseAuthRepository(FirebaseAuth.instance);
});

final itineraryApiProvider = Provider<ItineraryApi>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockApi) return MockItineraryApi();
  final auth = ref.watch(authRepositoryProvider);
  return HttpItineraryApi(baseUrl: config.apiBaseUrl, idToken: auth.idToken);
});

/// 自分の旅程一覧（F-06）
final myItinerariesProvider =
    FutureProvider.autoDispose<List<ItineraryListEntry>>(
      (ref) => ref.watch(itineraryApiProvider).myItineraries(),
    );

/// 旅程 1 件。更新系 API の結果はここに反映して、各画面が同じ旅程を見るようにする。
final itineraryProvider =
    AsyncNotifierProvider.family<ItineraryNotifier, Itinerary, String>(
      ItineraryNotifier.new,
    );

class ItineraryNotifier extends AsyncNotifier<Itinerary> {
  ItineraryNotifier(this.id);

  final String id;

  ItineraryApi get _api => ref.read(itineraryApiProvider);

  @override
  Future<Itinerary> build() => _api.getItinerary(id);

  Future<void> reload() async {
    state = await AsyncValue.guard(() => _api.getItinerary(id));
  }

  /// サーバーから返った最新の旅程で置き換える
  void replace(Itinerary itinerary) {
    state = AsyncData(itinerary);
  }

  Future<Itinerary> updatePlaces(UpdatePlacesRequest request) async {
    final current = await future;
    final updated = await _api.updatePlaces(
      id,
      request,
      version: current.version,
    );
    replace(updated);
    return updated;
  }

  Future<Itinerary> acceptReplan({
    required String replanId,
    required String optionId,
    required int basedOnVersion,
  }) async {
    final updated = await _api.acceptReplan(
      id,
      replanId,
      optionId: optionId,
      version: basedOnVersion,
    );
    replace(updated);
    return updated;
  }

  Future<Itinerary> addItem(AddItemRequest request) async {
    final current = await future;
    final updated = await _api.addItem(id, request, version: current.version);
    replace(updated);
    return updated;
  }
}
