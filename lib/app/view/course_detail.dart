import 'dart:ui' as ui;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/wishlist_store.dart';
import 'package:flutter_app/app/backend/models/instructor-model.dart';
import 'package:flutter_app/app/controller/course_detail_controller.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/payment_controller.dart';
import 'package:flutter_app/app/helper/function_helper.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';
import 'package:flutter_app/app/view/components/skeleton/skeleton_widgets.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_app/app/util/orientation_service.dart';
import 'package:flutter_app/app/view/components/accordion-lesson.dart';
import 'package:fwfh_just_audio/fwfh_just_audio.dart';
import 'package:fwfh_webview/fwfh_webview.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:indexed/indexed.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  CourseDetailScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late double screenWidth;
  late double screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  final courseStore = locator<CourseStore>();
  WishlistStore get wishlistStore => Get.find<WishlistStore>();
  CoursesController get courseController => Get.find<CoursesController>();
  PaymentController get paymentController => Get.find<PaymentController>();
  HomeController get homeController => Get.find<HomeController>();
  CourseDetailController get courseDetailController =>
      Get.find<CourseDetailController>();

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void initState() {
    final args = Get.arguments;
    if (args != null &&
        args is List &&
        args.length > 1 &&
        args[1] == 'reloadPage') refreshData();
    OrientationService.unlockAll();
    super.initState();
  }

  @override
  void dispose() {
    OrientationService.lockPortrait();
    super.dispose();
  }

  refreshData() async {
    await courseDetailController.refreshData();
  }

  void onNaviInstructor(value) {
    UserInstructorModel instructor = UserInstructorModel.fromJson(value);
    Get.toNamed(AppRouter.getInstructorDetailRoute(), arguments: [instructor]);
  }

  Widget renderItemRating(value, MedsKaiThemeColors colors) {
    if (value.review == null ||
        value.review["reviews"] == null ||
        value.review["reviews"]["reviews"] == null) {
      return Container();
    }
    final reviewsData = value.review["reviews"]["reviews"];
    final reviews = reviewsData is List ? reviewsData : [];
    final reviewData = value.review["reviews"];
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reviews.length,
        itemBuilder: (context, index) => Container(
          key: ValueKey(index),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.sectionBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      reviews[index]["display_name"]?.toString() ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  RatingBar.builder(
                    ignoreGestures: true,
                    initialRating: double.tryParse(
                            reviews[index]["rate"]?.toString() ?? '0') ??
                        0.0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 14,
                    unratedColor: colors.border,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: MedsKaiColors.accent,
                    ),
                    onRatingUpdate: (rating) {},
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                reviews[index]["title"]?.toString() ?? '',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reviews[index]["content"]?.toString() ?? '',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      if (reviews.isNotEmpty &&
          (reviewData["paged"] ?? 0) < (reviewData["pages"] ?? 0))
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRouter.getReview(), arguments: [value.courseId]);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: MedsKaiColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(LocaleKeys.singleCourse_showAllReview),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MedsKaiColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: MedsKaiColors.primary,
                ),
              ],
            ),
          ),
        )
    ]);
  }

  Widget renderComment(value, MedsKaiThemeColors colors) {
    if (value.review != null && value.review["can_review"] == true) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(LocaleKeys.singleCourse_leaveAReview),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr(LocaleKeys.singleCourse_leaveAReviewDescription),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            // Title field
            Text(
              tr(LocaleKeys.singleCourse_reviewTitle),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.sectionBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: tr(LocaleKeys.singleCourse_reviewTitle),
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: colors.textHint,
                ),
              ),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: colors.textPrimary,
              ),
              controller: value.titleController,
            ),
            const SizedBox(height: 16),
            // Rating
            Text(
              tr(LocaleKeys.singleCourse_reviewRating),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 32,
              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: MedsKaiColors.accent,
              ),
              unratedColor: colors.border,
              onRatingUpdate: (rating) {
                value.rating = rating;
              },
            ),
            const SizedBox(height: 16),
            // Content field
            Text(
              tr(LocaleKeys.singleCourse_reviewContent),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.sectionBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                hintText: tr(LocaleKeys.singleCourse_reviewContent),
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: colors.textHint,
                ),
              ),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: colors.textPrimary,
              ),
              controller: value.contentController,
            ),
            const SizedBox(height: 20),
            // Submit button (using #673ABF from website)
            GestureDetector(
              onTap: () => value.submitRating(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MedsKaiColors.buttonColor,
                      MedsKaiColors.buttonColor.withOpacity(0.85)
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(10), // 8-10px from website
                  boxShadow: [
                    BoxShadow(
                      color: MedsKaiColors.buttonColor.withOpacity(0.85),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  tr(LocaleKeys.singleCourse_reviewSubmit),
                  style: const TextStyle(
                    color: MedsKaiColors.white,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildPriceDisplay(CourseDetailController value) {
    if (!kIsWeb && Platform.isIOS) {
      return const SizedBox.shrink();
    }
    
    final maxPriceWidth = screenWidth - 64;
    final isCompact = screenWidth < 390;

    String priceText(String? rendered, dynamic fallback) {
      final normalized = rendered?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
      return '\$$fallback';
    }

    Widget scaledPriceText(String text, TextStyle style) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: style,
        ),
      );
    }

    if (value.course.on_sale == true) {
      final salePrice =
          priceText(value.course.sale_price_rendered, value.course.sale_price);
      final originPrice = priceText(
          value.course.origin_price_rendered, value.course.origin_price);
      const saleStyle = TextStyle(
        fontFamily: 'Manrope',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: MedsKaiColors.white,
      );
      const originStyle = TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
        decoration: TextDecoration.lineThrough,
        decorationColor: Colors.white70,
      );

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxPriceWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: MedsKaiColors.price,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: MedsKaiColors.price.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isCompact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    scaledPriceText(salePrice, saleStyle),
                    const SizedBox(height: 2),
                    scaledPriceText(originPrice, originStyle),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: scaledPriceText(salePrice, saleStyle)),
                    const SizedBox(width: 10),
                    Flexible(child: scaledPriceText(originPrice, originStyle)),
                  ],
                ),
        ),
      );
    } else if ((value.course.price ?? 0) > 0) {
      final price = priceText(value.course.price_rendered, value.course.price);

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxPriceWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: MedsKaiColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: MedsKaiColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: scaledPriceText(
            price,
            const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: MedsKaiColors.white,
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: MedsKaiColors.success,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: MedsKaiColors.success.withOpacity(0.85),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          tr(LocaleKeys.free),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MedsKaiColors.white,
          ),
        ),
      );
    }
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    required MedsKaiThemeColors colors,
  }) {
    return Semantics(
      button: true,
      label: 'Share',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.sectionBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 14,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    IconData? icon,
    required VoidCallback onPressed,
    Gradient? gradient,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    MedsKaiColors.buttonColor,
                    MedsKaiColors.buttonColor.withOpacity(0.85)
                  ], // #673ABF from website
                ),
            borderRadius: BorderRadius.circular(10), // 8-10px from website
            boxShadow: [
              BoxShadow(
                color: (gradient != null
                        ? MedsKaiColors.success
                        : MedsKaiColors.buttonColor)
                    .withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: MedsKaiColors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: MedsKaiColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
    required MedsKaiThemeColors colors,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: colors.sectionBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<CourseDetailController>(builder: (value) {
      if (value.hasError) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.background,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: colors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      value.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: value.retryLoadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MedsKaiColors.primary,
                        foregroundColor: MedsKaiColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(tr(LocaleKeys.common_retry)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      if (value.course.name == null) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.background,
          body: const SkeletonCourseDetail(),
        );
      } else {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.background,
          drawerEnableOpenDragGesture: false,
          body: Stack(
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
                    height: (180 / 375) * screenWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MedsKaiColors.primary.withOpacity(0.1),
                          colors.sectionBg,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  // Header
                  Container(
                    height: 90.0,
                    width: screenWidth,
                    padding: EdgeInsets.fromLTRB(
                        8, MediaQuery.of(context).viewPadding.top, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Back button
                        Semantics(
                          button: true,
                          label: 'Go back',
                          child: GestureDetector(
                            onTap: () {
                              homeController.getOverview();
                              value.onBack();
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6B39BF)
                                          .withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: colors.textPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Title - course name
                        Expanded(
                          child: Text(
                            value.course.name ??
                                tr(LocaleKeys.singleCourse_title),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: colors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => value.refreshData(),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        scrollDirection: Axis.vertical,
                        child: Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              // Course Image Section
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(children: [
                                    Observer(
                                      builder: (_) => Container(
                                        width: screenWidth - 32,
                                        height: (220 / 375) * screenWidth,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: (courseStore.detail?.image
                                                            ?.isNotEmpty ==
                                                        true &&
                                                    !(courseStore.detail?.image
                                                            ?.contains(
                                                                'placeholder') ??
                                                        true))
                                                ? CachedNetworkImageProvider(
                                                    courseStore.detail!.image!)
                                                : const AssetImage(
                                                    "assets/images/logo_horizontal_light.png"),
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.04),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Wishlist button
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Observer(
                                        builder: (_) {
                                          final isWishlisted =
                                              wishlistStore.isInWishlist(
                                                  courseStore.detail?.id ?? 0);
                                          return Semantics(
                                            button: true,
                                            label: isWishlisted
                                                ? 'Remove from wishlist'
                                                : 'Add to wishlist',
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (courseStore.detail !=
                                                    null) {
                                                  await value.onToggleWishlist(
                                                      courseStore.detail!);
                                                  courseController
                                                      .refreshScreen();
                                                  homeController
                                                      .refreshScreen();
                                                }
                                              },
                                              child: Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: isWishlisted
                                                      ? MedsKaiColors.error
                                                      : colors.surface,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.04),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  isWishlisted
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: isWishlisted
                                                      ? MedsKaiColors.white
                                                      : colors.textSecondary,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // Course title overlay
                                    // Positioned(
                                    //   bottom: 16,
                                    //   left: 16,
                                    //   right: 16,
                                    //   child: Text(
                                    //     value.course.name ?? '',
                                    //     maxLines: 2,
                                    //     overflow: TextOverflow.ellipsis,
                                    //     style: const TextStyle(
                                    //       fontFamily: 'Manrope',
                                    //       fontSize: 18,
                                    //       fontWeight: FontWeight.w700,
                                    //       color: MedsKaiColors.white,
                                    //       height: 1.3,
                                    //     ),
                                    //   ),
                                    // ),
                                  ]),
                                ),
                              ),
                              // Course Info Section
                              Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // Duration and students
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        // Duration chip
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: colors.sectionBg,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.access_time_rounded,
                                                size: 14,
                                                color: MedsKaiColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                Helper
                                                    .handleTranslationsDuration(
                                                        value.course.duration ??
                                                            ''),
                                                style: TextStyle(
                                                  fontFamily: 'Manrope',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Price display
                                    _buildPriceDisplay(value),
                                  ],
                                ),
                              ),
                              // Visit Website Button
                              if (!(!kIsWeb && Platform.isIOS) && (value.course.price ?? 0) > 0 &&
                                  value.course.course_data?.status == "")
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
                                  child: Semantics(
                                    button: true,
                                    label: 'Visit Website to Purchase',
                                    child: GestureDetector(
                                      onTap: () {
                                        if (value.course.permalink != null && value.course.permalink!.isNotEmpty) {
                                          _launchUrl(value.course.permalink!);
                                        } else {
                                          _launchUrl("https://medskai.com/courses/");
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: colors.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: MedsKaiColors.primary.withOpacity(0.5),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: MedsKaiColors.primary.withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.open_in_browser_rounded,
                                              size: 20,
                                              color: MedsKaiColors.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                tr(LocaleKeys.singleCourse_btnViewOnWebsite),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Manrope',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: MedsKaiColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              // Overview Section
                              value.course.content != null
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 4,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: MedsKaiColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                tr(LocaleKeys
                                                    .singleCourse_overview),
                                                style: TextStyle(
                                                  fontFamily: 'Manrope',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: colors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Directionality(
                                            textDirection: ui.TextDirection.ltr,
                                            child: HtmlWidget(
                                              value.course.content.toString(),
                                              factoryBuilder: () =>
                                                  MyWidgetFactory(),
                                              textStyle: TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 14,
                                                color: colors.textSecondary,
                                                fontWeight: FontWeight.w400,
                                                height: 1.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(height: 16),
                              // Curriculum Section
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: MedsKaiColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          tr(LocaleKeys
                                              .singleCourse_curriculum),
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    value.course.sections != null
                                        ? AccordionLesson(
                                            data: value.course.sections!,
                                            indexLesson:
                                                value.handleGetIndexLesson(),
                                            onNavigate: (item) => {
                                              value.onNavigateLearning(item, 0),
                                              _scaffoldKey.currentState
                                                  ?.closeDrawer()
                                            },
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Instructor Section
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: MedsKaiColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          tr(LocaleKeys
                                              .singleCourse_instructor),
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () => onNaviInstructor(
                                          value.course.instructor),
                                      child: Row(
                                        children: [
                                          // Avatar
                                          value.course.instructor != null &&
                                                  value.course.instructor[
                                                          "avatar"] !=
                                                      null &&
                                                  value.course.instructor[
                                                          "avatar"] !=
                                                      "" &&
                                                  value.course.instructor[
                                                          "avatar"] !=
                                                      false
                                              ? Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    border: Border.all(
                                                      color: MedsKaiColors
                                                          .primary
                                                          .withOpacity(0.1),
                                                      width: 2,
                                                    ),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image:
                                                          CachedNetworkImageProvider(
                                                              value.course
                                                                      .instructor[
                                                                  "avatar"]),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    color: colors.sectionBg,
                                                  ),
                                                  child: Icon(
                                                    Icons.person_rounded,
                                                    size: 30,
                                                    color: colors.textSecondary,
                                                  ),
                                                ),
                                          const SizedBox(width: 16),
                                          // Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  value.course
                                                          .instructor["name"] ??
                                                      '',
                                                  style: TextStyle(
                                                    fontFamily: 'Manrope',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: colors.textPrimary,
                                                  ),
                                                ),
                                                if (value.course.instructor[
                                                        "description"] !=
                                                    null) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    value.course.instructor[
                                                        "description"],
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: 'Manrope',
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          colors.textSecondary,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 10),
                                                // Social links
                                                Row(
                                                  children: [
                                                    _buildSocialButton(
                                                      icon:
                                                          Icons.facebook,
                                                      colors: colors,
                                                      onTap: () {
                                                        if (value.course.instructor[
                                                                    "social"] !=
                                                                null &&
                                                            value.course.instructor[
                                                                        "social"]
                                                                    [
                                                                    "facebook"] !=
                                                                null) {
                                                          _launchUrl(value
                                                                      .course
                                                                      .instructor[
                                                                  "social"]
                                                              ["facebook"]);
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _buildSocialButton(
                                                      icon:
                                                          Icons.alternate_email,
                                                      colors: colors,
                                                      onTap: () {
                                                        if (value.course.instructor[
                                                                    "social"] !=
                                                                null &&
                                                            value.course.instructor[
                                                                        "social"]
                                                                    [
                                                                    "twitter"] !=
                                                                null) {
                                                          _launchUrl(value
                                                                      .course
                                                                      .instructor[
                                                                  "social"]
                                                              ["twitter"]);
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _buildSocialButton(
                                                      icon:
                                                          Icons.smart_display,
                                                      colors: colors,
                                                      onTap: () {
                                                        if (value.course.instructor[
                                                                    "social"] !=
                                                                null &&
                                                            value.course.instructor[
                                                                        "social"]
                                                                    [
                                                                    "youtube"] !=
                                                                null) {
                                                          _launchUrl(value
                                                                      .course
                                                                      .instructor[
                                                                  "social"]
                                                              ["youtube"]);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 16,
                                            color: colors.textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Review Section
                              if (value.review != null)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: MedsKaiColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            tr(LocaleKeys.singleCourse_review),
                                            style: TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      // Rating summary card
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              MedsKaiColors.primary
                                                  .withOpacity(0.1),
                                              colors.sectionBg,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              (value.review["rated"] is num
                                                  ? (value.review["rated"]
                                                          as num)
                                                      .toStringAsFixed(1)
                                                  : '0.0'),
                                              style: const TextStyle(
                                                fontFamily: 'Manrope',
                                                color: MedsKaiColors.accent,
                                                fontSize: 42,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            RatingBar.builder(
                                              ignoreGestures: true,
                                              initialRating: double.tryParse(
                                                      value.review["rated"]
                                                              ?.toString() ??
                                                          '0') ??
                                                  0.0,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemSize: 24,
                                              unratedColor: colors.border,
                                              itemBuilder: (context, _) =>
                                                  const Icon(
                                                Icons.star_rounded,
                                                color: MedsKaiColors.accent,
                                              ),
                                              onRatingUpdate: (rating) {},
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              '${value.review["total"]} ${tr(LocaleKeys.singleCourse_rating)}',
                                              style: TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: colors.textSecondary,
                                              ),
                                            ),
                                            if (value
                                                .reviewMessage.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Text(
                                                value.reviewMessage,
                                                style: TextStyle(
                                                  fontFamily: 'Manrope',
                                                  color: colors.textSecondary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      renderItemRating(value, colors),
                                      renderComment(value, colors),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                            ])),
                      ),
                    ),
                  )
                ],
              ),
              // Bottom Action Bar
              Indexed(
                index: 1,
                child: Positioned(
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Enrolled - Continue learning
                        if (value.course.course_data?.status == 'enrolled')
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Progress indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: colors.sectionBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.trending_up_rounded,
                                        size: 18,
                                        color: MedsKaiColors.success,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${value.course.course_data?.result?.result}%',
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Continue button
                                Expanded(
                                  child: _buildPrimaryButton(
                                    label:
                                        tr(LocaleKeys.singleCourse_btnContinue),
                                    icon: Icons.play_arrow_rounded,
                                    onPressed: value.start,
                                  ),
                                ),
                              ],
                            ),
                          )
                        // Purchased - Start now
                        else if (value.course.course_data?.status ==
                            'purchased')
                          Expanded(
                            child: _buildPrimaryButton(
                              label: tr(LocaleKeys.singleCourse_btnStartNow),
                              icon: Icons.play_arrow_rounded,
                              onPressed: () {
                                value.onEnroll();
                              },
                            ),
                          )
                        // Not purchased - Show purchase options
                        else if ((value.course.price ?? 0) > 0 &&
                            value.course.course_data?.status == "")
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              decoration: BoxDecoration(
                                color: colors.sectionBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                "شراء الدورات غير متاح داخل التطبيق حالياً",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        // Free course - Enroll
                        else if (value.course.price == 0 &&
                            value.course.course_data?.status != 'finished')
                          Expanded(
                            child: _buildPrimaryButton(
                              label: tr(LocaleKeys.singleCourse_btnStartNow),
                              icon: Icons.play_arrow_rounded,
                              gradient: LinearGradient(
                                colors: [
                                  MedsKaiColors.success,
                                  MedsKaiColors.success.withOpacity(0.85)
                                ],
                              ),
                              onPressed: () {
                                value.onEnroll();
                              },
                            ),
                          ),
                        // Finished - Show result
                        if (value.course.course_data?.status == 'finished' &&
                            value.course.course_data?.graduation != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: value
                                              .course.course_data?.graduation ==
                                          'passed'
                                      ? [
                                          MedsKaiColors.success
                                              .withOpacity(0.85),
                                          MedsKaiColors.success
                                              .withOpacity(0.85)
                                        ]
                                      : [
                                          MedsKaiColors.error.withOpacity(0.1),
                                          MedsKaiColors.error.withOpacity(0.1)
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: value.course.course_data
                                                  ?.graduation ==
                                              'passed'
                                          ? MedsKaiColors.success
                                          : MedsKaiColors.error,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      value.course.course_data?.graduation ==
                                              'passed'
                                          ? Icons.check_rounded
                                          : Icons.close_rounded,
                                      color: MedsKaiColors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    value.course.course_data?.graduation ==
                                            'passed'
                                        ? tr(LocaleKeys.singleCourse_passed)
                                        : tr(LocaleKeys.singleCourse_failed),
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: value.course.course_data?.graduation ==
                                              'passed'
                                          ? MedsKaiColors.white
                                          : MedsKaiColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Retake option
                        if (value.course.course_data?.status == 'finished' &&
                            value.course.can_retake == true) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPrimaryButton(
                              label: tr(LocaleKeys.singleCourse_btnRetake),
                              icon: Icons.refresh_rounded,
                              onPressed: value.onRetake,
                            ),
                          ),
                        ],
                        // Finished without retake
                        if (value.course.course_data?.status == 'finished' &&
                            value.course.can_retake == false)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              alignment: Alignment.center,
                              child: Text(
                                tr(LocaleKeys.singleCourse_finished),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}

class MyWidgetFactory extends WidgetFactory
    with WebViewFactory, JustAudioFactory {
  @override
  bool get webViewMediaPlaybackAlwaysAllow => true;
}
