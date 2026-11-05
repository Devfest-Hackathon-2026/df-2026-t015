package itineraries

// POST /itineraries/:id/items
// 提案された予定、または利用者が選んだ施設を旅程に追加する（F-07）。
//
// 入力（パス）: id（旅程ID）。
// 入力（JSON）: placeId、stayMin、priority、insertAfterItemId。
//   priority は must / want / optional、stayMin は滞在時間（分）。
// ヘッダー: If-Match: <version> が必須。
// 認証: Bearer の Firebase ID token を検証し、ownerUid と uid を照合する。
// 出力（200、JSON / UTF-8）: 更新後の Itinerary。version を1増やし、ETag に入れる。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、404 NOT_FOUND、429 RATE_LIMITED、502 UPSTREAM_ERROR。
//   409 VERSION_CONFLICT: version が現在の旅程と異なる。
//   422: 予定を追加すると終了希望時刻を超える。
//
// 実装する処理: 認証・所有者確認 → 入力チェック → 追加後の時刻を計算 → version を照合して保存 → 返す。
