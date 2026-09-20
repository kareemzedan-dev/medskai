import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/app/core/security/secure_storage.dart';

class SharedPreferencesManager {
  SharedPreferences? sharedPreferences;
  final SecureStorage _secureStorage = SecureStorage.instance;

  /// Keys that must be stored securely (tokens, credentials)
  static const _secureKeys = {'token', 'accessToken', 'secure_access_token'};

  static const String keyAccessToken = 'accessToken';
  static const String keyUserData = 'user_data';
  static const String keyRole = 'user_role';
  static const String keyFcmToken = 'fcm_token';

  /// In-memory token cache for sync access (loaded from secure storage at init)
  String _cachedToken = '';

  SharedPreferencesManager({required this.sharedPreferences});

  /// Call after construction to load token from secure storage into memory.
  Future<void> initSecureToken() async {
    _cachedToken = await _secureStorage.getToken();
    // Migrate: if token exists in SharedPrefs but not in secure storage, move it
    final oldToken = sharedPreferences?.getString('token') ?? '';
    if (_cachedToken.isEmpty && oldToken.isNotEmpty) {
      debugPrint('Migrating token to secure storage');
      await _secureStorage.setToken(oldToken);
      _cachedToken = oldToken;
      await sharedPreferences?.remove('token'); // Remove from insecure storage
    }
  }

  Future<bool>? putBool(String key, bool value) =>
      sharedPreferences?.setBool(key, value);

  bool getBool(String key) => sharedPreferences?.getBool(key) ?? false;

  Future<bool>? putDouble(String key, double value) =>
      sharedPreferences?.setDouble(key, value);

  double? getDouble(String key) => sharedPreferences?.getDouble(key);

  Future<bool>? putInt(String key, int value) =>
      sharedPreferences?.setInt(key, value);

  int? getInt(String key) => sharedPreferences?.getInt(key);

  Future<bool>? putString(String key, String value) {
    if (_secureKeys.contains(key)) {
      _cachedToken = value;
      _secureStorage.setToken(value);
      return Future.value(true);
    }
    return sharedPreferences?.setString(key, value);
  }

  String? getString(String key) {
    if (_secureKeys.contains(key)) {
      return _cachedToken;
    }
    return sharedPreferences?.getString(key);
  }

  Future<bool>? putStringList(String key, List<String> value) =>
      sharedPreferences?.setStringList(key, value);

  Future<bool>? putCartString(String key, var value) =>
      sharedPreferences?.setStringList(key, value);

  List<String>? getStringList(String key) =>
      sharedPreferences?.getStringList(key);

  bool? isKeyExists(String key) => sharedPreferences?.containsKey(key);

  Future<bool>? clearKey(String key) {
    if (_secureKeys.contains(key)) {
      _cachedToken = '';
      _secureStorage.clearToken();
      return Future.value(true);
    }
    return sharedPreferences?.remove(key);
  }

  Future<bool>? clearAll() {
    _cachedToken = '';
    _secureStorage.clearAll();
    return sharedPreferences?.clear();
  }
}
