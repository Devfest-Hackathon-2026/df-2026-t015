/// ビルド時に `--dart-define` で切り替える設定。
///
/// 例: `flutter run --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=https://xxx.run.app`
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

  /// Cloud Run 上の Express API のベース URL
  final String apiBaseUrl;

  /// true のときはサーバーと Firebase を使わず、端末内のサンプルデータで動かす
  final bool useMockApi;
}
