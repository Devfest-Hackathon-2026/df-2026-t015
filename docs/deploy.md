# 公開手順書（Cloud Run + Firebase Hosting）

Iterinerary を本番に公開するための手順と、アプリ・API サーバー・Google のサービスがどうつながるかをまとめた資料です。
対象は `back` ブランチ（Flutter アプリ・Go の API サーバー・公開用の設定がすべて入っているブランチ）です。

- Firebase プロジェクト：`gen-tle-f502c`（リポジトリ直下の `.firebaserc`）
- 公開 URL：`https://gen-tle-f502c.web.app`（アプリ）、`https://gen-tle-f502c.web.app/api/...`（API）
- Cloud Run のサービス：`iterinerary-api`（リージョン `asia-northeast1`）

以下のコマンドの `<PROJECT_ID>` は `gen-tle-f502c` に読み替えてください。

---

## 1. 全体の構成

```
                    ┌──────────────── Firebase Hosting（https://<PROJECT_ID>.web.app）──────────────┐
ブラウザ ─────────▶ │ /            → app/build/web（Flutter Web）                                      │
（Flutter Web）     │ /api/**      → rewrite → Cloud Run「iterinerary-api」（asia-northeast1）          │
                    └──────────────────────────────────────────┬────────────────────────────────────┘
  │                                                            │ /api/places/... のまま転送
  │ ① 匿名ログイン                                              ▼
  ▼                                               ┌──────── Cloud Run（server/）────────┐
Firebase Authentication ─ ID トークン ───────────▶ │ API_BASE_PATH=/api で /api を外す   │
                                                  │ Authorization: Bearer <ID トークン> │
                                                  │   → Admin SDK で検証（uid を取得）  │
                                                  └──┬─────────────┬─────────────┬──────┘
                                                     ▼             ▼             ▼
                                                 Firestore    Places API (New)   Gemini
                                              （旅程・案・    Routes API      （API キー：AI Studio
                                               レート制限）   （Maps）          ADC：Vertex AI）
```

ポイント：

- アプリと API は**同じドメイン**（`<PROJECT_ID>.web.app`）で動くので、本番では CORS の設定は要りません。
- Firebase Hosting は `/api/places/autocomplete` を**そのままのパスで** Cloud Run に転送します。サーバーは `API_BASE_PATH=/api` を見て `/api` を外してからルーティングします（`server/api/public.go`）。`/api` の付かないリクエスト（Cloud Run の URL を直接呼ぶ場合）もそのまま受け付けます。
- Cloud Run は `--allow-unauthenticated` で公開します。利用者の確認は Cloud Run の IAM ではなく、**サーバーが Firebase の ID トークンを検証して**行います（`/healthz` 以外はすべて認証が必要です）。
- Firestore にはサーバーだけがアクセスします（`server/firestore.rules` でクライアントからの直接アクセスはすべて拒否します）。

## 2. API 連携の詳細

### 2.1 アプリ → API サーバー

| 項目 | 内容 | 場所 |
|---|---|---|
| 接続先 | `--dart-define=API_BASE_URL=...`（既定は `http://localhost:8080`） | `app/lib/config/app_config.dart` |
| モックとの切り替え | `--dart-define=USE_MOCK_API=false` で本物の API を使う。**既定は `true`（モック）**なので、本番ビルドでは必ず指定する | 同上 |
| HTTP クライアント | Dio。`baseUrl` に `API_BASE_URL` を入れ、各 API は `/itineraries` のようなパスで呼ぶ | `app/lib/data/api/http_itinerary_api.dart` |
| 認証 | 毎回のリクエストに `Authorization: Bearer <Firebase ID トークン>` を付ける。未ログインなら匿名ログインしてから取得する | `app/lib/data/auth/auth_repository.dart` |
| 楽観的ロック | 更新系（PUT / PATCH / DELETE など）は `If-Match: <version>` を送る。サーバーは `ETag: "<version>"` を返し、`"3"` と `3` のどちらでも受け付ける | `server/internal/service/http.go` |
| タイムアウト | 接続 10 秒、受信 15 秒 | `http_itinerary_api.dart` |
| Firebase の初期化 | `USE_MOCK_API=false` のときだけ `Firebase.initializeApp` を呼ぶ。設定は `lib/firebase_options.dart` | `app/lib/main.dart` |

### 2.2 API サーバーの環境変数

