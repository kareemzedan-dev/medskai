import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Tab Navigation Controller
///
/// Lightweight state holder for the selected tab index.
/// The actual tab switching is done by IndexedStack in TabScreen.
class TabControllerX extends GetxController {
  /// Currently selected tab index (reactive)
  final RxInt selectedIndex = 0.obs;

  // Tab Indices
  static const int tabCount = 5;
  static const int homeTab = 0;
  static const int coursesTab = 1;
  static const int myCoursesTab = 2;
  static const int wishlistTab = 3;
  static const int profileTab = 4;

  /// Navigate to specific tab by index
  void navigateTo(int index) {
    if (index < 0 || index >= tabCount) return;
    selectedIndex.value = index;
    update();
  }

  /// Convenience navigation methods
  void goToHome() => navigateTo(homeTab);
  void goToCourses() => navigateTo(coursesTab);
  void goToMyCourses() => navigateTo(myCoursesTab);
  void goToWishlist() => navigateTo(wishlistTab);
  void goToProfile() => navigateTo(profileTab);

  /// Check if current tab is selected
  bool isCurrentTab(int index) => selectedIndex.value == index;

  // Legacy support
  int get tabId => selectedIndex.value;
  void updateTabId(int id) => navigateTo(id);

  void reinitialize() => update();
}
