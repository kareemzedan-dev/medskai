import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper for sensitive data (tokens, credentials).
/// Uses platform keychain/keystore for encrypted storage.
class SecureStorage {
  static SecureStorage? _instance;
  final FlutterSecureStorage _storage;

  SecureStorage._()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  static SecureStorage get instance {
    _instance ??= SecureStorage._();
    return _instance!;
  }

  // Keys
  static const keyAccessToken = 'secure_access_token';
  static const keyRefreshToken = 'secure_refresh_token';

  /// Read a secure value.
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('SecureStorage read error: $e');
      return null;
    }
  }

  /// Write a secure value.
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('SecureStorage write error: $e');
    }
  }

  /// Delete a secure value.
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('SecureStorage delete error: $e');
    }
  }

  /// Clear all secure storage.
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('SecureStorage clearAll error: $e');
    }
  }

  // Convenience methods for token
  Future<String> getToken() async => await read(keyAccessToken) ?? '';
  Future<void> setToken(String token) => write(keyAccessToken, token);
  Future<void> clearToken() => delete(keyAccessToken);
}
