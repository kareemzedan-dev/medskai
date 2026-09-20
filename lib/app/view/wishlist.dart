import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/tabs_controller.dart';
import 'package:flutter_app/app/controller/wishlist_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/item-course.dart';
import 'package:flutter_app/app/view/components/skeleton/skeleton_widgets.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onLogin() {
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(AppRouter.getLoginRoute());
    });
  }

  HomeController get homeController => Get.find<HomeController>();
  CoursesController get courseController => Get.find<CoursesController>();
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.kaiColors;
    double top = MediaQuery.of(context).viewPadding.top;
    return GetBuilder<WishlistController>(builder: (value) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: colors.background,
        drawerEnableOpenDragGesture: false,
        body: SafeArea(
          child: Column(
              children: <Widget>[
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        tr(LocaleKeys.wishlist_title),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Wishlist count badge
                if (value.parser.getToken() != '' && value.coursesList.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: MedsKaiColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                size: 16,
                                color: MedsKaiColors.error,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${value.coursesList.length} ${value.coursesList.length == 1 ? tr(LocaleKeys.common_courseSingular) : tr(LocaleKeys.common_coursePlural)}',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: MedsKaiColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Initial loading skeleton for logged in users
                if (value.parser.getToken() != '' && value.isInitialLoading)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => const SkeletonCourseCard(),
                        ),
                      ),
                    ),
                  ),
                // Error state for logged in users
                if (value.parser.getToken() != '' && value.hasError && value.coursesList.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 64,
                            color: colors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tr(LocaleKeys.error),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            value.errorMessage,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => value.retryLoadData(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(tr(LocaleKeys.common_retry)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MedsKaiColors.primary,
                              foregroundColor: MedsKaiColors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Empty state for logged in users (after loading complete)
                if (value.parser.getToken() != '' && !value.isInitialLoading && !value.hasError && value.coursesList.isEmpty)
                  Expanded(
                    child: Center(
                      child: _buildEmptyState(),
                    ),
                  ),
                // Login prompt for non-logged in users
                value.parser.getToken() == ''
                    ? Expanded(
                        child: Center(
                          child: _buildLoginPrompt(),
                        ),
                      )
                    : value.coursesList.isNotEmpty
                        ? Expanded(
                            child: RefreshIndicator(
                              color: MedsKaiColors.primary,
                              onRefresh: () => value.refreshData(),
                              child: ListView.builder(
                                controller: value.scrollController,
                                padding: const EdgeInsets.only(bottom: 100, top: 8),
                                physics: const AlwaysScrollableScrollPhysics(),
                                cacheExtent: 500,
                                itemCount: value.coursesList.length,
                                itemBuilder: (context, index) {
                                  if (index < value.coursesList.length) {
                                    return Container(
                                      key: ValueKey(value.coursesList[index].id ?? index),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: ItemCourse(
                                        item: value.coursesList[index],
                                        courseDetailParser: Get.find(),
                                        onToggleWishlist: () async => {
                                          await value.onToggleWishlist(
                                              value.coursesList[index]),
                                          homeController.refreshScreen(),
                                          courseController.refreshScreen(),
                                        },
                                        hideCategory: true,
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                          )
                        : const SizedBox(),
              ],
            ),
          ),
      );
    });
  }

  Widget _buildEmptyState() {
    final colors = context.kaiColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Empty heart illustration
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MedsKaiColors.error.withOpacity(0.15),
                MedsKaiColors.error.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 60,
                color: MedsKaiColors.error.withOpacity(0.4),
              ),
              Positioned(
                bottom: 28,
                right: 28,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.sectionBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          tr(LocaleKeys.dataNotFound),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            tr(LocaleKeys.empty_emptyWishlistHint),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Browse courses button
        GestureDetector(
          onTap: () {
            Get.find<TabControllerX>().goToCourses();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [MedsKaiColors.primary, MedsKaiColors.primary.withOpacity(0.85)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: MedsKaiColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.explore_rounded,
                  color: MedsKaiColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  tr(LocaleKeys.common_browseCourses),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: MedsKaiColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    final colors = context.kaiColors;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lock illustration
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MedsKaiColors.primary,
                  MedsKaiColors.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: MedsKaiColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 50,
              color: MedsKaiColors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tr(LocaleKeys.needLogin),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(LocaleKeys.auth_signInWishlist),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Login button
          Container(
            height: 54,
            width: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  MedsKaiColors.primary,
                  MedsKaiColors.primary.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: MedsKaiColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                alignment: Alignment.center,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onLogin,
              child: Center(
                child: Text(
                  tr(LocaleKeys.login),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MedsKaiColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
