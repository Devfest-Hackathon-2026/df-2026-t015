package replans

// POST /itineraries/:id/replans/:replanId/accept
// 選択した組み直し案を旅程に反映する（F-04）。
//
// 入力（パス）: id（旅程ID）、replanId（組み直し案ID）。
// 入力（JSON）: optionId。
// ヘッダー: If-Match: <version> が必須。案の basedOnVersion と同じ値を送る。
// 認証: Bearer の Firebase ID token を検証し、旅程の ownerUid と uid を照合する。
// 出力（200、JSON / UTF-8）: 更新後の Itinerary。version を1増やし、ETag に入れる。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、404 NOT_FOUND、429 RATE_LIMITED。
//   409 VERSION_CONFLICT: 旅程が先に更新されている。
//   410 REPLAN_EXPIRED: 案の有効期限（15分）が切れている。
//
// 実装する処理: 認証・所有者確認 → 案・期限を確認 → version を照合して反映 → 返す。
