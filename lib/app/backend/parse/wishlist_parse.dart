import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class WishlistParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  WishlistParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getWishlist(var body) async {
    try {
      String token = getToken();
      var response =
          await apiService.getPrivate(ApiEndpoints.wishlist.list, token, body);
      return response;
    } catch (e) {
      debugPrint('getWishlist error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> toggleWishlist(int courseId) async {
    try {
      String token = getToken();
      var param = {"id": courseId};
      var response =
          await apiService.postPrivate(ApiEndpoints.wishlist.toggle, param, token);
      return response;
    } catch (e) {
      debugPrint('toggleWishlist error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getWishlistCourse(int courseId) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.wishlist.course(courseId), token, null);
      return response;
    } catch (e) {
      debugPrint('getWishlistCourse error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  void saveItemToWishlish(CourseModel data) async {
    String json = jsonEncode(data);
    sharedPreferencesManager.putString('wishlish', json);
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
