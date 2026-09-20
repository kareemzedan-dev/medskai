import 'package:get/get_connect/http/src/response/response.dart';

import '../../core/network/api_endpoints.dart';
import '../../helper/shared_pref.dart';
import '../api/api.dart';

class PaymentParser {
  final ApiService apiService;
  final SharedPreferencesManager sharedPreferencesManager;
  PaymentParser({required this.apiService, required this.sharedPreferencesManager});

  Future<Response> checkCourse(String receipt, bool isIos, String id) async {
    try {
      var param = {
        'receipt-data': receipt,
        'is-ios': isIos.toString(),
        'course-id': id,
        'platform': "flutter",
      };
      var response = await apiService.postPrivate(
          ApiEndpoints.payment.verifyReceipt, param, getToken());
      return response;
    } catch (e) {
      return const Response(statusCode: 500, statusText: 'Network error');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
