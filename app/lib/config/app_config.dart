/// ビルド時に `--dart-define` で切り替える設定。
///
/// 本番: `flutter run --dart-define-from-file=config/prod.json`（`config/` に接続先ごとの値がある）
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.useMockApi});

  factory AppConfig.fromEnvironment() => const AppConfig(
    apiBaseUrl: String.fromEnvironment(
      _apiBaseUrlKey,
      defaultValue: _defaultApiBaseUrl,
    ),
    useMockApi: bool.fromEnvironment(_useMockApiKey, defaultValue: true),
  );

  static const _apiBaseUrlKey = 'API_BASE_URL';
  static const _useMockApiKey = 'USE_MOCK_API';
  static const _defaultApiBaseUrl = 'http://localhost:8080';

  /// Go の API サーバーのベース URL。本番は `https://test-gentle.web.app/api`
  final String apiBaseUrl;

  /// true のときはサーバーと Firebase を使わず、端末内のサンプルデータで動かす
  final bool useMockApi;
}
