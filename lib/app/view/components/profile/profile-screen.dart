import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/parse/my_profile_parse.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/controller/tabs_controller.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:indexed/indexed.dart';

import '../../../controller/profile_controller.dart';
import '../../../controller/my_courses_controller.dart';
import '../../../core/services/offline_storage.dart';
import '../../../env.dart';
import 'package:flutter_app/app/view/components/overview.dart';
import 'package:flutter_app/app/controller/home_controller.dart';

typedef OnNavigateCallback = void Function(int page);

class Profile extends StatefulWidget {
  final MyProfileParser myProfileParser;
  final ProfileController profileController;
  final OnNavigateCallback goToPage;
  final OnNavigateCallback goBack;

  @override
  State<Profile> createState() => _Profile();

  Profile(
      {required this.myProfileParser,
      super.key,
      required this.goToPage,
      required this.goBack,
      required this.profileController});
}

class _Profile extends State<Profile> {
  @override
  void initState() {
    String? user = widget.myProfileParser.getUserInfo();
    if (user != null) {
      widget.profileController.refreshDataUser(jsonDecode(user));
    }
    widget.profileController.getUser();

    super.initState();
  }

  void onLogin() {
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(AppRouter.getLoginRoute());
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<ProfileController>(
      init: widget.profileController,
      builder: (value) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.background,
          drawerEnableOpenDragGesture: false,
          body: widget.myProfileParser.getToken() == ''
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MedsKaiColors.primary.withOpacity(0.15),
                        colors.background,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        child: _buildLoginPrompt(),
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: <Widget>[
                    // Gradient header background
                    Indexed(
                      index: 1,
                      child: Positioned(
                        right: 0,
                        top: 0,
                        left: 0,
                        child: Container(
                          width: screenWidth,
                          height: (250 / 375) * screenWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                MedsKaiColors.primary.withOpacity(0.15),
                                colors.background,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Text(
                              tr(LocaleKeys.profile_title),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  _buildProfileCard(value),
                                  if (widget.myProfileParser.getToken() != '')
                                    GetBuilder<HomeController>(
                                      id: 'overview',
                                      builder: (ctrl) => ctrl.isLoadingOverview
                                          ? const SizedBox.shrink()
                                          : (ctrl.overview is Map &&
                                                  ctrl.overview["id"] != null)
                                              ? Column(
                                                  children: [
                                                    const SizedBox(height: 20),
                                                    Overview(overview: ctrl.overview),
                                                  ],
                                                )
                                              : const SizedBox.shrink(),
                                    ),
                                  const SizedBox(height: 24),
                                  _buildMenuSection(value),
                                  // const SizedBox(height: 24),
                                  // _buildVersionInfo(),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showDownloadsSheet(BuildContext context) {
    final colors = context.kaiColors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final offline = Get.find<OfflineStorage>();

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final currentCount = offline.getDownloadedLessonIds().length;
            final currentSizeBytes = offline.getTotalSizeBytes();
            final currentSizeMB = (currentSizeBytes / (1024 * 1024)).toStringAsFixed(2);

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr(LocaleKeys.downloads_title),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.sectionBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: MedsKaiColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            color: MedsKaiColors.info,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr(LocaleKeys.downloads_downloadedCount, namedArgs: {'count': currentCount.toString()}),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tr(LocaleKeys.downloads_totalSize, namedArgs: {'size': currentSizeMB}),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
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
                  const SizedBox(height: 20),
                  if (currentCount > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await offline.clearAll();
                          setSheetState(() {});
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(tr(LocaleKeys.downloads_cleared)),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 20),
                        label: Text(
                          tr(LocaleKeys.downloads_clearAll),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MedsKaiColors.error,
                          foregroundColor: MedsKaiColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (currentCount == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No lessons downloaded yet.\nLessons are saved automatically when you view them online.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    final colors = context.kaiColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
            Icons.person_outline_rounded,
            size: 50,
            color: MedsKaiColors.white,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            tr(LocaleKeys.needLogin),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr(LocaleKeys.auth_signInProfile),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
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
    );
  }

  Widget _buildProfileCard(ProfileController value) {
    final colors = context.kaiColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B39BF).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          (value.userInfo.avatar_url != null && value.userInfo.avatar_url.isNotEmpty)
              ? Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MedsKaiColors.primary.withOpacity(0.2),
                      width: 3,
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(value.userInfo.avatar_url),
                    ),
                  ),
                )
              : Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MedsKaiColors.primary.withOpacity(0.2),
                        MedsKaiColors.primary.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: MedsKaiColors.primary,
                  ),
                ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.userInfo.name ?? '',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (value.userInfo.description != '' && value.userInfo.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    value.userInfo.description ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                if (value.userInfo.email != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: MedsKaiColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: MedsKaiColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            value.userInfo.email ?? '',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: MedsKaiColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (value.userInfo.completed_courses_count > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: MedsKaiColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: MedsKaiColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${value.userInfo.completed_courses_count} ${tr(LocaleKeys.myOrders_completed)}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: MedsKaiColors.success,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(ProfileController value) {
    final colors = context.kaiColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Settings
          _buildMenuItem(
            icon: Feather.settings,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.primary, MedsKaiColors.primary.withOpacity(0.85)],
            title: tr(LocaleKeys.settings_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitleSettings),
            onTap: () => widget.goToPage(1),
            showDivider: true,
          ),
          // My Orders
          _buildMenuItem(
            icon: Feather.shopping_bag,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.primary, MedsKaiColors.primary.withOpacity(0.85)],
            title: tr(LocaleKeys.myOrders_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitleOrders),
            onTap: () => widget.goToPage(2),
            showDivider: true,
          ),
          // Wishlist
          _buildMenuItem(
            icon: Icons.favorite_border_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [Colors.redAccent, Colors.redAccent.withOpacity(0.85)],
            title: tr(LocaleKeys.bottomNavigation_wishlist),
            subtitle: 'Your saved courses',
            onTap: () {
               try {
                 Get.find<TabControllerX>().updateTabId(3);
               } catch (_) {}
            },
            showDivider: true,
          ),
          // Community
          _buildMenuItem(
            icon: Icons.forum_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.primary, MedsKaiColors.primary.withOpacity(0.85)],
            title: tr(LocaleKeys.community_title),
            subtitle: tr(LocaleKeys.community_subtitle),
            onTap: () => Get.toNamed(AppRouter.community),
            showDivider: true,
          ),
          // Downloads (Offline Lessons)
          _buildMenuItem(
            icon: Icons.download_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.info, MedsKaiColors.info.withOpacity(0.85)],
            title: tr(LocaleKeys.downloads_title),
            subtitle: tr(LocaleKeys.downloads_subtitle),
            onTap: () => _showDownloadsSheet(context),
            showDivider: true,
          ),
          // Certificates
          _buildMenuItem(
            icon: Icons.verified_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.success, MedsKaiColors.success.withOpacity(0.85)],
            title: tr(LocaleKeys.certificate_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitleCertificates),
            onTap: () => Get.toNamed(AppRouter.certificates),
            showDivider: true,
          ),
          // Instructors
          _buildMenuItem(
            icon: Icons.school_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.secondary, MedsKaiColors.secondary.withOpacity(0.85)],
            title: tr(LocaleKeys.instructors_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitleInstructors),
            onTap: () => Get.toNamed(AppRouter.instructorsList),
            showDivider: true,
          ),
          // Our Team
          // _buildMenuItem(
          //   icon: Icons.groups_rounded,
          //   iconColor: MedsKaiColors.white,
          //   iconBgGradient: [MedsKaiColors.primary, MedsKaiColors.purpleAccent],
          //   title: 'Our Team',
          //   subtitle: 'Meet the people behind MedsKai',
          //   onTap: () => Get.toNamed(AppRouter.team),
          //   showDivider: true,
          // ),
          // Contact Us
          _buildMenuItem(
            icon: Icons.mail_outline_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.info, MedsKaiColors.info.withOpacity(0.85)],
            title: tr(LocaleKeys.contact_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitleContact),
            onTap: () => Get.toNamed(AppRouter.contact),
            showDivider: true,
          ),
          // Become an Instructor
          _buildMenuItem(
            icon: Icons.cast_for_education_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.accent, MedsKaiColors.accent.withOpacity(0.85)],
            title: tr(LocaleKeys.instructor_becomeInstructor),
            subtitle: tr(LocaleKeys.ui_profileSubtitleBecomeInstructor),
            onTap: () => Get.toNamed(AppRouter.becomeInstructor),
            showDivider: true,
          ),
          // Job Opportunities conditionally
          GetBuilder<MyCoursesController>(
            init: Get.find<MyCoursesController>(),
            builder: (myCourses) {
              if (myCourses.coursesList.isNotEmpty) {
                return _buildMenuItem(
                  icon: Icons.work_outline_rounded,
                  iconColor: MedsKaiColors.white,
                  iconBgGradient: [MedsKaiColors.secondary, MedsKaiColors.secondary.withOpacity(0.85)],
                  title: tr(LocaleKeys.jobs_title),
                  subtitle: tr(LocaleKeys.ui_profileSubtitleJobs),
                  onTap: () => Get.toNamed(AppRouter.jobs),
                  showDivider: true,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // About Us
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.primary, MedsKaiColors.primary.withOpacity(0.85)],
            title: tr(LocaleKeys.aboutUs_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitleAboutUs),
            onTap: () => Get.toNamed(AppRouter.aboutUs),
            showDivider: true,
          ),
          // Blog
          _buildMenuItem(
            icon: Icons.article_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.info, MedsKaiColors.info.withOpacity(0.85)],
            title: tr(LocaleKeys.blog_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitleBlog),
            onTap: () => Get.toNamed(AppRouter.blog),
            showDivider: true,
          ),
          // Privacy Policy
          _buildMenuItem(
            icon: Icons.privacy_tip_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [colors.textSecondary, colors.textSecondary.withOpacity(0.85)],
            title: tr(LocaleKeys.privacyPolicy_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitlePrivacy),
            onTap: () => Get.toNamed(AppRouter.privacyPolicy),
            showDivider: true,
          ),
          // Terms & Conditions
          _buildMenuItem(
            icon: Icons.description_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [colors.textSecondary, colors.textSecondary.withOpacity(0.85)],
            title: tr(LocaleKeys.terms_title),
            subtitle: tr(LocaleKeys.ui_profileSubtitleTerms),
            onTap: () => Get.toNamed(AppRouter.termsConditions),
            showDivider: true,
          ),
          // Logout
          _buildMenuItem(
            icon: Icons.logout_rounded,
            iconColor: MedsKaiColors.white,
            iconBgGradient: [MedsKaiColors.error, MedsKaiColors.error.withOpacity(0.85)],
            title: tr(LocaleKeys.logout),
            subtitle: tr(LocaleKeys.ui_profileSubtitleLogout),
            onTap: value.logout,
            showDivider: false,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required List<Color> iconBgGradient,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
    bool isDestructive = false,
  }) {
    final colors = context.kaiColors;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: iconBgGradient,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: iconBgGradient[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDestructive ? MedsKaiColors.error : colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
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
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colors.textSecondary.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: colors.border.withOpacity(0.5),
            ),
          ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    final colors = context.kaiColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colors.sectionBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        LocaleKeys.profile_version,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
        ),
      ).tr(args: [Environments.appVersion, Environments.appBuild]),
    );
  }
}
