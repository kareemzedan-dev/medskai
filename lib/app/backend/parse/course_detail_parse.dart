import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class CourseDetailParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  CourseDetailParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getDetailCourse(String id) async {
    try {
      String token = getToken();
      Random random = Random();
      int randomNumber = random.nextInt(123456789);
      var param = {
        "v": randomNumber.toString(),
      };
      final endpoint = ApiEndpoints.courses.detail(int.parse(id));
      Response response;
      if (token.isNotEmpty) {
        response = await apiService.getPrivate(endpoint, token, param);
      } else {
        response = await apiService.getPublic(endpoint, param);
      }
      return response;
    } catch (e) {
      debugPrint('getDetailCourse error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> start(String id) async {
    try {
      var param = {
        "id": int.parse(id),
      };
      String token = getToken();
      var response = await apiService.postPrivate(
        ApiEndpoints.courses.enroll,
        param,
        token,
      );
      return response;
    } catch (e) {
      debugPrint('start error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> enroll(String id) async {
    try {
      var param = {
        "id": int.parse(id),
      };
      String token = getToken();
      var response = await apiService.postPrivate(
        ApiEndpoints.courses.enroll,
        param,
        token,
      );
      return response;
    } catch (e) {
      debugPrint('enroll error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> retake(String id) async {
    try {
      var param = {"id": int.parse(id)};
      String token = getToken();
      var response = await apiService.postPrivate(
        ApiEndpoints.courses.retake,
        param,
        token,
      );
      return response;
    } catch (e) {
      debugPrint('retake error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }

  Future<Response> getRating(String id, int? per_page) async {
    try {
      String token = getToken();
      var param = {"per_page": per_page != null ? per_page.toString() : null};
      var response = await apiService.getPrivate(
          ApiEndpoints.review.course(int.parse(id)), token, param);
      return response;
    } catch (e) {
      debugPrint('getRating error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> createRating(var body) async {
    try {
      String token = getToken();
      var response =
          await apiService.postPrivate(ApiEndpoints.review.submit, body, token);
      return response;
    } catch (e) {
      debugPrint('createRating error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  void setOverview(String overview) {
    sharedPreferencesManager.putString('overview', overview);
  }
  String getOverviewId() {
    return sharedPreferencesManager.getString('overview') ?? "";
  }
}
