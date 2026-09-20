import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class InstructorDetailParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  InstructorDetailParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getCourse(var body) async {
    try {
      var response =
          await apiService.getPublic(ApiEndpoints.courses.list, body);
      return response;
    } catch (e) {
      debugPrint('getCourse error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getInstructor(String userId) async {
    try {
      Map<String, dynamic> body = {};
      // Use WP public users endpoint (works without admin permissions)
      var response = await apiService.getPublic(
          'wp-json/wp/v2/users/$userId', body);
      return response;
    } catch (e) {
      debugPrint('getInstructor error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
