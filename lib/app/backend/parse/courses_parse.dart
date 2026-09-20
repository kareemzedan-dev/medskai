import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class CoursesParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  CoursesParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getCourses(var body) async {
    try {
      var response = await apiService.getPublic(ApiEndpoints.courses.list, body);
      return response;
    } catch (e) {
      debugPrint('getCourses error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getCategory() async {
    try {
      var response = await apiService.getPublic(ApiEndpoints.categories.list, null);
      return response;
    } catch (e) {
      debugPrint('getCategory error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
