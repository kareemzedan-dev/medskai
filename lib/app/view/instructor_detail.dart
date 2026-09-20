import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/instructor_detail_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/item-course.dart';
import 'package:flutter_app/app/view/components/skeleton/skeleton_widgets.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class InstructorDetailScreen extends StatefulWidget {
  const InstructorDetailScreen({Key? key}) : super(key: key);

  @override
  State<InstructorDetailScreen> createState() => _InstructorDetailScreenState();
}

class _InstructorDetailScreenState extends State<InstructorDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isExpanded = false;

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<InstructorDetailController>(builder: (value) {
      if (value.hasError) {
        return Scaffold(
          backgroundColor: colors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MedsKaiColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.cloud_off,
                    size: 48,
                    color: MedsKaiColors.error,
                  ),
                ),
                const SizedBox(height: 24),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    value.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => value.retryLoadData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MedsKaiColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    tr(LocaleKeys.common_retry),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: colors.background,
        drawerEnableOpenDragGesture: false,
        body: SafeArea(
          child: CustomScrollView(
            controller: value.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── Header bar ───
              SliverToBoxAdapter(
                child: Container(
                  height: 60.0,
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back),
                        color: colors.textPrimary,
                        iconSize: 24,
                      ),
                      Text(
                        tr(LocaleKeys.instructorScreen_title),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),

              // ─── Instructor info ───
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 5),
                          value.instructor?.avatar_url != null &&
                                  value.instructor?.avatar_url != 'null' &&
                                  value.instructor?.avatar_url != ''
                              ? Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            value.instructor?.avatar_url ?? ''),
                                      )))
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      const Color(0xFF707BED).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Color(0xFF707BED),
                                  ),
                                ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(value.instructor?.name ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    )),
                                if (value.instructor?.description != null && value.instructor!.description!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        value.instructor?.description ?? '',
                                        maxLines: isExpanded ? null : 5,
                                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 12,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      if ((value.instructor?.description ?? '').length > 150)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isExpanded = !isExpanded;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                                            child: Text(
                                              isExpanded ? 'Read Less' : 'Read More',
                                              style: TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: MedsKaiColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                              child: Icon(Icons.facebook,
                                  size: 16, color: colors.textSecondary),
                              onTap: () => {
                                    if (value.instructor?.social != null &&
                                        value.instructor?.social["facebook"] !=
                                            null)
                                      _launchUrl(value.instructor
                                              ?.social["facebook"] ??
                                          ''),
                                  }),
                          const SizedBox(width: 10),
                          GestureDetector(
                              child: Icon(Icons.alternate_email,
                                  size: 16, color: colors.textSecondary),
                              onTap: () => {
                                    if (value.instructor?.social != null &&
                                        value.instructor?.social["twitter"] !=
                                            null)
                                      _launchUrl(value.instructor
                                              ?.social["twitter"] ??
                                          ''),
                                  }),
                          const SizedBox(width: 10),
                          GestureDetector(
                              child: Icon(Icons.smart_display,
                                  size: 16, color: colors.textSecondary),
                              onTap: () => {
                                    if (value.instructor?.social != null &&
                                        value.instructor?.social["youtube"] !=
                                            null)
                                      _launchUrl(value.instructor
                                              ?.social["youtube"] ??
                                          ''),
                                  }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (value.instructor?.instructor_data != null &&
                          value.instructor
                                  ?.instructor_data["total_courses"] !=
                              null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                (value.instructor?.instructor_data[
                                            "total_courses"] ??
                                        '')
                                        .toString() +
                                    " " +
                                    tr(LocaleKeys.home_countCourse),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: colors.textPrimary,
                                )),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 15)),

              // ─── Courses list ───
              if (value.isInitialLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const SkeletonCourseCard(),
                    childCount: 3,
                  ),
                )
              else if (value.coursesList.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined,
                            size: 64, color: colors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          tr(LocaleKeys.empty_noCourses),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == value.coursesList.length) {
                        return const Center(
                          child: SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              color: MedsKaiColors.primary,
                            ),
                          ),
                        );
                      } else if (index < value.coursesList.length) {
                        return Container(
                          key:
                              ValueKey(value.coursesList[index].id ?? index),
                          margin:
                              const EdgeInsetsDirectional.only(bottom: 20),
                          child: ItemCourse(
                            item: value.coursesList[index],
                            courseDetailParser: Get.find(),
                            onToggleWishlist: () => value
                                .onToggleWishlist(value.coursesList[index]),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                    childCount: value.coursesList.length +
                        (value.isLoadingMore ? 1 : 0),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      );
    });
  }
}
