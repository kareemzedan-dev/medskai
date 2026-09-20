import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';

class SplashParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  SplashParser(
      {required this.apiService, required this.sharedPreferencesManager});

  bool isNewUser() {
    return sharedPreferencesManager.getBool('welcome');
  }

  Future<bool> initAppSettings() {
    return Future.value(true);
  }
}
