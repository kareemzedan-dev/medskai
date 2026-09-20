import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple offline storage for lesson content using SharedPreferences.
/// Stores lesson HTML content for offline viewing.
class OfflineStorage {
  static const _prefix = 'offline_lesson_';
  static const _indexKey = 'offline_lessons_index';

  final SharedPreferences _prefs;

  OfflineStorage(this._prefs);

  /// Max size per lesson (500KB to stay safe within SharedPrefs limits)
  static const int _maxSizeBytes = 500 * 1024;

  /// Save lesson content for offline. Skips if content too large.
  Future<bool> saveLesson(String lessonId, dynamic data) async {
    try {
      final encoded = data is String ? data : jsonEncode(data);
      if (encoded.length > _maxSizeBytes) {
        // Content too large for SharedPreferences — skip silently
        return false;
      }
      await _prefs.setString('$_prefix$lessonId', encoded);
      // Update index
      final index = getDownloadedLessonIds();
      if (!index.contains(lessonId)) {
        index.add(lessonId);
        await _prefs.setStringList(_indexKey, index);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get saved lesson content
  Map<String, dynamic>? getLesson(String lessonId) {
    final data = _prefs.getString('$_prefix$lessonId');
    if (data == null) return null;
    try {
      return jsonDecode(data);
    } catch (_) {
      return null;
    }
  }

  /// Check if lesson is available offline
  bool isAvailable(String lessonId) =>
      _prefs.containsKey('$_prefix$lessonId');

  /// Get all downloaded lesson IDs
  List<String> getDownloadedLessonIds() =>
      _prefs.getStringList(_indexKey) ?? [];

  /// Delete a saved lesson
  Future<void> deleteLesson(String lessonId) async {
    await _prefs.remove('$_prefix$lessonId');
    final index = getDownloadedLessonIds();
    index.remove(lessonId);
    await _prefs.setStringList(_indexKey, index);
  }

  /// Clear all offline content
  Future<void> clearAll() async {
    final index = getDownloadedLessonIds();
    for (final id in index) {
      await _prefs.remove('$_prefix$id');
    }
    await _prefs.remove(_indexKey);
  }

  /// Get total size of offline content (approximate)
  int getTotalSizeBytes() {
    int total = 0;
    for (final id in getDownloadedLessonIds()) {
      final data = _prefs.getString('$_prefix$id');
      if (data != null) total += data.length;
    }
    return total;
  }
}
