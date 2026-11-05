package replans

// GET /itineraries/:id/replans/:replanId/explanation
// Gemini が生成する、組み直し案の変更理由を返す（F-05）。
//
// 入力（パス）: id（旅程ID）、replanId（組み直し案ID）。
// 入力（クエリ）: optionId が必須。
// 認証: Bearer の Firebase ID token を検証し、旅程の ownerUid と uid を照合する。
// 出力（200、JSON / UTF-8）: status（pending / ready / failed）と、完了時の text。
//   pending の間はクライアントが1秒間隔で取得する。
//   failed の場合は画面で定型文を表示し、案の確定は可能にする。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、404 NOT_FOUND、429 RATE_LIMITED。
//
// 実装する処理: 認証・所有者確認 → 対象の案を確認 → 理由文の生成状況と結果を返す。
