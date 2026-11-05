package me

// GET /me/itineraries
// ログイン中の利用者の旅程を、旅行日の新しい順に返す。
//
// 入力: なし。
// 認証: Bearer の Firebase ID token を検証し、ownerUid が uid と一致する旅程だけを取得する。
// 出力（200、JSON / UTF-8）: itineraries 配列。各旅程は id、title、date、updatedAt。
// エラー: 401 UNAUTHENTICATED、429 RATE_LIMITED。
//
// 実装する処理: 認証 → 本人の旅程を検索 → 旅行日の降順で返す。
