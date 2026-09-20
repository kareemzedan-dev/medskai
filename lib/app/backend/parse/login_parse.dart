import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get_connect.dart';

class LoginParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  LoginParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> login(var body) async {
    try {
      var response = await apiService.postPublic(ApiEndpoints.auth.login, body);
      return response;
    } catch (e) {
      debugPrint('login error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> validateToken() async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.auth.validateToken, token, null);
      return response;
    } catch (e) {
      debugPrint('validateToken error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> getUser(String id) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.user.detail(int.parse(id)), token, null);
      return response;
    } catch (e) {
      debugPrint('getUser error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  void saveToken(String token) {
    sharedPreferencesManager.putString('token', token);
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
  String getFcmToken() {
    return sharedPreferencesManager.getString(SharedPreferencesManager.keyFcmToken) ?? "";
  }
  String getUserId() {
    return sharedPreferencesManager.getString('user_id') ?? "";
  }

  void saveUserInfo(UserInfoModel user) {
    sharedPreferencesManager.putString('user_info', jsonEncode(user.toJson()));
  }

  void saveUser(String userId, String userLogin, String userEmail,
      String userDisplayName) {
    sharedPreferencesManager.putString('user_id', userId);
    sharedPreferencesManager.putString('user_login', userLogin);
    sharedPreferencesManager.putString('user_email', userEmail);
    sharedPreferencesManager.putString('user_display_name', userDisplayName);
  }
}
