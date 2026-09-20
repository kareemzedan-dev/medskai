import 'package:flutter/material.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final sharedPref = Get.find<SharedPreferencesManager>();
    final token = sharedPref.getString('token') ?? '';
    if (token.isEmpty) {
      return RouteSettings(name: AppRouter.getLoginRoute());
    }
    return null;
  }
}
