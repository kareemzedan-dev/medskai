import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class FinishLearningParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  FinishLearningParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getLesson(String id) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.lessons.detail(int.parse(id)), token, null);
      return response;
    } catch (e) {
      debugPrint('getLesson error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getQuiz(String id) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.quiz.detail(int.parse(id)), token, null);
      return response;
    } catch (e) {
      debugPrint('getQuiz error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
