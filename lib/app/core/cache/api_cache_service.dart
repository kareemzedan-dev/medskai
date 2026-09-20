import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCacheService {
  static final ApiCacheService _instance = ApiCacheService._();
  factory ApiCacheService() => _instance;
  ApiCacheService._();

  static const int defaultTtl = 300000; // 5 minutes in ms
  static const String _prefix = 'api_cache_';
  static const String _tsPrefix = 'api_cache_ts_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _cacheKey(String endpoint) => '$_prefix$endpoint';
  String _tsKey(String endpoint) => '$_tsPrefix$endpoint';

  Future<String?> get(String endpoint) async {
    try {
      final prefs = await _sharedPrefs;
      final data = prefs.getString(_cacheKey(endpoint));
      if (data == null) return null;

      if (isExpired(endpoint, prefs: prefs)) return null;
      return data;
    } catch (e) {
      debugPrint('ApiCacheService.get error: $e');
      return null;
    }
  }

  Future<String?> getIgnoringTtl(String endpoint) async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString(_cacheKey(endpoint));
    } catch (e) {
      debugPrint('ApiCacheService.getIgnoringTtl error: $e');
      return null;
    }
  }

  Future<void> set(String endpoint, String data) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString(_cacheKey(endpoint), data);
      await prefs.setInt(
          _tsKey(endpoint), DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('ApiCacheService.set error: $e');
    }
  }

  bool isExpired(String endpoint,
      {SharedPreferences? prefs, int ttl = defaultTtl}) {
    final p = prefs ?? _prefs;
    if (p == null) return true;
    final ts = p.getInt(_tsKey(endpoint));
    if (ts == null) return true;
    return DateTime.now().millisecondsSinceEpoch - ts > ttl;
  }

  bool isFresh(String endpoint, {int ttl = defaultTtl}) {
    return !isExpired(endpoint, ttl: ttl);
  }

  Future<void> clear(String endpoint) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.remove(_cacheKey(endpoint));
      await prefs.remove(_tsKey(endpoint));
    } catch (e) {
      debugPrint('ApiCacheService.clear error: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await _sharedPrefs;
      final keys =
          prefs.getKeys().where((k) => k.startsWith(_prefix) || k.startsWith(_tsPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('ApiCacheService.clearAll error: $e');
    }
  }

  /// Invalidate all cache entries whose keys contain [pattern].
  Future<void> invalidatePattern(String pattern) async {
    try {
      final prefs = await _sharedPrefs;
      final keys = prefs.getKeys().where((k) =>
          (k.startsWith(_prefix) || k.startsWith(_tsPrefix)) &&
          k.contains(pattern));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('ApiCacheService.invalidatePattern error: $e');
    }
  }

  /// Decode cached JSON safely. Returns null if corrupted.
  dynamic decodeCached(String? cachedData) {
    if (cachedData == null) return null;
    try {
      return jsonDecode(cachedData);
    } catch (e) {
      debugPrint('ApiCacheService: corrupted cache data, clearing: $e');
      return null;
    }
  }
}
