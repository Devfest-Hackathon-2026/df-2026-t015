package api

// GET /healthz
// Cloud Run 用のヘルスチェック。
//
// 入力: なし。認証不要。
// 出力（200、JSON / UTF-8）: {"status": "ok"}。
//
// 実装する処理: 正常稼働していることを JSON で返す。
