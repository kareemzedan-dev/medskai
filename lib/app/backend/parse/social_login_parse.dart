import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import '../../core/network/api_endpoints.dart';
import '../../env.dart';
import '../../helper/shared_pref.dart';
import '../api/api.dart';

class SocialLoginParse {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  SocialLoginParse({required this.sharedPreferencesManager, required this.apiService});

  Future<Response> verifyGGLogin(var body) async {
    try {
      var response =
          await apiService.postPublic(ApiEndpoints.socialLogin.verifyGoogle, body);
      return response;
    } catch (e) {
      debugPrint('verifyGGLogin error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> verifyFbLogin(var body) async {
    try {
      var response =
          await apiService.postPublic(ApiEndpoints.socialLogin.verifyFacebook, body);
      return response;
    } catch (e) {
      debugPrint('verifyFbLogin error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> checkTokenFB() async {
    try {
      Map<String, dynamic> param = {};
      param['client_id'] = Environments.facebookClientId;
      param['client_secret'] = Environments.facebookClientSecret;
      param['grant_type'] = 'client_credentials';
      var response =
          await apiService.get('https://graph.facebook.com/oauth/access_token', param);
      return response;
    } catch (e) {
      debugPrint('checkTokenFB error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }

  Future<Response> enableSocialLogin() async {
    try {
      Map<String, dynamic> body = {};
      var response = await apiService.getPrivate(
          ApiEndpoints.socialLogin.enableSocial, '', body);
      return response;
    } catch (e) {
      debugPrint('enableSocialLogin error: $e');
      return const Response(statusCode: -1, statusText: 'Request failed');
    }
  }
}
