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
}

/// API のヘッダー名など、通信で使う固定値。
abstract final class ApiHeaders {
  static const authorization = 'Authorization';
  static const bearerPrefix = 'Bearer ';
  static const ifMatch = 'If-Match';
  static const etag = 'ETag';
}
