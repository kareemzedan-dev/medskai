import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class ReviewParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  ReviewParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getReview(String id, var body) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.review.course(int.parse(id)), token, body);
      return response;
    } catch (e) {
      debugPrint('getReview error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
