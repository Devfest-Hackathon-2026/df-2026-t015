# Iterinerary Go API

Go 1.26以上。API仕様（MVP、2026-11-06改訂版、F-01〜F-11）の #1〜#16 と `GET /healthz` を実装しています。

| # | メソッド・パス | 用途 |
|---|---|---|
| 1 | `GET /places/autocomplete` | 施設名の入力補完（F-01） |
| 2 | `POST /places/interpret` | 自由文から行き先候補（F-01、Gemini） |
| 3 | `POST /itineraries` | 旅程の生成（F-02） |
| 4 | `GET /me/itineraries` | 自分の旅程一覧（F-08） |
| 5 | `GET /itineraries/:id` | 旅程の取得（F-06） |
| 6 | `PUT /itineraries/:id/places` | 行き先・優先度・出発と終わり・旅行日の編集と再生成（F-01、F-02、F-09、F-10） |
| 7 | `POST /itineraries/:id/replans` | 遅延の組み直し案（F-03、F-04） |
| 8 | `GET /itineraries/:id/replans/:replanId/explanation` | 変更理由（F-05、Gemini） |
| 9 | `POST /itineraries/:id/replans/:replanId/accept` | 組み直し案の確定（F-04） |
| 10 | `GET /itineraries/:id/suggestions` | 空き時間の提案（F-07） |
| 11 | `POST /itineraries/:id/items` | 提案された予定の追加（F-07） |
| 12 | `GET /places/nearby` | 地図に表示する近くの施設（F-10） |
| 13 | `GET /places/:placeId` | 施設の詳しい情報とその日の営業時間（F-10） |
| 14 | `PATCH /itineraries/:id` | 旅程名の変更（F-09） |
| 15 | `DELETE /itineraries/:id` | 旅程の削除（F-09） |
| 16 | `POST /itineraries/:id/copy` | 旅程を別の日にコピー（F-11） |
| — | `GET /healthz` | ヘルスチェック（認証なし） |

## 接続先の準備

- Firebase Authenticationで匿名ログインを有効化する。
- Firestoreのデータベースを作り、サーバーの実行アカウントに必要な読み書き権限を付与する。
- Mapsの課金を設定し、Places API (New) と Routes API を有効化する。#12 は Places API の Nearby Search（名前で絞るときは Text Search）、#13 は Place Details を使います。
- Gemini APIキーと、そのプロジェクトで利用できるモデル名を用意する。

Firebase/Firestoreは公式Admin SDKとApplication Default Credentialsを使用します。ローカルでは `GOOGLE_APPLICATION_CREDENTIALS` に認証JSONの絶対パスを指定するか、ADCを設定してください。Cloud Runでは実行サービスアカウントを使用できます。

## 起動

`server` ディレクトリで実行します。

```sh
cp .env.example .env
# .env を実際の値に編集してから実行する
set -a
. ./.env
set +a
go run ./cmd/server
```

`.env` は起動プログラムが自動で読み込むものではなく、上記のシェルで環境変数として読み込みます。認証JSONやAPIキーをGitへ追加しないでください。

```sh
curl http://localhost:8080/healthz
curl -H "Authorization: Bearer $FIREBASE_ID_TOKEN" \
  'http://localhost:8080/places/autocomplete?q=東京駅'
```

`FIREBASE_ID_TOKEN` はクライアントのFirebase匿名ログイン後に取得したIDトークンです。APIキーやAdmin SDK用の認証JSONではありません。`/healthz` 以外は認証必須です。

## 実装の構成

- `cmd/server`: 設定の確認、起動、終了処理。
- `api`: ルート登録と各HTTPハンドラー。
- `internal/service`: 入力検証、外部API、旅程計算、Firestore保存。

AI（Gemini）の使い方は「サーバーが事実を計算し、AIは選択・順番・文章だけを担う」ことを基本にしています。プロンプトは `internal/service/gemini.go` の `Prompt`（タスク・ルール・入力データ）で組み立て、入力データは JSON のコードブロックに入れて指示と分けます。出力は JSON スキーマで縛り、施設IDは `enum` で入力の候補に限定します。スキーマに合わない応答は1回だけ再試行します。

