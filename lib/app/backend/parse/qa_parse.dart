import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class QaParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  QaParser({required this.apiService, required this.sharedPreferencesManager});

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }

  Future<Response> getQuestions(int courseId) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.qa.courseQuestions(courseId), token, null);
      return response;
    } catch (e) {
      debugPrint('getQuestions error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> submitQuestion(int courseId, Map<String, dynamic> body) async {
    try {
      String token = getToken();
      var response = await apiService.postPrivate(
          ApiEndpoints.qa.courseQuestions(courseId), body, token);
      return response;
    } catch (e) {
      debugPrint('submitQuestion error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> submitReply(int questionId, Map<String, dynamic> body) async {
    try {
      String token = getToken();
      var response = await apiService.postPrivate(
          ApiEndpoints.qa.replyQuestion(questionId), body, token);
      return response;
    } catch (e) {
      debugPrint('submitReply error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }
}
