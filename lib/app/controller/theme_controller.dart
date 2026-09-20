import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/app/helper/shared_pref.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';
  final SharedPreferencesManager _prefs;

  ThemeController({required SharedPreferencesManager prefs}) : _prefs = prefs;

  bool get isDarkMode => Get.isDarkMode;

  void toggleTheme() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
      _prefs.putString(_themeKey, 'light');
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      _prefs.putString(_themeKey, 'dark');
    }
    update();
  }
}
