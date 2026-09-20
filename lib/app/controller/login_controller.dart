import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';
import 'package:flutter_app/app/backend/parse/login_parse.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/notification_controller.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../helper/router.dart';

class LoginController extends GetxController implements GetxService {
  final LoginParser parser;
  final SessionStore sessionStore;
  final NotificationController notificationController =
      Get.find<NotificationController>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginController({required this.parser, required this.sessionStore});

  final MyCoursesController myCourseController =
      Get.find<MyCoursesController>();
  final WishlistStore wishlistStore = Get.find<WishlistStore>();

  Future<void> login(username, password) async {
    final trimmedUsername = username?.toString().trim() ?? '';
    final trimmedPassword = password?.toString().trim() ?? '';
    debugPrint('Login: Starting login...');

    if (trimmedUsername.isEmpty) {
      showToast(tr(LocaleKeys.loginScreen_usernameEmpty), isError: true);
      return;
    }
    if (trimmedPassword.isEmpty) {
      showToast(tr(LocaleKeys.loginScreen_passwordEmpty), isError: true);
      return;
    }

    Response response;
    try {
      var param = {
        "username": trimmedUsername,
        "password": trimmedPassword,
      };
      debugPrint('Login: Calling API...');
      response = await parser.login(param);
      debugPrint(
          'Login: API response received - statusCode: ${response.statusCode}');
    } catch (e) {
      debugPrint('Login: Exception caught: $e');
      showToast(tr(LocaleKeys.toast_networkError), isError: true);
      return;
    }

    if (response.statusCode == 200) {
      debugPrint('Login: Success! Parsing response...');
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      parser.saveToken(myMap['token']?.toString() ?? '');
      sessionStore.setToken(myMap['token']?.toString() ?? '');
      parser.saveUser(
          myMap['user_id']?.toString() ?? '',
          myMap['user_login']?.toString() ?? '',
          myMap['user_email']?.toString() ?? '',
          myMap['user_display_name']?.toString() ?? '');

      // Run background tasks first (don't await - fire and forget)
      _runBackgroundTasks();

      // Refresh HomeController if it already exists (permanent controller)
      try {
        if (Get.isRegistered<HomeController>()) {
          final home = Get.find<HomeController>();
          home.token = parser.getToken();
          home.refreshAllData();
        }
      } catch (_) {}

      debugPrint('Login: Navigating to main app...');
      Get.offAllNamed(AppRouter.getTabsBarRoute());
    } else if (response.statusCode == 1) {
      // Connection issue (timeout or network error)
      debugPrint('Login: Connection failed - ${response.statusText}');
      showToast(tr(LocaleKeys.toast_networkError), isError: true);
    } else {
      debugPrint('Login: Failed with statusCode ${response.statusCode}');
      String errorMsg = tr(LocaleKeys.toast_loginFailed);
      if (response.body != null &&
          response.body is Map &&
          response.body["message"] != null) {
        errorMsg = response.body["message"].toString();
      }
      showToast(errorMsg, isError: true);
    }
    debugPrint('Login: Function completed');
  }

  /// Run background tasks after login (fire and forget)
  void _runBackgroundTasks() {
    // Get user info
    sessionStore.getUser();

    // Register FCM token
    try {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>()
            .registerFCMToken(parser.getFcmToken());
      }
    } catch (e) {
      debugPrint('FCM registration failed: $e');
    }

    // Load wishlist (async but don't await)
    wishlistStore.getWishlist().catchError((e) {
      debugPrint('Wishlist load failed: $e');
    });

    // Refresh my courses (async but don't await — controller may not exist yet)
    try {
      if (Get.isRegistered<MyCoursesController>()) {
        Get.find<MyCoursesController>().refreshData().catchError((e) {
          debugPrint('My courses refresh failed: $e');
        });
      }
    } catch (e) {
      debugPrint('My courses controller not available: $e');
    }
  }

  Future<void> getUser() async {
    try {
      String token = parser.getToken();
      if (token == "") return;
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      if (payload["data"]?["user"]?["id"] == null) return;
      Response response = await parser.getUser(payload["data"]["user"]["id"]);
      if (response.statusCode == 200) {
        UserInfoModel user = UserInfoModel.fromJson(response.body);
        parser.saveUserInfo(user);
      }
    } catch (e) {
      debugPrint('getUser error: $e');
    }
    update();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  final OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(8.0),
      topRight: Radius.circular(8.0),
      bottomLeft: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
    ),
    borderSide: BorderSide(color: MedsKaiColors.border),
  );
}
