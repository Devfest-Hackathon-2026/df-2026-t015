package itineraries

// POST /itineraries
// 行き先と優先度から1日分の旅程を生成する（F-02）。
//
// 入力（JSON）:
//   title、date（YYYY-MM-DD）、start（placeId / departAt）、endBy（HH:mm）、places。
//   departAt は HH:mm。places は1〜10件で、各行き先は placeId、priority、stayMin を持つ。
//   priority は must / want / optional、stayMin は10〜480分。
//
// 認証: Bearer の Firebase ID token を検証し、uid を ownerUid として保存する。
// 出力（201、JSON / UTF-8）: Itinerary。入りきらない行き先と理由は dropped に入れる。
//   version は1から開始し、ETag に version を入れる。
//   expiresAt は旅行日から30日後。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、429 RATE_LIMITED、502 UPSTREAM_ERROR。
//   必須の予定が入りきらない場合は422 MUST_ITEMS_INFEASIBLE。details.placeIds に対象を入れる。
//
// 実装する処理: 認証 → 入力チェック → 移動時間・営業時間を判定 → 旅程を生成・保存 → 返す。
