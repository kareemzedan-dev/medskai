import 'dart:async';

/// Prevents duplicate concurrent API requests.
/// If the same request is already in-flight, returns the existing Future.
class RequestDeduplicator {
  static final Map<String, Future<dynamic>> _pending = {};

  /// Execute a request with deduplication.
  /// [key] should be unique per request (e.g., URL + params hash).
  static Future<T> execute<T>(String key, Future<T> Function() request) async {
    if (_pending.containsKey(key)) {
      return _pending[key]! as Future<T>;
    }
    final future = request().whenComplete(() => _pending.remove(key));
    _pending[key] = future;
    return future;
  }

  /// Clear all pending requests.
  static void clearAll() => _pending.clear();
}