| 変数 | 必須 | 本番（Cloud Run）での値 | 説明 |
|---|---|---|---|
| `FIREBASE_PROJECT_ID` | ○ | `<PROJECT_ID>` | ID トークンの検証、Firestore、Vertex AI / Maps の課金先 |
| `GEMINI_MODEL` | ○ | 使うモデル名 | 未設定だと起動しない |
| `GEMINI_API_KEY` | △ | Secret Manager から渡す | 空なら ADC で Vertex AI を呼ぶ |
| `GOOGLE_MAPS_API_KEY` | △ | Secret Manager から渡す | 空なら ADC で Places / Routes を呼ぶ |
| `GOOGLE_CLOUD_LOCATION` | － | `global`（既定） | Vertex AI を使うときのリージョン |
| `API_BASE_PATH` | ○（Hosting 経由） | `/api` | Hosting の rewrite の前置きを外す |
| `CORS_ALLOWED_ORIGINS` | － | 空 | 本番は同じドメインなので不要。開発で別オリジンから呼ぶときだけ |
| `PORT` | － | Cloud Run が自動で設定 | 既定 8080 |
| `GOOGLE_APPLICATION_CREDENTIALS` | － | **設定しない** | ローカル専用。Cloud Run は実行サービスアカウントを使う |

ローカルでは `server/.env` を起動時に自動で読み込みます（`server/cmd/server/main.go` の `loadDotEnv`）。すでに設定されている環境変数が優先されます。`.env` は `.dockerignore` でイメージから外しているので、Cloud Run には入りません。

### 2.3 API サーバー → Google のサービス

| 連携先 | 使う API | 認証（キーあり） | 認証（キーなし＝ADC） |
|---|---|---|---|
| Firebase Authentication | ID トークンの検証（Admin SDK） | 不要（公開鍵で検証） | 同左 |
| Firestore | `itineraries` / `replans` / `rateLimits` コレクション | 実行サービスアカウント | 同左 |
| Places API (New) | autocomplete / searchText / searchNearby / Place Details | `X-Goog-Api-Key` | OAuth トークン + `X-Goog-User-Project` |
| Routes API | `directions/v2:computeRoutes`（徒歩・車・公共交通） | `X-Goog-Api-Key` | OAuth トークン + `X-Goog-User-Project` |
| Gemini | キーあり：`generativelanguage.googleapis.com`（AI Studio） | `x-goog-api-key` | Vertex AI：`aiplatform.googleapis.com` |

起動時のログに `Gemini: ... / Maps: ...` と、どちらの方式で呼ぶかが出ます。デプロイ後はまずこのログを確認してください。

経路は Google の Routes API だけで求めます（`server/internal/service/routes.go`）。区間ごとに徒歩・車・公共交通の3つを**並行して**問い合わせ、次の順に選びます。

1. 徒歩が20分以内 → 徒歩（`walk`）
2. 公共交通の結果がある → 電車（`train`）またはバス（`bus`）。路線名つき
3. 車の結果がある → 車（`taxi`。アプリでは「タクシー」と表示）
4. 車もない → 徒歩

Routes API は日本の公共交通をほとんど返さないため、国内では20分を超える区間はほぼ車になります。追加の外部サービスやキーは要りません。

### 2.4 タイムアウトと上限

| 項目 | 値 |
|---|---|
| Firebase Hosting → Cloud Run の転送 | 60 秒で打ち切り |
| サーバー側の 1 リクエスト全体 | 60 秒 |
| サーバー → 外部 API（1 回ごと） | 15 秒 |
| アプリの受信タイムアウト | 15 秒（※ 下の「既知の注意点」を参照） |
| レート制限 | 認証済みの利用者ごとに 1 分 120 リクエスト |
| 旅程の保存数 | 1 人 20 件まで（超えると 422 `ITINERARY_LIMIT`） |

---

## 3. 事前準備（最初の 1 回だけ）

### 3.1 ツール

- Google Cloud CLI（`gcloud`）
- Firebase CLI（`npm i -g firebase-tools`）
- Flutter 3.47.0（CI の `.github/workflows/app.yml` と揃える）
- FlutterFire CLI（`dart pub global activate flutterfire_cli`）
- Go 1.26 以上（ローカルでテストするとき）

```sh
gcloud auth login
gcloud config set project <PROJECT_ID>
firebase login
```

### 3.2 Google Cloud の API を有効にする

