# Go API 実装案

## 目的

コメントだけの12エンドポイントを、Flutterから呼び出せるGoのAPIにする。
Firebase・Maps・Geminiに実際に接続する方式は利用者が選択済み。
元のAPI仕様を基本とし、利用者の追加方針により #2・#3・#6・#7・#10 と #8 の理由文でAIを使う。
#10 のメソッドは元の仕様どおり GET とする。

## 方式の比較

- 実サービス接続（選択済み）: 本番と同じ認証・施設検索・AIを使える。実接続にはプロジェクトとキーの設定が必要。
- 外部接続を後回しにする方式: すぐ起動できるが、認証・施設の実在・AIの振る舞いを確認できない。

## 構成

- Go標準の net/http でルーティングする。既存の api/places、api/itineraries、api/me の配置を使う。
- server/go.mod と起動用コマンドを追加し、PORT（既定8080）で待ち受ける。
- 共通のデータ型、JSON処理、外部接続、保存、旅程計算は server/internal に置く。
- Firebase認証とFirestoreには公式Go SDKを使う。MapsとGeminiは標準のHTTPクライアントでREST APIを呼ぶ。
- 起動時に Firebase のプロジェクトID、Maps APIキー、Gemini APIキーとモデル名を確認する。
- Firebase/Firestoreの認証には Application Default Credentials を使う。キーや認証JSONはコミットしない。

## APIの処理

1. GET /places/autocomplete: 必須の q と任意の緯度経度を検証し、Places Autocompleteの実在候補を返す。
2. POST /places/interpret: Geminiで希望を検索語にし、Placesで施設を検索・確認して最大5件を返す。
3. POST /itineraries: 施設情報をPlacesで取得し、Geminiに訪問順を提案させる。サーバーで移動時間・営業時間・滞在時間を確認し、旅程を保存する。
4. GET /me/itineraries: 本人の旅程だけを旅行日の降順で返す。
5. GET /itineraries/:id: 本人の旅程を返し、versionをETagに入れる。
6. PUT /itineraries/:id/places: Geminiの提案とサーバーの検証で再生成し、If-Matchを照合して保存する。
7. POST /itineraries/:id/replans: 過去・完了済み予定を保持し、遅延後の残りの旅程をAIで組み直す。最大3案と変更差分を15分保存する。
8. GET /itineraries/:id/replans/:replanId/explanation: 案の根拠からGeminiで理由文を生成し、ready/failedを保存する。
9. POST /itineraries/:id/replans/:replanId/accept: 所有者・期限・basedOnVersionを確認し、選択した案を旅程へ反映する。
10. GET /itineraries/:id/suggestions: 空き時間と近隣の実在施設をもとにGeminiで候補を選び、前後の移動時間と営業時間を検証して返す。
11. POST /itineraries/:id/items: 選択施設を指定位置へ追加し、時刻を再計算してIf-Matchを照合して保存する。
12. GET /healthz: 認証なしで200とstatus=okを返す。

## AIと旅程の境界

- AIの返答はJSONとして読み、未知の施設ID、重複、欠落、不正な優先度や時刻を受け入れない。
- 実在する施設、移動時間、営業時間はMapsの結果を使う。AIの作った施設や移動時間をそのまま保存しない。
- 料金が確認できない施設は amount=null、kind=unknown とし、確定値を捏造しない。
- 候補の提案順はAIに任せ、最終的な開始終了時刻・集計・必須予定の成立はサーバーで確認する。
- 生成・編集で必須の予定が成立しない場合は422。組み直しではmust_at_riskを警告し、利用者が選べる案を返す。
- 日時の計算は日本時間、同日内の旅程とする。Mapsの営業時間が不明なときは確認済みと扱わず、openingHours=nullを返す。

## 認証と整合性

- /healthz以外はFirebase Admin SDKでBearerのIDトークンを検証する。認証を飛ばす開発モードは作らない。
- ownerUidが異なる旅程・案は404。JSONにownerUidや秘密情報を含めない。
- 変更時はFirestoreのトランザクション内で所有者とversionを再確認し、versionを1増やす。AI・Maps呼び出しはトランザクション外で行う。
- 再生成時に重複更新があれば409。期限切れの案は、Firestore TTLによる実削除を待たず410にする。
- リクエストサイズを制限し、未知のJSON項目や複数のJSON値、不正な日時、範囲外の値を400にする。
- 共通エラーJSONを統一する。外部のエラー本文やトークンは返さない。上流の429はRATE_LIMITEDにする。
- 認証済みuidごとの呼び出し制限を設ける。複数インスタンスでも共有できるようFirestoreのトランザクションでカウントする。

## 保存と理由文

- itinerariesに所有者・version・旅行日・updatedAt・expiresAtと旅程本体を保存する。
- replansには旅程ID・所有者・basedOnVersion・案・期限・理由文の状態を保存する。
- 旅程の期限は旅行日から30日、案の期限は15分。TTL用のexpiresAtはFirestore Timestampで持つ。
- 最初の実装では理由文を #8 の初回取得時に生成する。生成中の同時リクエストにはpendingを返し、完了後はキャッシュを返す。
- 理由文の生成には期限付きの処理権を保存し、プロセス停止後も再試行できるようにする。失敗時はfailedとし、案の確定は妨げない。
- リクエスト終了後のgoroutineに外部処理を任せない。Cloud Tasksなどのジョブ基盤は今回追加しない。

