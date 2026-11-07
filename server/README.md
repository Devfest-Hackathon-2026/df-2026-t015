# Iterinerary Go API

Go 1.26以上。API仕様（MVP、2026-11-06改訂版、F-01〜F-11）のうち、#1〜#11 と `GET /healthz` を実装しています。#10 は `GET /itineraries/:id/suggestions` です。#12〜#16（地図の施設、施設の詳細、旅程名の変更・削除・コピー）は未実装です。

## 接続先の準備

- Firebase Authenticationで匿名ログインを有効化する。
- Firestoreのデータベースを作り、サーバーの実行アカウントに必要な読み書き権限を付与する。
- Mapsの課金を設定し、Places API (New) と Routes API を有効化する。
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

AIを使うのは自由文の候補生成、旅程生成、編集後の再生成、遅延時の組み直し、空き時間の候補選択、変更理由の生成です。AIが返した施設IDは入力またはMapsで取得した候補と照合し、移動時間と営業時間はサーバーで検証します。

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
