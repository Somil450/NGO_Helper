import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'jwt_token';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  static Future<void> deleteToken() async {
    await _prefs?.remove(_tokenKey);
  }

  static bool hasToken() {
    return getToken() != null;
  }
}