```sh
gcloud services enable \
  run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com \
  secretmanager.googleapis.com firestore.googleapis.com \
  places.googleapis.com routes.googleapis.com \
  aiplatform.googleapis.com
```

- `run` / `cloudbuild` / `artifactregistry`：`gcloud run deploy --source` でイメージを作るために必要です。
- `aiplatform` は Gemini を ADC（Vertex AI）で呼ぶときだけ必要です。
- Maps（Places / Routes）を使うには、プロジェクトに**課金アカウント**が必要です。

### 3.3 Firebase の設定（コンソール）

1. **Authentication** → ログイン方法 → **匿名**を有効にする。
2. **Authentication** → 設定 → 承認済みドメインに `<PROJECT_ID>.web.app` と `<PROJECT_ID>.firebaseapp.com` が入っていることを確認する（最初から入っています。独自ドメインを使うときは追加）。
3. **Firestore Database** を作る。
   - データベース ID は `(default)`（サーバーは既定のデータベースを使います）。
   - モードは**ネイティブ**、ロケーションは `asia-northeast1` を推奨（Cloud Run と同じ地域）。
   - ロケーションは後から変えられません。
4. **Hosting** を有効にする（`firebase deploy` を初めて実行すると作られます）。

### 3.4 API キーを用意する（キーを使う場合）

組織のポリシーで API キーを作れない場合は、この節を飛ばして ADC で動かします（3.5 のロールを付ければ動きます）。

- **Maps**：Google Cloud コンソール → 「API とサービス」→「認証情報」でキーを作ります。
  - API の制限：**Places API (New)** と **Routes API** だけにする。
  - アプリケーションの制限：サーバーから呼ぶので、HTTP リファラーの制限は付けない。
- **Gemini**：Google AI Studio でキーを作ります。使えるモデル名は次のコマンドで確認し、`GEMINI_MODEL` に入れます。

```sh
curl -s -H "x-goog-api-key: $GEMINI_API_KEY" \
  https://generativelanguage.googleapis.com/v1beta/models | grep '"name"'
```

`models/` を除いた部分（例：`models/xxxx` なら `xxxx`）が `GEMINI_MODEL` の値です。

キーは Secret Manager に入れます（シェルの履歴に残さないよう、`read -s` で入力します）。

```sh
read -s GEMINI_API_KEY && printf '%s' "$GEMINI_API_KEY" | gcloud secrets create gemini-api-key --data-file=-
read -s MAPS_API_KEY  && printf '%s' "$MAPS_API_KEY"  | gcloud secrets create maps-api-key  --data-file=-
```

キーを変えるときは `gcloud secrets versions add gemini-api-key --data-file=-` で新しい版を足し、Cloud Run を再デプロイ（または新しいリビジョンを作成）します。

### 3.5 Cloud Run の実行サービスアカウント

```sh
gcloud iam service-accounts create iterinerary-api --display-name="Iterinerary API"
SA=iterinerary-api@<PROJECT_ID>.iam.gserviceaccount.com

# Firestore の読み書き（必須）
gcloud projects add-iam-policy-binding <PROJECT_ID> --member="serviceAccount:$SA" --role=roles/datastore.user

# API キーを Secret Manager から読む（キーを使う場合）
gcloud secrets add-iam-policy-binding gemini-api-key --member="serviceAccount:$SA" --role=roles/secretmanager.secretAccessor
gcloud secrets add-iam-policy-binding maps-api-key  --member="serviceAccount:$SA" --role=roles/secretmanager.secretAccessor

# ADC で Gemini（Vertex AI）と Maps を呼ぶ場合
gcloud projects add-iam-policy-binding <PROJECT_ID> --member="serviceAccount:$SA" --role=roles/aiplatform.user
gcloud projects add-iam-policy-binding <PROJECT_ID> --member="serviceAccount:$SA" --role=roles/serviceusage.serviceUsageConsumer
```

`gcloud run deploy --source` を初めて実行したときに Cloud Build の権限エラーが出た場合は、ビルドに使うサービスアカウント（既定は Compute Engine のデフォルト サービスアカウント）に `roles/run.builder` を付けてください。

---

## 4. 公開の手順

順番が大事です。**Hosting の rewrite 先の Cloud Run サービスが先に存在している必要がある**ため、API サーバー → アプリの順に出します。

### 4.0 公開前のチェック（`back` ブランチで）