| API | AI の役割 | サーバー側の工夫 |
|---|---|---|
| #2 interpret | 1回目で希望文を検索語に分ける。2回目で実在の候補から最大5件を選び、理由をつける | Places で実在を確認し、候補だけを enum で渡す。2回目が失敗したら検索語ごとの先頭の施設で返す |
| #3 作成 | 施設情報・その日の営業時間・直線距離表をもとに訪問順を返す | 最近傍法＋2-opt の基準の順番も作る。AI の順番は未知・重複を捨て、抜けを最小コスト挿入で補う。両方を実際の移動時間で組み、外した行き先・移動時間・到着時刻で良い方を採る |
| #6 編集 | 固定の予定・今の順番・変更点（追加・削除・優先度の変更）を見て、残りの順番を返す | 基準の順番は「変更のない施設は今の順番のまま、追加分を最小コストの位置に挿入」。部分的な変更にとどめる |
| #7 組み直し | 近くの代替施設も使った案を最大3つ返す（`label` つき） | AI なしの案（順番そのままで時刻をずらす、優先度の低い予定を1つ外す）も作り、すべて返す（AI の案は最大3案、アルゴリズムの案と合わせて最大5案）。各案に `source`（algorithm / ai）と `label` をつける。結果が同じ案はまとめる。AI が失敗してもアルゴリズムの案は返す |
| #8 理由文 | サーバーが取り出した事実（時刻のずれ、延びた滞在、外れた理由、警告）を、要約 `text` と変更ごとの `reasons` にする | 理由の itemId は案の changes に限定し、種類（replace など）はサーバーの値を使う |
| #10 空き時間 | 前後の移動を除いた「滞在に使える時間」を見て施設を選び、滞在時間と理由をつける。施設を決めない過ごし方 `ideas` も返す | Nearby Search の候補ごとに前後の移動時間を Routes で求め、使える時間が15分未満の候補と営業時間外の候補を先に除く。AI の滞在時間は使える時間に収める |


`If-Match` は取得時の `ETag` の値を送ってください。更新時はFirestoreトランザクションで所有者とversionを確認します。別の利用者の旅程・案は404、古いversionは409、期限切れの案は410です。認証済み利用者ごとに1分120リクエストまで受け付けます。

## Firestore

使用するコレクションは `itineraries`、`replans`、`rateLimits` です。いずれもサーバーからのみアクセスします。`firestore.rules` はクライアントの直接アクセスを拒否する設定例です。Admin SDKのアクセスにはIAM権限が別途必要です。

`firestore.indexes.json` は旅程本体・案本体を検索インデックスから除外し、3コレクションの `expiresAt` をTTL対象にする設定例です。旅程は旅行日から30日、案は15分、レート制限カウンターは2分で期限を設定します。クラウド側への設定反映は別途必要です。この実装では設定のデプロイは行いません。

一覧（`GET /me/itineraries`）は `ownerUid` の等価検索と `date` の降順で `limit` 件ずつ取得するため、`firestore.indexes.json` の複合インデックス（ownerUid ↑, date ↓, __name__ ↓）が必要です。続きは応答の `nextCursor` を `cursor` に送って取得します。TTLの実削除は遅れるため、API側でも有効期限を検証し、期限切れの旅程は一覧から除きます（そのため1ページの件数が `limit` より少ないことがあります）。

1人が保存できる旅程は期限内のもので20件までです。作成時にトランザクション内で件数を確認し、超える場合は422 `ITINERARY_LIMIT` を返します。

## 最初の実装での扱い

