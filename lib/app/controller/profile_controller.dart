import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/backend/parse/my_profile_parse.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../l10n/locale_keys.g.dart';
import 'notification_controller.dart';

class ProfileController extends GetxController {
  final SessionStore sessionStore;
  final MyProfileParser myProfileParser;
  final NotificationController notificationController =
      Get.find<NotificationController>();
  bool isLogin = false;

  bool haveData = false;
  UserInfoModel _userInfo = UserInfoModel();

  UserInfoModel get userInfo => _userInfo;
  String? avatar;

  String userLogin = '';
  String emailLogin = '';

  bool isLoadingProfile = true;
  int counter = 0;

  ProfileController({
    required this.sessionStore,
    required this.myProfileParser,
  });

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await getUser();
  }

  Future<void> getUser() async {
    if (sessionStore.token == "") {
      isLoadingProfile = false;
      update();
      return;
    }
    isLoadingProfile = true;
    update();
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(sessionStore.token);
      if (payload["data"]?["user"]?["id"] == null) {
        isLoadingProfile = false;
        update();
        return;
      }
      Response response =
          await myProfileParser.getUser(payload["data"]["user"]["id"]);
      if (response.statusCode == 200 && response.body != null) {
        UserInfoModel user = UserInfoModel.fromJson(response.body);
        _userInfo = user;
        avatar = _userInfo.avatar_url;
        isLogin = true;
        myProfileParser.saveUserInfo(user);
      }
    } catch (e) {
      debugPrint('getUser error: $e');
    }
    isLoadingProfile = false;
    update();
    refresh();
  }

  refreshDataUser(userString) {
    UserInfoModel user = UserInfoModel.fromJson(userString);
    _userInfo = user;
    avatar = _userInfo.avatar_url;
    isLogin = true;
    update();
    refresh();
  }

  Future<void> logout() async {
    final context = Get.context;
    if (context == null) return;
    Alert(
      context: context,
      title: tr(LocaleKeys.logout),
      desc: tr(LocaleKeys.alert_logoutTxt),
      buttons: [
        DialogButton(
          child: Text(
            tr(LocaleKeys.alert_cancel),
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500),
          ),
          onPressed: () => {Navigator.pop(context)},
        ),
        DialogButton(
          child: Text(
            tr(LocaleKeys.alert_ok),
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500),
          ),
          onPressed: () async {
            // Delete FCM token
            try {
              String fcmToken = myProfileParser.getFCMToken();
              notificationController.deleteFCMToken(fcmToken);
            } catch (_) {}
            // Clear all session data (single source of truth)
            sessionStore.clearSession();
            isLogin = false;
            update();
            Get.offAllNamed(AppRouter.splash);
          },
        ),
      ],
    ).show();
  }
}
