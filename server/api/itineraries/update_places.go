package itineraries

// PUT /itineraries/:id/places
// 行き先・優先度・終了希望時刻を編集し、旅程を再生成する（F-01、F-02）。
//
// 入力（パス）: id（旅程ID）。
// 入力（JSON）:
//   places: 全件を送る。1〜10件で、各行き先は placeId、priority、stayMin を持つ。
//   priority は must / want / optional、stayMin は10〜480分。
//   endBy: 任意。終了希望時刻（HH:mm）。
// ヘッダー: If-Match: <version> が必須。
//
// 認証: Bearer の Firebase ID token を検証し、ownerUid と uid を照合する。
// 出力（200、JSON / UTF-8）: 更新後の Itinerary。version を1増やし、ETag に入れる。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、404 NOT_FOUND、429 RATE_LIMITED、502 UPSTREAM_ERROR。
//   409 VERSION_CONFLICT: version が現在の旅程と異なる。
//   422 MUST_ITEMS_INFEASIBLE: 必須の予定が入りきらない。details.placeIds に対象を入れる。
//
// 実装する処理: 認証・所有者確認 → 入力チェック → 再生成 → version を照合して更新 → 返す。
