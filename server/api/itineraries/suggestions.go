package itineraries

// GET /itineraries/:id/suggestions
// 空き時間に入れられる近くの予定を提案する（F-07）。
//
// 入力（パス）: id（旅程ID）。
// 入力（クエリ）: from / to（日時）が必須。afterItemId（直前の予定ID）は任意。
// 認証: Bearer の Firebase ID token を検証し、ownerUid と uid を照合する。
// 出力（200、JSON / UTF-8）: suggestions 配列。
//   各提案は place、reason、stayMin、price、insertAfterItemId、legFromPrev を持つ。
//   place は placeId、name、address、location。legFromPrev は mode、durationMin。
//   price は amount、kind（fixed / estimate / unknown）、任意の source。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、404 NOT_FOUND、429 RATE_LIMITED、502 UPSTREAM_ERROR。
//
// 実装する処理: 認証・所有者確認 → 空き時間を確認 → 近隣施設・移動時間を調べる → 提案を返す。
