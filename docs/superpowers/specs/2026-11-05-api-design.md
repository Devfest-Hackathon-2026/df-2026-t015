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
