import 'package:shared_preferences/shared_preferences.dart';

/// Persists the JWT session token on-device (SharedPreferences).
///
/// POC-level storage: good enough for a demo/thesis defense. Production
/// should move this to flutter_secure_storage (encrypted keychain/keystore).
class TokenStorage {
  static const _tokenKey = 'auth_access_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