```sh
git switch back && git pull
cd server && go vet ./... && go test ./... && cd ..
cd app && flutter pub get && bash tool/check_conventions.sh && flutter analyze && flutter test && cd ..
```

### 4.1 API サーバーを Cloud Run に出す

リポジトリ直下で実行します。`server/Dockerfile` を使って Cloud Build がイメージを作ります。

**API キーを使う場合**

```sh
gcloud run deploy iterinerary-api \
  --source server \
  --region asia-northeast1 \
  --service-account iterinerary-api@<PROJECT_ID>.iam.gserviceaccount.com \
  --allow-unauthenticated \
  --set-env-vars FIREBASE_PROJECT_ID=<PROJECT_ID>,GEMINI_MODEL=<モデル名>,API_BASE_PATH=/api \
  --set-secrets GEMINI_API_KEY=gemini-api-key:latest,GOOGLE_MAPS_API_KEY=maps-api-key:latest
```

**ADC で動かす場合（キーなし）**

```sh
gcloud run deploy iterinerary-api \
  --source server \
  --region asia-northeast1 \
  --service-account iterinerary-api@<PROJECT_ID>.iam.gserviceaccount.com \
  --allow-unauthenticated \
  --set-env-vars FIREBASE_PROJECT_ID=<PROJECT_ID>,GEMINI_MODEL=<モデル名>,API_BASE_PATH=/api,GOOGLE_CLOUD_LOCATION=global
```

- サービス名 `iterinerary-api` とリージョン `asia-northeast1` は、リポジトリ直下の `firebase.json` の rewrite と**一致させてください**。変える場合は `firebase.json` も変えます。
- 必要に応じて `--max-instances`（費用の上限）、`--min-instances 1`（コールドスタート対策。常に課金されます）を足します。

### 4.2 API サーバーを確認する

```sh
URL=$(gcloud run services describe iterinerary-api --region asia-northeast1 --format='value(status.url)')
curl -i "$URL/me/itineraries"                  # JSON の 401 が返れば起動している
gcloud run services logs read iterinerary-api --region asia-northeast1 --limit 20
```

ログはコンソールの Cloud Run →「iterinerary-api」→「ログ」でも見られます。

`*.run.app` の URL では `/healthz` のように `z` で終わる一部のパスが Google 側で予約されていて、コンテナに届かず Google の HTML の 404 が返ります。起動の確認には、上のように認証が必要な API を使い、**JSON の 401** が返ることを確かめてください。

ログに `Gemini: ... / Maps: ...` と `API listening on :8080` が出ていれば正常です。`FIREBASE_PROJECT_ID を設定してください` などが出ていたら、環境変数を見直します。

認証の必要な API も試します。Firebase の Web API キー（コンソールの「プロジェクトの設定」→「全般」。公開されてよい値です）を使い、匿名ユーザーの ID トークンを取得します。

```sh
WEB_API_KEY=<Firebase の Web API キー>
TOKEN=$(curl -s "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$WEB_API_KEY" \
  -H 'Content-Type: application/json' -d '{"returnSecureToken":true}' | sed -n 's/.*"idToken": *"\([^"]*\)".*/\1/p')
curl -s --get -H "Authorization: Bearer $TOKEN" --data-urlencode "q=東京駅" "$URL/places/autocomplete"   # Places との連携
curl -s -H "Authorization: Bearer $TOKEN" "$URL/me/itineraries"                 # Firestore との連携
```

日本語をクエリに入れるときは、上のように `--data-urlencode` を使います。URL にそのまま書くと、Google のフロントエンドが HTML の 400 を返します。

Routes API が使えるかは、自分のアカウントで直接確かめられます（`DRIVE` を `WALK` に変えると徒歩）。

```sh
curl -s -X POST https://routes.googleapis.com/directions/v2:computeRoutes \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "X-Goog-User-Project: <PROJECT_ID>" \
  -H "X-Goog-FieldMask: routes.duration" -H "Content-Type: application/json" \
  -d '{"origin":{"address":"東京駅"},"destination":{"address":"新大阪駅"},"travelMode":"DRIVE","languageCode":"ja"}'
```

`{"routes":[{"duration":"..."}]}` が返れば使えます。

