import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TTL configuration for different endpoint patterns
class CacheTtlConfig {
  static const Duration categories = Duration(minutes: 60);
  static const Duration courseList = Duration(minutes: 15);
  static const Duration courseDetail = Duration(minutes: 10);
  static const Duration userProfile = Duration(minutes: 5);
  static const Duration wishlist = Duration(minutes: 5);
  static const Duration blogPosts = Duration(minutes: 30);
  static const Duration instructors = Duration(minutes: 60);
  static const Duration defaultTtl = Duration(minutes: 15);

  /// Get TTL for a given endpoint
  static Duration forEndpoint(String endpoint) {
    if (endpoint.contains('categories')) return categories;
    if (endpoint.contains('courses') && !endpoint.contains('/'))
      return courseList;
    if (RegExp(r'courses/\d+').hasMatch(endpoint)) return courseDetail;
    if (endpoint.contains('profile')) return userProfile;
    if (endpoint.contains('wishlist')) return wishlist;
    if (endpoint.contains('posts') || endpoint.contains('blog'))
      return blogPosts;
    if (endpoint.contains('instructor')) return instructors;
    return defaultTtl;
  }
}

/// API Response Cache Service
///
/// File-based cache with per-endpoint TTL and stale-while-revalidate support.
class ApiCacheService {
  static const String _metaPrefix = 'cache_meta_';
  Directory? _cacheDir;
  final SharedPreferences _prefs;

  ApiCacheService(this._prefs);

  /// Initialize cache directory
  Future<void> init() async {
    if (kIsWeb) {
      _cacheDir = null;
      return;
    }

    final appDir = await getApplicationCacheDirectory();
    _cacheDir = Directory('${appDir.path}/api_cache');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  /// Generate a cache key from endpoint and params
  String _cacheKey(String endpoint, Map<String, dynamic>? params) {
    final paramStr = params != null ? jsonEncode(params) : '';
    final raw = '$endpoint|$paramStr';
    return raw.hashCode.toRadixString(16);
  }

  /// Get cached response if available and not expired
  ///
  /// Returns null if no cache exists.
  /// Returns cached data even if stale (caller decides whether to revalidate).
  Future<CacheEntry?> get(String endpoint,
      {Map<String, dynamic>? params}) async {
    if (_cacheDir == null) return null;

    final key = _cacheKey(endpoint, params);
    final file = File('${_cacheDir!.path}/$key.json');

    if (!await file.exists()) return null;

    try {
      final metaJson = _prefs.getString('$_metaPrefix$key');
      if (metaJson == null) return null;

      final meta = jsonDecode(metaJson) as Map<String, dynamic>;
      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(meta['timestamp'] as int);
      final ttlMs = meta['ttl'] as int;
      final ttl = Duration(milliseconds: ttlMs);
      final isExpired = DateTime.now().isAfter(timestamp.add(ttl));

      final data = await file.readAsString();
      return CacheEntry(
        data: data,
        timestamp: timestamp,
        ttl: ttl,
        isExpired: isExpired,
      );
    } catch (e) {
      debugPrint('ApiCacheService: Error reading cache for $endpoint: $e');
      // Corrupted cache - delete it
      await _deleteEntry(key);
      return null;
    }
  }

  /// Store response in cache
  Future<void> put(
    String endpoint,
    String responseBody, {
    Map<String, dynamic>? params,
    Duration? ttl,
  }) async {
    if (_cacheDir == null) return;

    final key = _cacheKey(endpoint, params);
    final file = File('${_cacheDir!.path}/$key.json');
    final effectiveTtl = ttl ?? CacheTtlConfig.forEndpoint(endpoint);

    try {
      await file.writeAsString(responseBody);
      final meta = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': effectiveTtl.inMilliseconds,
        'endpoint': endpoint,
      };
      await _prefs.setString('$_metaPrefix$key', jsonEncode(meta));
    } catch (e) {
      debugPrint('ApiCacheService: Error writing cache for $endpoint: $e');
      // Storage full or other error - skip silently
    }
  }

  /// Delete a specific cache entry
  Future<void> _deleteEntry(String key) async {
    try {
      final file = File('${_cacheDir!.path}/$key.json');
      if (await file.exists()) await file.delete();
      await _prefs.remove('$_metaPrefix$key');
    } catch (_) {}
  }

  /// Invalidate cache for a specific endpoint
  Future<void> invalidate(String endpoint,
      {Map<String, dynamic>? params}) async {
    final key = _cacheKey(endpoint, params);
    await _deleteEntry(key);
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    if (_cacheDir == null) return;
    try {
      if (await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
      }
    } catch (_) {}
  }
}

/// Represents a cached API response
class CacheEntry {
  final String data;
  final DateTime timestamp;
  final Duration ttl;
  final bool isExpired;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
    required this.isExpired,
  });

  /// Parse cached data as JSON
  dynamic get json => jsonDecode(data);
}
