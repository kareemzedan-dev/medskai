import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter_app/app/backend/parse/social_login_parse.dart';
import 'package:flutter_app/app/env.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsignin;
import '../backend/parse/register_parse.dart';
import '../helper/dialog_helper.dart';
import '../helper/router.dart';
import '../backend/mobx-store/session_store.dart';
import '../controller/home_controller.dart';

class SocialLoginController extends GetxController {
  RegisterParser registerParser = Get.find();
  SocialLoginParse socialLoginParse = Get.find();
  bool isEnableSocialLogin = false;
  @override
  void onInit() {
    isSocialLoginEnable();
    super.onInit();
  }

  signInGoogle() async {
    //Google Sign In
    try {
      await gsignin.GoogleSignIn.instance.initialize(
        clientId: Environments.googleClientId.isNotEmpty ? Environments.googleClientId : null,
        serverClientId: Environments.googleServerClientId.isNotEmpty ? Environments.googleServerClientId : null,
      );
      final gsignin.GoogleSignInAccount result = await gsignin.GoogleSignIn.instance.authenticate();
      
      if (result != null) {
        final gsignin.GoogleSignInAuthentication googleKey = await result.authentication;
        final String? idToken = googleKey.idToken;

        if (idToken != null) {
          DialogHelper.showLoading();
          
          final response = await socialLoginParse.verifyGGLogin({"idToken": idToken});

          if (response.statusCode == 200) {
            Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
            String token = myMap['token']?.toString() ?? '';
            if (token.isNotEmpty) {
              registerParser.saveToken(token);
              registerParser.saveUser(
                  myMap['user_id']?.toString() ?? '',
                  myMap['user_login']?.toString() ?? '',
                  myMap['user_email']?.toString() ?? '',
                  myMap['user_display_name']?.toString() ?? '');
              
              try {
                if (Get.isRegistered<SessionStore>()) {
                  Get.find<SessionStore>().setToken(token);
                  Get.find<SessionStore>().getUser();
                }
              } catch (_) {}

              await registerParser.getUser();

              try {
                if (Get.isRegistered<HomeController>()) {
                  final home = Get.find<HomeController>();
                  home.token = token;
                  home.refreshAllData();
                }
              } catch (_) {}

              Timer(const Duration(seconds: 2), () {
                DialogHelper.hideLoading();
                Get.offAllNamed(AppRouter.tabsBarRoutes);
              });
            } else {
              DialogHelper.hideLoading();
              debugPrint('Login failed: Token is empty');
            }
          } else {
            DialogHelper.hideLoading();
            debugPrint('Login failed: ${response.body}');
          }
        }
      }
    } catch (error) {
      debugPrint('$error');
      DialogHelper.hideLoading();
    }
  }

  signInFacebook() async {
  }

  isSocialLoginEnable() async {
    if (!kIsWeb && Platform.isIOS) {
      isEnableSocialLogin = false;
      refresh();
      update();
      return false;
    }

    // Check if credentials exist locally first
    bool hasGoogleCredentials = Environments.googleClientId.isNotEmpty ||
                                 Environments.googleServerClientId.isNotEmpty;
    bool hasFacebookCredentials = Environments.facebookClientId.isNotEmpty;

    if (hasGoogleCredentials || hasFacebookCredentials) {
      isEnableSocialLogin = true;
      refresh();
      update();
      return true;
    } else {
      isEnableSocialLogin = false;
      refresh();
      update();
      return false;
    }
  }
}
