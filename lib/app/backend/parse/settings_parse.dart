import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'dart:convert';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

import '../mobx-store/session_store.dart';

class SettingsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;
  final SessionStore sessionStore;

  SettingsParser({required this.apiService, required this.sharedPreferencesManager, required this.sessionStore});

  Future<Response> changePassword(var body) async {
    try {
      var response = await apiService.postPrivate(
          ApiEndpoints.auth.resetPassword, body, getToken());
      return response;
    } catch (e) {
      debugPrint('changePassword error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> deleteAccount(var body) async {
    try {
      var response = await apiService.postPrivate(
          ApiEndpoints.user.list, body, getToken());
      return response;
    } catch (e) {
      debugPrint('deleteAccount error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> submitGeneral(var body) async {
    try {
      UserInfoModel user = getUserInfo();
      var response = await apiService.postPrivateMultipart(
          ApiEndpoints.user.detail(user.id ?? 0), body, getToken());
      return response;
    } catch (e) {
      debugPrint('submitGeneral error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }

  UserInfoModel getUserInfo() {
    String temp = sharedPreferencesManager.getString('user_info') ?? "";
    UserInfoModel json = UserInfoModel();
    if (temp != "") {
      json = UserInfoModel.fromJson(jsonDecode(temp) as Map<String, dynamic>);
    }
    return json;
  }

  updateUserDataSharedPreferencesManager() async {
    String? token = sharedPreferencesManager.getString('token');
    String? userId = sharedPreferencesManager.getString('user_id');
    if (token == null || token.isEmpty || userId == null || userId.isEmpty) return;
    try {
      Response response = await apiService.getPrivate(
          ApiEndpoints.user.detail(int.parse(userId)), token, null);
      if (response.statusCode == 200 && response.body != null) {
        UserInfoModel user = UserInfoModel.fromJson(response.body);
        sharedPreferencesManager.putString('user_info', jsonEncode(user.toJson()));
        sessionStore.setUserInfo(user);
      }
    } catch (e) {
      // Failed to update user data
    }
  }
}
