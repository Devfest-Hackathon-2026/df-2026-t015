/// API 仕様（docs/iterinerary_API.docx）で決められた入力の制約。
abstract final class ApiConstraints {
  /// GET /places/autocomplete の q の長さ
  static const autocompleteQueryMinLength = 1;
  static const autocompleteQueryMaxLength = 100;

  /// POST /places/interpret の text の最大長
  static const interpretTextMaxLength = 200;

  /// POST /places/interpret の候補の最大件数
  static const interpretMaxCandidates = 5;

  /// 旅程に入れられる行き先の件数
  static const placesMinCount = 1;
  static const placesMaxCount = 10;

  /// 滞在時間（分）
  static const stayMinMin = 10;
  static const stayMinMax = 480;

  /// POST /itineraries/:id/replans の delayMin（分）
  static const delayMinMin = 0;
  static const delayMinMax = 600;

  /// 組み直し案の最大件数と有効期限
  static const replanMaxOptions = 3;
  static const replanTtl = Duration(minutes: 15);

  /// 旅程の保存期間（旅行日から）
  static const itineraryTtl = Duration(days: 30);

  /// 1 人が保存できる旅程の件数
  static const itineraryMaxCount = 20;

  /// 旅程名（PATCH /itineraries/:id の title）の長さ
  static const titleMinLength = 1;
  static const titleMaxLength = 50;

  /// GET /me/itineraries の limit
  static const myItinerariesLimitMin = 1;
  static const myItinerariesLimitMax = 50;
  static const myItinerariesLimitDefault = 20;

  /// GET /me/itineraries の placeNames の最大件数
  static const listPlaceNamesMaxCount = 3;

  /// GET /places/nearby の radius（m）
  static const nearbyRadiusMin = 100;
  static const nearbyRadiusMax = 5000;
  static const nearbyRadiusDefault = 1000;

  /// GET /places/nearby の q の長さ
  static const nearbyQueryMinLength = 1;
  static const nearbyQueryMaxLength = 100;

  /// GET /places/nearby の最大件数
  static const nearbyMaxResults = 20;
}

/// API のヘッダー名など、通信で使う固定値。
abstract final class ApiHeaders {
  static const authorization = 'Authorization';
  static const bearerPrefix = 'Bearer ';
  static const ifMatch = 'If-Match';
  static const etag = 'ETag';
}
