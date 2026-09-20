import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/parse/register_parse.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_app/app/view/tabs.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController implements GetxService {
  final RegisterParser parser;

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreedToTerms = false;
  bool isLoading = false;
  final WishlistStore wishlistStore = Get.find<WishlistStore>();
  final SessionStore sessionStore = Get.find<SessionStore>();
  final HomeController homeController = Get.find<HomeController>();
  final MyCoursesController myCourseController =
      Get.find<MyCoursesController>();
  RegisterController({required this.parser});
  bool apiCalled = false;

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    if (isLoading) return;

    if (usernameController.text.trim().isEmpty) {
      showToast(tr(LocaleKeys.registerScreen_usernameEmpty), isError: true);
      return;
    }
    if (emailController.text.trim().isEmpty) {
      showToast(tr(LocaleKeys.registerScreen_emailEmpty), isError: true);
      return;
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      showToast(tr(LocaleKeys.validation_invalidEmail), isError: true);
      return;
    }
    if (passwordController.text.isEmpty) {
      showToast(tr(LocaleKeys.registerScreen_passwordEmpty), isError: true);
      return;
    }
    if (passwordController.text.length < 6) {
      showToast(
          tr(LocaleKeys.validation_passwordMinLength,
              namedArgs: {'count': '6'}),
          isError: true);
      return;
    }
    if (confirmPasswordController.text.isEmpty) {
      showToast(tr(LocaleKeys.registerScreen_confirmPasswordEmpty),
          isError: true);
      return;
    }

    if (confirmPasswordController.text != passwordController.text) {
      showToast(tr(LocaleKeys.registerScreen_incorrectPassword), isError: true);
      return;
    }

    if (!agreedToTerms) {
      showToast(tr(LocaleKeys.registerScreen_termAndConditionEmpty),
          isError: true);
      return;
    }

    isLoading = true;
    update();

    Response response;
    try {
      var param = {
        "email": emailController.text.trim(),
        "username": usernameController.text.trim(),
        "password": passwordController.text,
        "confirm_password": confirmPasswordController.text
      };
      response = await parser.register(param);
      apiCalled = true;
    } catch (e) {
      debugPrint('Register error: $e');
      showToast(tr(LocaleKeys.toast_registrationFailed), isError: true);
      isLoading = false;
      update();
      return;
    }

    if (response.statusCode == 200) {
      if (response.body == null || response.body is! Map) {
        showToast(tr(LocaleKeys.toast_unexpectedResponse), isError: true);
        isLoading = false;
        update();
        return;
      }
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);

      if (myMap['token'] == null) {
        showToast(tr(LocaleKeys.toast_noTokenReceived), isError: true);
        isLoading = false;
        update();
        return;
      }

      parser.saveToken(myMap['token']?.toString() ?? '');
      parser.saveUser(
        myMap['user_id']?.toString() ?? '',
        myMap['user_login']?.toString() ?? '',
        myMap['user_email']?.toString() ?? '',
        myMap['user_display_name']?.toString() ?? '',
      );
      sessionStore.setToken(myMap['token']?.toString() ?? '');

      // Navigate first - this is the critical action
      isLoading = false;
      update();
      // Refresh HomeController with new token before navigating
      try {
        if (Get.isRegistered<HomeController>()) {
          final home = Get.find<HomeController>();
          home.token = home.parser.getToken();
          home.refreshAllData();
        }
      } catch (_) {}

      Get.offAllNamed(AppRouter.getTabsBarRoute());

      // Non-critical: run after navigation
      try {
        await parser.getUser();
      } catch (e) {
        debugPrint('getUser failed: $e');
      }
      try {
        await wishlistStore.getWishlist();
      } catch (e) {
        debugPrint('Wishlist load failed: $e');
      }
      try {
        await myCourseController.refreshData();
      } catch (e) {
        debugPrint('My courses refresh failed: $e');
      }
    } else {
      String errorMsg = tr(LocaleKeys.toast_registrationFailedDefault);
      if (response.body != null &&
          response.body is Map &&
          response.body["message"] != null) {
        errorMsg = response.body["message"];
      }
      showToast(errorMsg, isError: true);
      isLoading = false;
      update();
    }
  }
}
