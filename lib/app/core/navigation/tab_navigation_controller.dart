import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Tab Navigation Controller
///
/// Manages bottom navigation bar state and tab switching
///
/// Usage:
/// ```dart
/// final tabController = Get.find<TabNavigationController>();
/// tabController.navigateTo(TabNavigationController.coursesTab);
/// ```
class TabNavigationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// Tab controller for TabBarView
  late TabController tabController;

  /// Currently selected tab index (reactive)
  final RxInt selectedIndex = 0.obs;

  /// Loading state for tab content
  final RxBool isLoading = false.obs;

  // ============================================================
  // Tab Indices
  // ============================================================

  /// Total number of tabs
  static const int tabCount = 5;

  /// Home tab index
  static const int homeTab = 0;

  /// Courses tab index
  static const int coursesTab = 1;

  /// My Courses tab index
  static const int myCoursesTab = 2;

  /// Wishlist tab index
  static const int wishlistTab = 3;

  /// Profile tab index
  static const int profileTab = 4;

  // ============================================================
  // Lifecycle
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: selectedIndex.value,
    );

    // Listen to tab controller changes
    tabController.addListener(_onTabChanged);
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }

  // ============================================================
  // Navigation Methods
  // ============================================================

  /// Navigate to specific tab by index
  void navigateTo(int index) {
    if (index < 0 || index >= tabCount) return;
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;
    tabController.animateTo(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    update();
  }

  /// Navigate to Home tab
  void goToHome() => navigateTo(homeTab);

  /// Navigate to Courses tab
  void goToCourses() => navigateTo(coursesTab);

  /// Navigate to My Courses tab
  void goToMyCourses() => navigateTo(myCoursesTab);

  /// Navigate to Wishlist tab
  void goToWishlist() => navigateTo(wishlistTab);

  /// Navigate to Profile tab
  void goToProfile() => navigateTo(profileTab);

  // ============================================================
  // State Management
  // ============================================================

  /// Check if current tab is the specified tab
  bool isCurrentTab(int index) => selectedIndex.value == index;

  /// Get current tab index
  int get currentTabIndex => selectedIndex.value;

  /// Check if Home tab is selected
  bool get isHomeSelected => isCurrentTab(homeTab);

  /// Check if Courses tab is selected
  bool get isCoursesSelected => isCurrentTab(coursesTab);

  /// Check if My Courses tab is selected
  bool get isMyCoursesSelected => isCurrentTab(myCoursesTab);

  /// Check if Wishlist tab is selected
  bool get isWishlistSelected => isCurrentTab(wishlistTab);

  /// Check if Profile tab is selected
  bool get isProfileSelected => isCurrentTab(profileTab);

  // ============================================================
  // Private Methods
  // ============================================================

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      selectedIndex.value = tabController.index;
    }
  }

  // ============================================================
  // Legacy Support (backwards compatibility)
  // ============================================================

  /// Legacy getter for tab ID
  int get tabId => selectedIndex.value;

  /// Legacy method for updating tab ID
  void updateTabId(int id) => navigateTo(id);
}

/// Deprecated: Use TabNavigationController instead
@Deprecated('Use TabNavigationController instead')
typedef TabControllerX = TabNavigationController;
