package replans

// POST /itineraries/:id/replans
// 遅延による組み直しの必要性を判定し、必要なら最大3案を返す（F-03、F-04）。
//
// 入力（パス）: id（旅程ID）。
// 入力（JSON）: currentItemId と、delayMin（0〜600分）または now（日時）のどちらか一方。
//   now の場合は、予定との差からサーバーで遅延を計算する。
// 認証: Bearer の Firebase ID token を検証し、旅程の ownerUid と uid を照合する。
//
// 出力（200、JSON / UTF-8）:
//   不要な場合: {"needsChange": false, "warnings": [], "options": []}。
//   必要な場合: replanId、basedOnVersion、needsChange、expiresAt、warnings、options、explanation。
//   各案は optionId、changes、summaryBefore、summaryAfter、preview（items / legs）を持つ。
//   changes の type は replace / retime / drop / keep。explanation.status は pending。
//   必須の予定を守れない場合は warnings に must_at_risk を入れ、除外案も提示する。
//   案の有効期限は15分。計算はサーバーで行い、Gemini は代替先候補の選択にだけ使う。
// エラー: 400 INVALID_ARGUMENT、401 UNAUTHENTICATED、404 NOT_FOUND、429 RATE_LIMITED、502 UPSTREAM_ERROR。
//
// 実装する処理: 認証・所有者確認 → 入力チェック → 組み直しを計算 → 案を保存 → 返す。
