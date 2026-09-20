import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';

import 'package:get/get.dart';

/// Minimal parser kept for binding compatibility, and creating jobs natively.
class JobsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  JobsParser({required this.apiService, required this.sharedPreferencesManager});

  Future<Response> createJob(Map<String, dynamic> data) async {
    return await apiService.postPrivate(
      'wp-json/wp/v2/job-listings',
      data,
      getToken(),
    );
  }

  String getToken() {
    return sharedPreferencesManager.getString('token') ?? "";
  }
}