- `401`：トークンが無い・期限切れ、または `FIREBASE_PROJECT_ID` がトークンのプロジェクトと違う。
- `502 UPSTREAM_ERROR`：外部サービス（Maps・Gemini）か Firestore の呼び出しに失敗した。**今のサーバーはエラーの詳細をログに出さず、すべてこのコードにまとめます**。次の順に切り分けてください。
  - `/places/autocomplete` だけ失敗する → Maps（Places API の有効化、キーの API 制限、ADC なら `roles/serviceusage.serviceUsageConsumer`）
  - 旅程の作成（`POST /itineraries`）だけ失敗する → Routes（Routes API の有効化、キーの API 制限、ADC なら `roles/serviceusage.serviceUsageConsumer`）
  - `/me/itineraries` だけ失敗する → Firestore（データベースの作成、`roles/datastore.user`、4.4 の複合インデックスが「有効」になっているか）
  - `POST /places/interpret` だけ失敗する → Gemini（`GEMINI_MODEL` のモデル名、キー、ADC なら `roles/aiplatform.user` と `GOOGLE_CLOUD_LOCATION`）
  - キーが原因か調べるときは、同じキーで Google の API を直接 `curl` で呼ぶと、エラーの理由が返ってきます。
- `422 ROUTE_NOT_FOUND`：Routes API が徒歩・車・公共交通のどれでも経路を返さなかった（離島など）。
- `429 RATE_LIMITED`：1 分 120 リクエストの上限か、外部サービスの割り当ての上限。

### 4.3 Flutter Web をビルドする

```sh
cd app
flutterfire configure --project=<PROJECT_ID> --platforms=web   # lib/firebase_options.dart を生成
flutter pub get
flutter build web --release \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=https://<PROJECT_ID>.web.app/api
cd ..
```

- 今のリポジトリの `app/lib/firebase_options.dart` は**仮のファイル**で、このままだと `USE_MOCK_API=false` のアプリは起動時にエラーになります。生成したファイルはコミットしておくと、誰がビルドしても同じになります（Web の Firebase 設定は秘密情報ではありません）。
- `USE_MOCK_API=false` を付け忘れると、サンプルデータで動くモック版が公開されます。
- 独自ドメインを使う場合は、`API_BASE_URL` をそのドメインの `/api` にします。

### 4.4 Hosting と Firestore の設定を反映する

リポジトリ直下（`firebase.json` のある場所）で実行します。

```sh
firebase deploy --only hosting,firestore
```

- `hosting`：`app/build/web` を配信し、`/api/**` を Cloud Run に転送します。`index.html` と `flutter_service_worker.js` は `Cache-Control: no-cache` にしているので、再デプロイ後に古いアプリが残りにくくなっています。
- `firestore`：`server/firestore.rules`（クライアントからの直接アクセスを拒否）と `server/firestore.indexes.json`（一覧用の複合インデックス、本体を検索インデックスから外す設定、`expiresAt` の TTL）を反映します。
- インデックスの作成には数分かかります。コンソールの Firestore →「インデックス」で「有効」になるまで待ちます。
- TTL がコンソールの「有効期間（TTL）」に出ていない場合は、手で設定します。

```sh
for c in itineraries replans rateLimits; do
  gcloud firestore fields ttls update expiresAt --collection-group=$c --enable-ttl --async
done
```

`server/firebase.json` は `server/` の中で Firebase CLI を実行するとき用の重複した設定です。公開は**リポジトリ直下から**実行してください。

### 4.5 全体の動作確認

```sh
curl -i https://<PROJECT_ID>.web.app/api/me/itineraries   # JSON の 401 なら Hosting → Cloud Run の転送と /api の除去ができている
```

ブラウザで `https://<PROJECT_ID>.web.app` を開き、次の順に確認します。

1. 起動できる（開発者ツールのコンソールに Firebase の初期化エラーが出ていない）。
2. 行き先の入力補完が出る（#1、Maps）。自由文から候補が出る（#2、Gemini）。
3. 旅程を作成できる（#3）。一覧に出る（#4、Firestore の複合インデックス）。
4. 今日の旅程から「遅れを伝える」→ 組み直し案が出る（#7）→ 理由文が出る（#8）→ 確定できる（#9）。
5. 名前の変更・コピー・削除ができる（#14〜#16）。

開発者ツールの「ネットワーク」で、リクエストが `https://<PROJECT_ID>.web.app/api/...` に出ていて、`Authorization: Bearer ...` が付いていることも確認します。

---

## 5. 更新・切り戻し

