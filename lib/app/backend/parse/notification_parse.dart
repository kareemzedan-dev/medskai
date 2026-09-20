import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class NotificationParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  NotificationParser(
      {required this.apiService, required this.sharedPreferencesManager});

  Future<Response> getNotification({Map<String, String>? body}) async {
    try {
      String token = getToken();
      var response = await apiService.getPrivate(
          ApiEndpoints.notification.list, token, body);
      return response;
    } catch (e) {
      debugPrint('getNotification error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> registerFCMToken(
      String deviceToken, String deviceType) async {
    try {
      String token = getToken();
      Map<String, String> body = {
        'device_token': deviceToken,
        'device_type': deviceType
      };
      var response = await apiService.postPrivate(
          ApiEndpoints.notification.registerDevice, body, token);
      return response;
    } catch (e) {
      debugPrint('registerFCMToken error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> deleteFCMToken(String deviceToken) async {
    try {
      String token = getToken();
      Map<String, String> body = {'device_token': deviceToken};
      var response = await apiService.postPrivate(
          ApiEndpoints.notification.deleteDevice, body, token);
      return response;
    } catch (e) {
      debugPrint('deleteFCMToken error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
