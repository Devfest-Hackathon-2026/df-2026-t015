// このファイルは `flutterfire configure` で上書きする仮のファイル。
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<Firebase プロジェクト ID>
//
// モック API（既定の USE_MOCK_API=true）で動かす間は使われない。

import 'package:firebase_core/firebase_core.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'firebase_options.dart が未設定です。flutterfire configure を実行してください。',
  );
}
