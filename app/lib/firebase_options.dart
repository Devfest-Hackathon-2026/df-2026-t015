// 本番の Firebase プロジェクト（test-gentle）の設定。
//
// Web アプリ「test-gentle」の設定値（Firebase コンソール → プロジェクトの設定 → マイアプリ）。
// クライアントに埋め込む公開情報で、秘密ではない。
// Android / iOS のアプリを Firebase に登録したら、次のコマンドで作り直す。
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=test-gentle
//
// モック API（既定の USE_MOCK_API=true）で動かす間は使われない。

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'この端末向けの Firebase アプリは未登録です。'
      'flutterfire configure --project=test-gentle を実行してください。',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBHA3L24r-_otgeRBlSFaUZnX7XRxZ6xjI',
    appId: '1:1026093274301:web:44ceeabaaff31a1dd113d4',
    messagingSenderId: '1026093274301',
    projectId: 'test-gentle',
    authDomain: 'test-gentle.firebaseapp.com',
    storageBucket: 'test-gentle.firebasestorage.app',
    measurementId: 'G-QY04M4XQ16',
  );
}
