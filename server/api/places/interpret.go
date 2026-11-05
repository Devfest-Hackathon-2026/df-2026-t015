package places

// POST /places/interpret
// 自由文を Gemini で解釈し、Places API で実在する施設に絞る（F-01）。
//
// 入力（JSON）:
//   text: 必須。200文字以内の希望。
//   near: {lat, lng} または {placeId}。
//
// 認証: Bearer の Firebase ID token をサーバーで検証する。
// 出力（200、JSON / UTF-8）: candidates 配列（最大5件）。各候補は place と reason。
//   place は placeId、name、address、location（lat / lng）を持つ。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、429 RATE_LIMITED、502 UPSTREAM_ERROR。
//
// 実装する処理: 認証 → 入力チェック → Gemini で解釈 → 施設を検索 → 候補を返す。
