import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/app/controller/tabs_controller.dart';
import 'package:flutter_app/app/view/components/categories.dart';
import 'package:flutter_app/app/view/components/instructors.dart';
import 'package:flutter_app/app/view/components/latest_news.dart';
import 'package:flutter_app/app/view/components/home/universities_slider.dart';
import 'package:flutter_app/app/view/components/top-course.dart';
import 'package:flutter_app/app/view/components/offline_banner.dart';
import 'package:flutter_app/app/view/components/overview.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:get/get.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class HomeScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onLogin() {
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(AppRouter.getLoginRoute());
    });
  }

  void onRegister() {
    Future.delayed(Duration.zero, () {
      Get.toNamed(AppRouter.getRegisterRoute());
    });
  }

  TabControllerX get tabController => Get.find<TabControllerX>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.kaiColors;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final topPadding =
        isAndroid ? 44.0 : MediaQuery.of(context).viewPadding.top + 8;

    return GetBuilder<HomeController>(
      builder: (value) {
        if (value.hasError) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: colors.background,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              MedsKaiColors.primary.withOpacity(0.15),
                              MedsKaiColors.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.build_circle_rounded,
                          size: 56,
                          color: MedsKaiColors.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Under Maintenance',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We\'re working on improving your experience.\nPlease try again in a moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          value.hasError = false;
                          value.update();
                          value.refreshAllData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                MedsKaiColors.primary,
                                MedsKaiColors.primary.withOpacity(0.85)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.refresh_rounded,
                                  color: MedsKaiColors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Try Again',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: MedsKaiColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final isLoggedIn = value.parser.getToken() != "";

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.background,
          body: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (value.isOffline) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(tr(LocaleKeys.ui_noInternetCached)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    await value.refreshAllData();
                  },
                  color: MedsKaiColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: topPadding),

                        // Header: Logo + Notification/Login
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 140,
                                height: 40,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 'assets/images/logo_horizontal_dark.png'
                                          : 'assets/images/logo_horizontal_light.png',
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              isLoggedIn
                                  ? const SizedBox.shrink()
                                  : Row(
                                      children: [
                                        TextButton(
                                          onPressed: onLogin,
                                          child: Text(
                                            tr(LocaleKeys.login),
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: MedsKaiColors.primary,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 20,
                                          width: 1,
                                          color: colors.border,
                                        ),
                                        TextButton(
                                          onPressed: onRegister,
                                          child: Text(
                                            tr(LocaleKeys.register),
                                            style: TextStyle(
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),

                        // User Greeting
                        if (isLoggedIn) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                // Avatar with purple ring
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        MedsKaiColors.primary,
                                        MedsKaiColors.primary.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.5),
                                  child: ClipOval(
                                    child: (value.parser
                                                    .getUserInfo()
                                                    .avatar_url !=
                                                null &&
                                            value.parser
                                                .getUserInfo()
                                                .avatar_url
                                                .isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: value.parser
                                                .getUserInfo()
                                                .avatar_url,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: MedsKaiColors.primary10,
                                            child: const Icon(Icons.person,
                                                color: MedsKaiColors.primary,
                                                size: 24),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 16,
                                            color: colors.textPrimary,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '${tr(LocaleKeys.home_greeting)} ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${value.parser.getUserInfo().first_name ?? value.parser.getUserInfo().name ?? ''} ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800),
                                            ),
                                            const TextSpan(text: '\u{1F44B}'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tr(LocaleKeys.home_greetingSubtitle),
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Overview Section
                        if (isLoggedIn)
                          GetBuilder<HomeController>(
                            id: 'overview',
                            builder: (ctrl) => ctrl.isLoadingOverview
                                ? const SizedBox.shrink()
                                : (ctrl.overview is Map &&
                                        ctrl.overview["id"] != null)
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 20),
                                            Overview(overview: ctrl.overview),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                          ),

                        // Categories Section
                        GetBuilder<HomeController>(
                          id: 'categories',
                          builder: (ctrl) => ctrl.isLoadingCategories
                              ? const SizedBox.shrink()
                              : ctrl.cateHomeList.isNotEmpty
                                  ? Categories(
                                      categoriesList: ctrl.cateHomeList)
                                  : const SizedBox.shrink(),
                        ),

                        // Top Courses Section
                        GetBuilder<HomeController>(
                          id: 'topCourses',
                          builder: (ctrl) => ctrl.isLoadingTopCourses
                              ? const SizedBox.shrink()
                              : ctrl.topCoursesList.isNotEmpty
                                  ? TopCourse(
                                      topCoursesList: ctrl.topCoursesList)
                                  : const SizedBox.shrink(),
                        ),

                        // Universities Slider Section
                        GetBuilder<HomeController>(
                          id: 'categories',
                          builder: (ctrl) => ctrl.isLoadingCategories
                              ? const SizedBox.shrink()
                              : const UniversitiesSlider(),
                        ),

                        // Latest News Section
                        GetBuilder<HomeController>(
                          id: 'latestPosts',
                          builder: (ctrl) => ctrl.isLoadingPosts
                              ? const SizedBox.shrink()
                              : ctrl.latestPosts.isNotEmpty
                                  ? LatestNews(postsList: ctrl.latestPosts)
                                  : const SizedBox.shrink(),
                        ),

                        // Instructors Section
                        GetBuilder<HomeController>(
                          id: 'instructors',
                          builder: (ctrl) => ctrl.isLoadingInstructors
                              ? const SizedBox.shrink()
                              : ctrl.instructorList.isNotEmpty
                                  ? Instructors(
                                      instructorList: ctrl.instructorList)
                                  : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
