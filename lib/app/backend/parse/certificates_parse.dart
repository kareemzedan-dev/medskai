import 'package:get/get_connect/http/src/response/response.dart';

import '../../helper/shared_pref.dart';
import '../api/api.dart';

class CertificatesParser {
  final ApiService apiService;
  final SharedPreferencesManager sharedPreferencesManager;

  CertificatesParser({
    required this.apiService,
    required this.sharedPreferencesManager,
  });

  /// Get user certificates from new API
  Future<Response> getMyCertificates({int page = 1, int perPage = 20}) async {
    try {
      String token = getToken();
      var params = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      String? userId = getUserId();
      if (userId != null && userId.isNotEmpty) {
        params['user_id'] = userId;
      }

      print('==== CERTIFICATES API REQUEST ====');
      print('URL: ${ApiEndpoints.certificates.myCertificates}');
      print('Params: $params');
      print('Headers: {');
      print('  Content-Type: application/json;');
      print('  x-platform: flutter');
      print('  Authorization: Bearer $token');
      print('}');
      print('==================================');

      var response = await apiService.getPrivate(
        ApiEndpoints.certificates.myCertificates,
        token,
        params,
      );
      return response;
    } catch (e) {
      return const Response(statusCode: 500, statusText: 'Network error');
    }
  }

  Future<Response> getPassedCourses({int page = 1, int perPage = 20}) async {
    try {
      final token = getToken();
      final params = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'learned': 'true',
        'course_filter': 'passed',
        'optimize': 'sections,count_students,instructor,meta_data,course_data',
      };
      return apiService.getPrivate(
        ApiEndpoints.courses.myCourses,
        token,
        params,
      );
    } catch (e) {
      return const Response(statusCode: 500, statusText: 'Network error');
    }
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }

  String? getUserId() {
    return sharedPreferencesManager.getString('user_id');
  }
}
