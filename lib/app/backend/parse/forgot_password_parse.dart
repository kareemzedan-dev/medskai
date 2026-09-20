import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import '../api/api.dart';

class ForgotPasswordParse {
  final ApiService apiService;
  ForgotPasswordParse({required this.apiService});
  Future<Response> forgotPassword(var body) async {
    var response = await apiService.postPublic(ApiEndpoints.auth.resetPassword, body);
    return response;
  }
}