## 検証

- httptestで認証必須・入力検証・所有者保護・共通エラー・ルーティングを確認する。
- Maps/Geminiはテスト用HTTP応答で、成功、不正JSON、未知のID、429、タイムアウトを検証する。
- 時間計算、必須予定、営業時間、バージョン競合、期限切れ、現在の予定を含む組み直しをテストする。
- Firestoreの保存・トランザクションはエミュレーターが使える場合に確認する。
- go test ./...、go test -race ./...、go vet ./... とビルドを実行する。
- 実際のFirebaseトークンやキーが未設定なら、有料サービスへの実接続テストは未実施として明記する。

## 今回の対象外と実装者の判断

- Flutter画面、デプロイ、クラウド側のAPI有効化・課金・権限変更、実データ投入、push・PR作成は行わない。
- Firestoreのルール・TTL・必要なインデックス設定と、環境変数・起動手順はREADMEに記載する。
- 適切なタイムアウト、モデル名の設定方法、Mapsの移動モード選択、ファイル分割は実装時に最小構成で決める。
- 訪問順の最適解を保証する最適化ソルバーは追加しない。成立を検証できた案だけを返す。

## 2026-11-06 の仕様改訂への対応（b_modify-api）

API仕様が「複数の旅程、出発と終わり、地図からの選択」をテーマに改訂された（F-01〜F-11）。既存の #1〜#11 を次のように合わせる。#12〜#16 の追加は別ブランチで行う。

- 共通: `endBy` を廃止し、`end`（placeId | null、name、location、arriveBy、arriveAt）を追加。`start` も placeId の代わりに location と name で指定できる。終わる場所への移動を最後の Leg（toItemId: "end"）として計算し、`summary.endAt` は終わる場所に着く時刻にする。
- エラー: 422 `END_INFEASIBLE`（行き先を外しても終わる場所に間に合わない）、422 `ITINERARY_LIMIT`（1人20件）を追加。
- #3: 上記の入力を受け付け、作成前と保存時のトランザクション内で件数の上限を確認する。
- #4: `limit`（1〜50、既定20）と `cursor` でページング。各旅程に start・end・placeCount・placeNames・expiresAt を返す。ownerUid + date の複合インデックスを使う。
- #6: `date`・`start`・`end` を任意で受け付ける。date を変えたら旅程全体を作り直す。
- #7: 終わる場所に間に合わない案には `end_at_risk` を警告する（`end_time_exceeded` は廃止）。遅延で出発が遅れる移動の時刻もずらす。
- #10・#11: 最後の予定の後は終わる場所までの移動を含めて判定する。#11 の insertAfterItemId は省略すると末尾に追加する。

## 改訂で追加された API（b_update-api）

- #12 GET /places/nearby: lat・lng（必須）、radius（100〜5000m、既定1000）、q（任意）。q がなければ Places Nearby Search、あれば Text Search を使い、範囲外を除いて最大20件。typeLabel は Places の primaryTypeDisplayName。
- #13 GET /places/:placeId: date（任意、既定は今日）の営業時間を返す。直近7日は currentOpeningHours、それ以降は regularOpeningHours。料金は priceRange（円）があるときだけ estimate。
- #14 PATCH /itineraries/:id: title（1〜100文字。仕様は1〜50文字だが、#3・#16 と揃えて100文字に統一）。If-Match 必須。
- #15 DELETE /itineraries/:id: If-Match 必須。旅程と組み直し案を同じトランザクションで削除し、204。
- #16 POST /itineraries/:id/copy: date 必須、title 任意。元の訪問順で新しい日付の営業時間・時刻表に組み直す。上限超過は 422 ITINERARY_LIMIT。
- ルーターはパスごとに1つのハンドラーを登録し、その中でメソッドを振り分ける（`GET /places/{placeId}` とほかの `/places/*` の衝突を避けるため）。

## Gemini 連携の作り込み（b_ai-inference）

- 共通: プロンプトを「タスク・ルール・入力データ（JSON）」の形で組み立てる。施設IDは JSON スキーマの enum で入力の候補に限定し、スキーマに合わない応答は1回だけ再試行する。構造化（順番・選択）は temperature 0.2、文章は 0.4〜0.5。
- #2: 検索語への分解 → Places で実在確認 → 候補から最大5件を選ぶ、の2段階。応答は {place, reason} だけ。
- #3: 基準の順番（最近傍法＋2-opt）と AI の順番を両方組み、外した行き先（優先度で重み付け）・移動時間・到着時刻で比べる。AI の順番は正規化してから使う。
- #6: 固定の予定は変えず、変更のない施設の相対順を保った基準の順番と、変更点を渡した AI の順番を比べる。
- #7: アルゴリズムの案（時刻をずらす／優先度の低い予定を外す）と AI の案（代替施設を使う）をすべて返す。「最大3案」は AI の案の上限とし、アルゴリズムの案（最大2案）と合わせて最大5案を返す（利用者確認済み）。各案に source と label を追加。
- #8: 変更点から事実を取り出し、AI は要約と変更ごとの理由の文章だけを作る。応答に reasons を追加。
- #10: 前後の移動時間を除いた滞在可能時間で候補を絞り、施設の提案に加えて ideas（施設を決めない過ごし方）を返す。各提案に typeLabel と legToNext を追加。