| やりたいこと | コマンド |
|---|---|
| サーバーだけ更新 | 4.1 の `gcloud run deploy` をもう一度（環境変数は前回の値が残ります） |
| アプリだけ更新 | 4.3 → `firebase deploy --only hosting` |
| ルール・インデックスだけ更新 | `firebase deploy --only firestore` |
| 環境変数だけ変える | `gcloud run services update iterinerary-api --region asia-northeast1 --update-env-vars GEMINI_MODEL=<新しいモデル名>` |
| サーバーを前の版に戻す | `gcloud run revisions list --service iterinerary-api --region asia-northeast1` で版を確認し、`gcloud run services update-traffic iterinerary-api --region asia-northeast1 --to-revisions <リビジョン名>=100` |
| アプリを前の版に戻す | Firebase コンソール → Hosting → リリース履歴 →「ロールバック」 |

API の形（リクエスト・レスポンス）を変える場合は、**サーバーを先に**出してからアプリを出します（古いアプリが新しいサーバーを呼んでも壊れない変更にしておく）。

---

## 6. ローカルでつないで確認する（開発用）

本番と同じ Firebase プロジェクトを使い、手元のサーバーと手元のアプリをつなぎます。

```sh
# サーバー（server/ で）
cp .env.example .env    # FIREBASE_PROJECT_ID・GEMINI_MODEL・キーを記入。CORS_ALLOWED_ORIGINS=http://localhost:* にする
gcloud auth application-default login                       # キーを使わない場合、または認証 JSON を使わない場合
gcloud auth application-default set-quota-project <PROJECT_ID>
go run ./cmd/server
```

```sh
# アプリ（app/ で）
flutter run -d chrome \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://localhost:8080
```

- ブラウザのアプリ（`http://localhost:<任意のポート>`）から `http://localhost:8080` を呼ぶので、サーバーには `CORS_ALLOWED_ORIGINS=http://localhost:*` が必要です。プリフライト（OPTIONS）は認証の前に答えます。
- サーバーとアプリの Firebase プロジェクトが違うと、ID トークンの検証で `401` になります。
- サーバーやアプリを使わずに画面だけ確認するときは、`flutter run -d chrome`（既定のモック API）で動きます。

---

## 7. 既知の注意点

- **アプリの受信タイムアウト（15 秒）がサーバーの上限（60 秒）より短い**：#2（Gemini を 2 回呼ぶ）、#3（Gemini と Routes を何度も呼ぶ）、#7・#10 は、混んでいると 15 秒を超えることがあります。その場合、サーバーは処理を続けていてもアプリ側はタイムアウトのエラーになります。本番で多発するようなら、`app/lib/data/api/http_itinerary_api.dart` の `_receiveTimeout` を延ばすか、API ごとに個別に設定することを検討してください。
- **エラーの詳細がログに出ない**：外部サービス・Firestore のエラーは、すべて `502 UPSTREAM_ERROR` として返り、原因はログに残りません（`server/internal/service/upstream.go`、`http.go` の `APIError`）。本番で原因を追えるように、失敗したときに外部サービスのステータスコードとエラーをログに出す改善をおすすめします。
- **電車・バスはほぼ使われない**：Routes API は日本の公共交通をほとんど返さないため、国内の20分を超える区間は車（タクシー表示）になります。タクシー料金・渋滞は反映しません。電車の時刻表にもとづく経路が必要になったら、国内の経路検索サービス（mixway など）を別途つなぐ必要があります。
- **Routes の呼び出しは1区間3回**：徒歩・車・公共交通を並行して呼ぶので、待ち時間は1回分ですが、Routes API の料金は3回分かかります。
- **CI はアプリ（`app/**`）だけ**：Go サーバーのテストは CI で動いていないので、サーバーを変えたら公開前に手元で `go test ./...` を実行してください。
- **費用**：Places / Routes / Gemini は呼び出しごとに課金されます。Cloud Billing の予算アラートと、Cloud Run の `--max-instances` を設定しておくことをおすすめします。実際の遅延・課金額はまだ測っていません。
- **`main` ブランチ**：まだ `back` を取り込んでいません（完成するまで見送り）。`main` には「`back` をマージしてから取り消した」コミット（`30af13d`）があるため、取り込むときは先に `git revert 30af13d` を実行してから `back` をマージしてください。そうしないと、サーバーのコードの大部分が消えたままになります。
