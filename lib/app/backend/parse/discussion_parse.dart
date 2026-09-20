import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class DiscussionParser {
  final ApiService apiService;
  final SharedPreferencesManager sharedPreferencesManager;

  DiscussionParser({required this.apiService, required this.sharedPreferencesManager});

  String getToken() => sharedPreferencesManager.getString('token') ?? '';

  /// Get comments for a course/lesson
  Future<Response> getComments(int courseId, {int? lessonId, int page = 1}) async {
    try {
      final params = <String, String>{
        'post': courseId.toString(),
        'page': page.toString(),
        'per_page': '20',
        'orderby': 'date',
        'order': 'desc',
      };
      if (lessonId != null) {
        params['post'] = lessonId.toString();
      }
      final response = await apiService.getPublic('wp-json/wp/v2/comments', params);
      return response;
    } catch (e) {
      debugPrint('getComments error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  /// Post a new comment
  Future<Response> postComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    try {
      final token = getToken();
      final body = {
        'post': postId,
        'content': content,
        if (parentId != null && parentId > 0) 'parent': parentId,
      };
      final response = await apiService.postPrivate(
        'wp-json/wp/v2/comments',
        body,
        token,
      );
      return response;
    } catch (e) {
      debugPrint('postComment error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }
}