- 日本時間・同日内の旅程を扱います。訪問順の最適解を保証するソルバーは含めていません。
- 出発地（`start`）と終わる場所（`end`）は `placeId`、または地図で選んだ地点の `location` と `name` で指定します。終わる場所への移動も最後の Leg（`toItemId: "end"`）として計算し、終わりの判定は終わる場所に着く時刻（`end.arriveAt`、`summary.endAt`）で行います。
- 必須の予定が入りきらない場合は422 `MUST_ITEMS_INFEASIBLE`、行き先をすべて外しても終わる場所に `end.arriveBy` までに着けない場合は422 `END_INFEASIBLE` です。
- `GET /places/:placeId` の営業時間は、`date` が今日から7日以内なら Places の `currentOpeningHours`（臨時営業・臨時休業を含む）、それ以降は通常営業時間で判定します。`currentOpeningHours.periods` が空配列なら臨時休業として `null` を返します。営業区間は「その日に重なるか」で判定し、前日から続く深夜営業は `opensAt: "00:00"` として含めます。区間が複数ある日は、その日の最初に開いている時刻と最後に閉まる時刻を返します。料金は Places の `priceRange`（円）がある施設だけ `kind: estimate` で返します。
- 旅程名 `title` は、作成（`POST /itineraries`）・名前の変更（`PATCH /itineraries/:id`）・コピー（`POST /itineraries/:id/copy`）のすべてで1〜100文字です。仕様の #14 は1〜50文字ですが、作成時の上限（100文字）と揃えないと、51文字以上の旅程名をそのままコピー・再保存できなくなるため100文字に統一しています。
- `DELETE /itineraries/:id` は旅程とその組み直し案を1つのトランザクションで削除し、204を返します。
- `POST /itineraries/:id/copy` は元の訪問順・優先度・滞在時間・出発と終わりを引き継ぎ、新しい日付の営業時間と時刻表で組み直します（AIは使いません）。完了済みの状態は引き継がず、入りきらない行き先は `dropped` に入ります。
- `PUT /itineraries/:id/places` は `date`・`start`・`end` を省略すると今の値のままです。`date` を変えると、完了済み・滞在中の予定も含めて旅程全体を作り直します。同じ日のまま旅程の開始後に出発地・出発時刻を変えることはできません（400）。
- Mapsの通常営業時間に基づいて検証します。営業時間が取得できない施設は `openingHours: null`、不明な料金は `amount: null, kind: unknown` とします。祝日などの臨時営業や入場料金の自動取得は含めていません。
- 料金合計は金額が分かる予定だけを合計し、不明・目安を含む場合は `hasEstimate: true` とします。移動料金の取得は含めていません。
- 移動はMapsの徒歩と公共交通のうち短い経路を使います。公共交通の検索可能期間（過去7日〜未来100日）の外では徒歩のみを使います。タクシーの自動選択は含めていません。
- 空き時間の提案は既存予定と重ならず、次の予定（最後の予定の後なら終わる場所）への移動も時間内に収まる候補だけを返します。最初の予定より前に追加する場合、`insertAfterItemId` は `start` を指定します。省略すると最後の予定の後ろに追加します。
- 遅延時の `now` は現在の予定の終了予定時刻との差から遅延を計算します。完了済みの予定と現在の予定を保持し、これからの予定だけを組み直します。
- 待ち時間で吸収できる遅延や最後の予定の遅延も、現在の終了時刻を保存するため時刻調整だけの案を返します。確定APIを呼ぶまでは元の旅程は変更しません。終わる場所に `end.arriveBy` までに着けなくなる場合は `end_at_risk` を警告します。
- 開始後の行き先編集は、完了済み・滞在中の予定を変更せずに全件送ってください。これらの予定の削除・優先度変更・滞在時間変更は400で拒否し、残りの予定だけをAIで再生成します。
- 理由文は初回のGETで生成・保存します。同時生成中は `pending`、完了後は `ready`、失敗時は `failed` を返します。理由文が失敗しても案の確定はできます。
- APIリクエスト全体の上限は60秒、外部HTTP呼び出しは各15秒です。実サービスの遅延と課金額は未測定です。

## テスト

```sh
go test ./...
go test -race ./...
go vet ./...
go build -o /tmp/iterinerary-api ./cmd/server
```

通常のテストでは認証・保存先・Maps/GeminiのHTTP応答を差し替えるため、有料サービスへアクセスしません。実接続には有効な設定とFirebase IDトークンが必要です。`FIRESTORE_EMULATOR_HOST` が設定されている場合は、`demo-iterinerary` プロジェクトのエミュレーター内で保存・同時更新・理由文の処理権・案の確定も検証します。

接続仕様の参照: [Firebase IDトークンの検証](https://firebase.google.com/docs/auth/admin/verify-id-tokens)、[Places Autocomplete](https://developers.google.com/maps/documentation/places/web-service/place-autocomplete)、[Routes](https://developers.google.com/maps/documentation/routes/transit-route)、[Geminiの構造化出力](https://ai.google.dev/gemini-api/docs/structured-output)。
