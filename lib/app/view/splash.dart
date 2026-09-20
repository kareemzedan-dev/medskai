import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/app/controller/splash_controller.dart';
import 'package:flutter_app/app/env.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
// import 'package:flutter_app/app/util/toast.dart';

class SplashScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initAndRoute();
  }

  Future<void> _initAndRoute() async {
    try {
      await Get.find<SplashController>()
          .initSharedData()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Splash init error: $e');
    }
    if (!mounted) return;
    _routing();
  }

  @override
  void dispose() {
    super.dispose();
    // _connectivitySubscription.cancel();
  }

  void _routing() {
    // Get.find<SplashController>().parser.saveWelcome(true);
    Future.delayed(Duration.zero, () {
      Get.offNamed(AppRouter.getTabsBarRoute());
    });
    //   Get.find<SplashController>().getConfigData().then((isSuccess) {
    //     if (isSuccess) {
    //       if (Get.find<SplashController>().getLanguageCode() != '') {
    //         var locale = Get.find<SplashController>().getLanguageCode();
    //         Get.updateLocale(Locale(locale));
    //       } else {
    //         // var locale =
    //         //     Get.find<SplashController>().defaultLanguage.languageCode != '' &&
    //         //             Get.find<SplashController>()
    //         //                     .defaultLanguage
    //         //                     .languageCode !=
    //         //                 ''
    //         //         ? Locale(Get.find<SplashController>()
    //         //             .defaultLanguage
    //         //             .languageCode
    //         //             .toString())
    //         //         : Locale('en'.tr);
    //         // Get.updateLocale(locale);
    //       }

    //       if (Get.find<SplashController>().parser.isNewUser() == false) {
    //         Get.find<SplashController>().parser.saveWelcome(true);
    //         Get.offNamed(AppRouter.getInitialRoute());
    //       } else {
    //         Get.find<SplashController>().parser.saveWelcome(true);
    //         // Get.offNamed(AppRouter.getChooseLocationRoutes());
    //       }
    //       // if (Get.find<SplashController>().parser.isNewUser() == false) {
    //       //   Get.find<SplashController>().parser.saveWelcome(true);
    //       //   Get.offNamed(AppRouter.getIntroRoutes());
    //       // } else {
    //       //   Get.find<SplashController>().parser.saveWelcome(true);
    //       //   Get.offNamed(AppRouter.getChooseLocationRoute());
    //       // }
    //     } else {
    //       // Get.toNamed(AppRouter.getErrorRoutes());
    //     }
    //   });
  }

  // Future<void> initConnectivity() async {
  //   late ConnectivityResult result;
  //   try {
  //     result = await _connectivity.checkConnectivity();
  //   } on PlatformException catch (e) {
  //     e;
  //     return;
  //   }
  //   if (!mounted) {
  //     return Future.value(null);
  //   }
  //   return _updateConnectionStatus(result);
  // }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   bool isNotConnected = result != ConnectivityResult.wifi &&
  //       result != ConnectivityResult.mobile;
  //   if (isNotConnected) {
  //     // showToast('No Internet Connection'.tr);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<SplashController>(builder: (value) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: colors.background,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              // Logo - new splash design
              Center(
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              // Loading indicator
              Positioned(
                bottom: 100,
                child: const CircularProgressIndicator(
                  color: MedsKaiColors.primary,
                  strokeWidth: 3,
                ),
              ),
              // Footer
              Positioned(
                bottom: 40,
                child: Text(
                  'Developed By '.tr + Environments.companyName,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
