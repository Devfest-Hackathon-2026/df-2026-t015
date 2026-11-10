# Domestic transit and multi-day itineraries implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** 国内の電車・バスを実際の経路から計算し、終了日を指定した旅程を生成・編集・コピー・再計算できるようにする。

**Architecture:** Google Placesで施設と座標を取得し、mixway APIで移動を計算する。既存の `date` と時刻入力は保ち、任意の `end.date` を追加する。Go標準HTTPと現在のFlutter/Freezed構成を使う。

**Tech Stack:** Go 1.26、net/http、Firebase/Firestore、mixway REST、Flutter、Freezed。

**Spec:** `docs/superpowers/specs/2026-11-10-transit-multiday-design.md`（利用者承認済み）

## Global Constraints

- 外部HTTPは15秒、リクエスト全体は60秒。
- `end.date` の省略は開始日と同じ日。
- 施設数と各施設の滞在時間の既存の上限を変更しない。
- 宿泊・就寝時間・日ごとの活動時間帯を自動で作らない。
- キー、認証情報、外部エラー本文を利用者に返さない。
- 契約・キー発行申込・課金設定・デプロイ・push・PR作成は含めない。
- 標準ライブラリで足りるHTTP処理に新しい依存を加えない。

## Review Focus

- 公共交通の取得失敗を徒歩として保存しない（Task 2）。
- 2日目の編集・遅延で時刻が開始日に戻らない（Task 1）。
- 終了日を省略した旧レコードと旧クライアントが動く（Task 1, 3）。
- 待ち時間・降車後の徒歩を含めた実際の到着で締切を判断する（Task 2）。
- コピー・開始日の編集後も旅程の日数を保つ（Task 1, 3）。

---

## Task 1: 終了日と日時計算

**Files:** `server/internal/service/types.go`, `planner.go`, `items.go`, `replan.go`, `order.go`, 各 `*_test.go`, `server/api/flow_test.go`。

**Interfaces:**
- `End.Date string` は `json:"date,omitempty"`。省略を解決する `endDate(startDate string, end End) string` と、締切を計算する `ValidateEnd(date string, end End) (time.Time, error)` を共用する。
- `Waypoint.HasLocation bool` を追加する。座標が渡された地点・取得済みの施設にはtrueを立て、Task 2が重複取得を避ける。
- `OpenAtUntil(hours *Hours, arrival time.Time, stay int, limit time.Time)` は既存の `OpenAt` と同じ3戻り値で、期限までの次の営業区間を探す。従来の `OpenAt` は同日で必要な呼び出しに残す。

- [x] `TestOvernightPlan`, `TestNextDayOpening`, `TestOvernightCopy`, `TestEditSecondDay`, `TestDelayAcrossMidnight`, `TestSuggestionsSecondDay` を追加する。同日と翌日の1時を区別し、旧入力を確認する。
- [x] 新しいテストが現在の実装で失敗することを確認する。
- [x] `End.Date` と締切計算を追加し、生成・編集・コピー・遅延・提案に使う。部分計算の開始日は実際の出発日、結合後の旅程の開始日は元の日付にする。保存期限は終了日+30日。
- [x] コピーと開始日変更は終了日を同じ日数だけ移す。営業時間の次日探索は終了期限内に限定する。
- [x] Goの対象テストを実行する。Task 2とテスト用の経路応答を統合した後、APIフローテストを実行する。

## Task 2: mixway接続

**Files:** 新規 `server/internal/service/transit.go`, `transit_test.go`; `maps.go`, `firebase.go`, `clients_test.go`, 経路を置き換える既存のテストfixture; `.env.example`, `README.md`。

**Interfaces:**
- `Maps.Route(ctx context.Context, from, to Waypoint, depart time.Time) (Leg, error)` は維持する。
- `Maps.Transit *Transit`、`Transit{Key string, HTTP *http.Client}` を使う。`Transit.Route(ctx, from Point, to Point, depart time.Time) (Leg, error)` は固定のmixwayエンドポイントへ送る。
- 取得済みの座標は `Waypoint.HasLocation` で判別する。必要なときだけGoogle Placesから座標を取得する。

- [x] `TestTransitRoute`, `TestTransitWaitAndOvernight`, `TestTransitUnavailable`, `TestTransitErrors` を追加する。鉄道・バス・徒歩、空の経路、欠落・不正な時刻、応答内エラー、429、キー未設定を検証する。
- [x] 現在の実装で失敗することを確認する。
- [x] `MIXWAY_API_KEY`、専用の認証なしHTTPクライアント、JSON変換を実装する。Googleの `TRANSIT` と暗黙の徒歩切り替えを削除する。
- [x] 公開仕様どおりの探索条件を生成し、公共交通・徒歩以外を使用しない。実際の到着日時から待ち時間込みのLegを作る。エラーは503 `TRANSIT_UNAVAILABLE`、422 `ROUTE_NOT_FOUND`、502 `UPSTREAM_ERROR`、429 `RATE_LIMITED` に分ける。
- [x] 既存のルートテストfixtureをmixway形式へ変更し、作成・編集・コピー・提案・再計算が同じ接続先を使うことを確認する。
- [x] キー設定・実接続の準備・検証の限界をREADMEと環境変数例に記載する。

## Task 3: Flutterの入力・モデル・表示

**Files:** `app/lib/data/models/requests.dart`, `itinerary.dart`, 生成ファイル; `mock_itinerary_api.dart`; `features/plan/plan_screen.dart`, `features/today/today_screen.dart`, `features/replan/replan_screen.dart`, `features/itineraries/itinerary_groups.dart`, 関連文言とテスト。

**Interfaces:**
- `EndInput.date`、`ItineraryEnd.date` は `String?`。旧応答の欠落を受け付ける。
- `EndInput.fromEndpoint` は終了日を保持する。
- 終了日は作成・編集の入力で指定し、JSONの `end.date` に送る。
- 一覧の「今日」は開始日から実際の終了日までを含む。

- [x] モデルの旧JSON、新しい終了日、日付を含む入力検証、2日目の一覧、日数を保つコピー・モックのテストを追加して失敗を確認する。
- [x] 終了日の選択を追加し、日時で前後を比較する。編集時の復元と開始日変更時の日数維持を実装する。
- [x] モデル生成を実行する。生成ファイルの手編集はしない。
- [x] モック・表示・一覧を更新する。日が変わる箇所を表示し、1日限定の文言を直す。
- [x] `dart run build_runner build --delete-conflicting-outputs`、`flutter analyze`、`flutter test`、`flutter build web` を実行する。

## Task 4: 統合・レビュー

- [x] `go test ./...`, `go test -race ./...`, `go vet ./...` とWebビルドを確認する。
- [x] 旧レコードの編集、2日目の部分編集、終日営業と前日からの深夜営業、キー未設定、未来日の交通データなしを再確認する。
- [x] 全差分をレビューし、過剰な分割・抽象化・設定・説明的コメントを減らす。別のレビュアーにも全体を確認してもらう。
- [x] 検証した範囲と、実キーがないため確認できない実接続・デプロイを分けて報告する。
- [x] 変更を専用ブランチで確認できる状態に保つ。契約・課金・push・PR作成・デプロイは行わない。
