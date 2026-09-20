import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class MyCoursesParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  MyCoursesParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getMyCourse(var body) async {
    try {
      String token = getToken();
      debugPrint('==== MY COURSES API REQUEST ====');
      debugPrint('URL: ${ApiEndpoints.courses.myCourses}');
      debugPrint('Params: $body');
      debugPrint('Headers: {');
      debugPrint('  Content-Type: application/json;');
      debugPrint('  x-platform: flutter');
      debugPrint('  Authorization: Bearer $token');
      debugPrint('}');
      debugPrint('================================');

      var response =
          await apiService.getPrivate(ApiEndpoints.courses.myCourses, token, body);
      return response;
    } catch (e) {
      debugPrint('getMyCourse error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
