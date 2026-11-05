package itineraries

// GET /itineraries/:id
// 旅程を1件取得する（F-06）。
//
// 入力（パス）: id（旅程ID）。
// 認証: Bearer の Firebase ID token を検証し、ownerUid と uid を照合する。
// 出力（200、JSON / UTF-8）: Itinerary。ETag に version を入れる。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、429 RATE_LIMITED。
//   旅程が存在しない、または本人のものでない場合は404 NOT_FOUND。
//
// 実装する処理: 認証 → 旅程を取得 → 所有者を確認 → 旅程を返す。
