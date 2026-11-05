# Iterinerary（Flutter クライアント）

旅行当日に予定が遅れたとき、優先度に合わせて旅程を組み直すアプリ。
仕様は [docs/](docs/) を参照（UI・機能まとめ / API 仕様 / UI デザイン）。

## 動かす

```sh
flutter pub get
flutter run -d chrome            # モック API（サーバー・Firebase なし）で動く
```

サーバーにつなぐとき:

```sh
flutterfire configure            # lib/firebase_options.dart を生成
flutter run \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=https://<Cloud Run の URL>
```

モデル（freezed / json_serializable）を変えたら:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## 構成

```
lib/
  main.dart / app.dart       起動・MaterialApp.router
  theme.dart                 デザインの値（ColorScheme / TextTheme / AppTokens）
  constants/                 API の制約・画面の文言
  config/                    --dart-define の設定
  routing/routes.dart        go_router（画面のパス）
  data/
    models/                  API 仕様の共通データ型・リクエスト
    api/                     ItineraryApi（HTTP 実装・モック実装・エラー）
    auth/                    Firebase 匿名ログイン
    providers.dart           Riverpod の provider（旅程の取得・更新）
  features/
    home/                    起動時の振り分け
    plan/                    3.1 行き先と優先度（F-01、F-02）
    today/                   3.2 今日の旅程（F-06）
    delay/                   3.3 遅れを伝える（F-03）
    replan/                  3.4 組み直し案（F-04、F-05）
  widgets/                   共通のボタン・ラベル・タイル
  utils/format.dart          時刻・金額の書式
```

## 開発規約（抜粋）

詳細は「Iterinerary アプリ UI・機能まとめ」の 7 章。

- 状態を持つウィジェットは `HookWidget` / `HookConsumerWidget`。`StatefulWidget` は使わない
- 色・余白・角丸・文字サイズは `lib/theme.dart` に置き、`context.tokens` / `context.colors` / `context.texts` で読む
- 意味のある数値・文字列は名前付きの定数にする（API の制約は `lib/constants/`、ポーリング間隔などは使う機能のファイル内）
- `bash tool/check_conventions.sh` で `extends StatefulWidget` と theme.dart 以外の `Color(0x` を検出する（CI でも実行）

## 未対応・TODO

- API クライアントは手書き。サーバーの OpenAPI 定義ができたら生成コードに置き換える
- F-07（空き時間の提案）は API クライアントのみで、画面は未実装
- google_maps_flutter による地図表示は未導入
