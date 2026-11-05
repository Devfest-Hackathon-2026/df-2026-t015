package places

// GET /places/autocomplete
// 施設名の入力補完（F-01）。Places API（Autocomplete）から候補を取得する。
//
// 入力（クエリ）:
//   q: 必須。1〜100文字の入力中の施設名。
//   lat / lng: 任意。指定地点に近い施設を優先する。
//
// 認証:
//   Authorization: Bearer <Firebase ID token> を必須とし、サーバーで検証する。
//
// 出力（200、JSON / UTF-8）:
//   {"candidates": [{"placeId": "ChIJ...", "name": "海の美術館", "address": "みなと町1-2-3"}]}
//
// エラー:
//   400 INVALID_ARGUMENT: 入力が不正。
//   401 UNAUTHENTICATED: トークンがない、または無効。
//   429 RATE_LIMITED: リクエスト回数の上限を超えた。
//   502 UPSTREAM_ERROR: Places API の呼び出しに失敗した。
//   形式: {"error": {"code": "INVALID_ARGUMENT", "message": "入力が不正です", "details": {}}}
//
// 実装する処理:
//   認証 → 入力チェック → Places API の呼び出し → 候補を JSON で返す。
