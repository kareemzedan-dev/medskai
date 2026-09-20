import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class ContactParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  /// Contact Form 7 form ID - update this with the actual form ID from WordPress admin
  static const int contactFormId = 1;

  ContactParser({required this.apiService, required this.sharedPreferencesManager});

  Future<Response> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      var response = await apiService.postPublic(
        ApiEndpoints.contact.feedback(contactFormId),
        jsonEncode({
          'your-name': name,
          'your-email': email,
          'your-subject': subject,
          'your-message': message,
        }),
      );
      return response;
    } catch (e) {
      debugPrint('submitContactForm error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }

  String getUserEmail() {
    return sharedPreferencesManager.getString('user_email') ?? "";
  }

  String getUserName() {
    return sharedPreferencesManager.getString('user_name') ?? "";
  }
}
