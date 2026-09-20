import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:flutter_app/app/controller/wishlist_controller.dart';
import 'package:flutter_app/app/controller/tabs_controller.dart';
import 'package:flutter_app/app/controller/profile_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/courses.dart';
import 'package:flutter_app/app/view/home.dart';
import 'package:flutter_app/app/view/my_courses.dart';
import 'package:flutter_app/app/view/my_profile.dart';
import 'package:flutter_app/app/view/wishlist.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import '../../l10n/locale_keys.g.dart';
import 'package:flutter_app/app/util/toast.dart';

class TabScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  TabScreen({super.key});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  double get screenWidth => MediaQuery.of(context).size.width;

  final List<Widget> _tabViews = [
    HomeScreen(),
    const CoursesScreen(),
    const MyCoursesScreen(),
    const WishlistScreen(),
    MyProfileScreen(),
  ];

  int _currentIndex = 0;
  DateTime? _currentBackPressTime;

  @override
  void initState() {
    super.initState();
    try {
      _currentIndex = Get.find<TabControllerX>().tabId.clamp(0, 4);
    } catch (_) {}
  }

  Future<bool> _onWillPop() {
    if (_currentIndex != 0) {
      _onNavTap(0);
      return Future.value(false);
    }
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      showToast("اضغط مرة أخرى للخروج من التطبيق", isError: false);
      return Future.value(false);
    }
    return Future.value(true);
  }

  void _onNavTap(int index) {
    if (index < 0 || index > 4) return;

    if (index == 0) {
      try {
        Get.find<HomeController>().getOverview();
      } catch (_) {}
    }
    if (index == 2) {
      try {
        Get.find<MyCoursesController>().refreshData();
      } catch (_) {}
    }
    if (index == 3) {
      try {
        Get.find<WishlistController>().refreshData();
      } catch (_) {}
    }
    if (index == 4) {
      try {
        Get.find<ProfileController>().getUser();
      } catch (_) {}
    }

    setState(() {
      _currentIndex = index;
    });

    try {
      final ctrl = Get.find<TabControllerX>();
      ctrl.selectedIndex.value = index;
      ctrl.update();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return GetBuilder<TabControllerX>(
      builder: (ctrl) {
        if (ctrl.tabId != _currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && ctrl.tabId != _currentIndex) {
              setState(() {
                _currentIndex = ctrl.tabId.clamp(0, 4);
              });
            }
          });
        }

        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: colors.background,
            extendBody: true,
            body: IndexedStack(
              index: _currentIndex,
              children: _tabViews,
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: isAndroid ? 16 : 24,
              ),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: colors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: MedsKaiColors.primary.withOpacity(0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home_rounded,
                        tr(LocaleKeys.bottomNavigation_home)),
                    _buildNavItem(
                        1,
                        Icons.school_outlined,
                        Icons.school_rounded,
                        tr(LocaleKeys.bottomNavigation_courses)),
                    _buildNavItem(
                        2,
                        Icons.play_circle_outline,
                        Icons.play_circle_rounded,
                        tr(LocaleKeys.bottomNavigation_myCourse)),
                    _buildNavItem(
                        3,
                        Icons.favorite_outline,
                        Icons.favorite_rounded,
                        tr(LocaleKeys.bottomNavigation_wishlist)),
                    _buildNavItem(4, Icons.person_outline, Icons.person_rounded,
                        tr(LocaleKeys.bottomNavigation_profile)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _onNavTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MedsKaiColors.primary.withOpacity(0.15),
                      MedsKaiColors.primary.withOpacity(0.08),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? MedsKaiColors.primary
                    : context.kaiColors.textSecondary.withOpacity(0.7),
                size: isSelected ? 26 : 24,
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: MedsKaiColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
