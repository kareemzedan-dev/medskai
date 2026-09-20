import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class CommunityParser {
  final ApiService apiService;
  final SharedPreferencesManager sharedPreferencesManager;

  CommunityParser({
    required this.apiService,
    required this.sharedPreferencesManager,
  });

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? '';
  }

  Future<Response> getMyGroups() async {
    try {
      final response = await apiService.getPrivate(
        'wp-json/speciality-groups/v1/my-groups',
        getToken(),
        null,
      );
      return response;
    } catch (e) {
      debugPrint('getMyGroups error: $e');
      rethrow;
    }
  }

  Future<Response> getGroupDiscussions(String groupId, {int page = 1}) async {
    try {
      final response = await apiService.getPrivate(
        'wp-json/speciality-groups/v1/groups/$groupId/discussions',
        getToken(),
        {'page': page.toString()},
      );
      return response;
    } catch (e) {
      debugPrint('getGroupDiscussions error: $e');
      rethrow;
    }
  }

  Future<Response> postGroupDiscussion(String groupId, String content) async {
    try {
      final response = await apiService.postPrivate(
        'wp-json/speciality-groups/v1/groups/$groupId/discussions',
        {'content': content},
        getToken(),
      );
      return response;
    } catch (e) {
      debugPrint('postGroupDiscussion error: $e');
      rethrow;
    }
  }
}
