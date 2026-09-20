import 'dart:convert';

import 'package:flutter_app/app/backend/api/api.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:flutter_app/app/core/network/api_endpoints.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mobx/mobx.dart';

import '../../env.dart';

part 'session_store.g.dart';

class SessionStore = _SessionStore with _$SessionStore;

abstract class _SessionStore with Store {
  SharedPreferencesManager? sharedPreferencesManager;
  ApiService? apiService;

  @observable
  String token = "";
  @observable
  UserInfoModel? userInfo;

  /// Single source of truth for auth state
  @computed
  bool get isLoggedIn => token.isNotEmpty && userInfo?.id != null;

  /// Reactive RxBool for GetX listeners (bridges MobX → GetX)
  final RxBool isAuthenticated = RxBool(false);

  void initStore(sharedPref, apiServiceTemp) {
    sharedPreferencesManager = sharedPref;
    apiService = apiServiceTemp;
    getUser();
  }

  @action
  void setToken(value) {
    token = value;
    _syncAuthState();
  }

  @action
  void setUserInfo(value) {
    userInfo = value;
    _syncAuthState();
  }

  /// Sync MobX state to GetX reactive
  void _syncAuthState() {
    isAuthenticated.value = isLoggedIn;
  }

  /// Clear all session data (logout)
  @action
  void clearSession() {
    token = "";
    userInfo = null;
    sharedPreferencesManager?.clearKey('token');
    sharedPreferencesManager?.clearKey('user_info');
    sharedPreferencesManager?.clearKey('overview');
    sharedPreferencesManager?.clearKey('user_id');
    sharedPreferencesManager?.clearKey('user_login');
    sharedPreferencesManager?.clearKey('user_email');
    sharedPreferencesManager?.clearKey('user_display_name');
    sharedPreferencesManager?.clearKey('cart_token');
    sharedPreferencesManager?.clearKey('wishlish');
    _syncAuthState();
  }

  Future<void> getUser() async {
    try {
      final apiService =
          ApiService(appBaseUrl: Environments.apiBaseURL);
      String tokenTemp = getToken();
      setToken(tokenTemp);
      if (token == "") return;
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      if (payload["data"]?["user"]?["id"] == null) return;
      String userId = payload["data"]["user"]["id"].toString();
      final userIdInt = int.tryParse(userId) ?? 0;
      if (userIdInt == 0) return;
      Response response = await apiService.getPrivate(
          ApiEndpoints.user.detail(userIdInt),
          token,
          null);
      if (response.statusCode == 200) {
        UserInfoModel user =
            UserInfoModel.fromJson(response.body);
        saveUserInfo(user);
        setUserInfo(user);
      }
    } catch (e) {
      // JWT parsing or API call failed - don't crash
    }
  }

  void saveUserInfo(UserInfoModel user) {
    sharedPreferencesManager!.putString('user_info', jsonEncode(user.toJson()));
  }

  String getToken() {
    return sharedPreferencesManager!.getString('token') ?? "";
  }
  String getCurrentCoursesId(){
    return sharedPreferencesManager!.getString('overview') ?? "";
  }
  String getFcmToken(){
    return sharedPreferencesManager!.getString('fcm_token') ?? "";
  }
}
