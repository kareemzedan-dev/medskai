import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/backend/parse/my_profile_parse.dart';
import 'package:flutter_app/app/view/tabs.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../backend/mobx-store/course_store.dart';

class MyProfileController extends GetxController implements GetxService {
  final MyProfileParser parser;
  final sessionStore = locator<SessionStore>();
  final courseStore = locator<CourseStore>();

  UserInfoModel _userInfo = UserInfoModel();
  UserInfoModel get userInfo => _userInfo;
  String? avatar;

  String token = '';
  String userLogin = '';
  String emailLogin = '';
  MyProfileController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    token = parser.getToken();
    userLogin = parser.getUserNameLogin();
    emailLogin = parser.getEmailLogin();
    getUser();
  }

  Future<void> getUser() async {
    if (token == "") return;
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      if (payload["data"]?["user"]?["id"] == null) return;
      Response response = await parser.getUser(payload["data"]["user"]["id"]);
      if (response.statusCode == 200 && response.body != null) {
        UserInfoModel user = UserInfoModel.fromJson(response.body);
        _userInfo = user;
        avatar = _userInfo.avatar_url;
        parser.saveUserInfo(user);
      }
    } catch (e) {
      debugPrint('getUser error: $e');
    }
    update();
  }

  Future<void> logout() async {
    parser.clearAccount();
    sessionStore.setToken('');
    courseStore.setDetail('');
    Get.offAll(() => TabScreen());
  }
}
