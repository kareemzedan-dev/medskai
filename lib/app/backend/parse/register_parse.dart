import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:jwt_decode/jwt_decode.dart';

class RegisterParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  RegisterParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> register(var body) async {
    try {
      var response = await apiService.postPublic(ApiEndpoints.auth.register, body);
      return response;
    } catch (e) {
      debugPrint('register error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<void> getUser() async {
    try {
      String token = getToken();
      if (token.isEmpty) return;

      Map<String, dynamic> payload = Jwt.parseJwt(token);
      if (payload["data"]?["user"]?["id"] == null) return;
      String userId = payload["data"]["user"]["id"];
      Response response = await apiService.getPrivate(
          ApiEndpoints.user.detail(int.parse(userId)),
          token,
          null);
      if (response.statusCode == 200) {
        UserInfoModel user =
            UserInfoModel.fromJson(response.body);
        saveUserInfo(user);
      }
    } catch (e) {
      // JWT parsing or API call failed - don't crash
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }

  void saveToken(String token) {
    sharedPreferencesManager.putString('token', token);
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
