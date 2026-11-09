import 'package:firebase_auth/firebase_auth.dart';

/// 利用者の識別。会員登録なしで使えるよう Firebase の匿名ログインを使う。
abstract interface class AuthRepository {
  /// 未ログインなら匿名ログインする
  Future<void> ensureSignedIn();

  /// API に付ける Firebase ID トークン
  Future<String?> idToken();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<void> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  @override
  Future<String?> idToken() async {
    await ensureSignedIn();
    return _auth.currentUser?.getIdToken();
  }
}

/// モック API 用。Firebase を初期化せずに動かす。
class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository();

  static const _token = 'mock-token';

  @override
  Future<void> ensureSignedIn() async {}

  @override
  Future<String?> idToken() async => _token;
}
