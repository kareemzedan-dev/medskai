import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/courses_controller.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/categories_course.dart';
import 'package:flutter_app/app/view/components/item-course.dart';
import 'package:flutter_app/app/view/components/skeleton/skeleton_widgets.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_app/app/view/components/course_filter_sheet.dart';
import 'package:get/get.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late double screenWidth;
  late double screenHeight;
  HomeController get homeController => Get.find<HomeController>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.kaiColors;
    double top = MediaQuery.of(context).viewPadding.top;
    return GetBuilder<CoursesController>(builder: (value) {
      if (value.hasError && value.coursesList.isEmpty) {
        return Scaffold(
          backgroundColor: colors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: MedsKaiColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 40,
                    color: MedsKaiColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tr(LocaleKeys.error),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(tr(LocaleKeys.common_retry)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MedsKaiColors.primary,
                    foregroundColor: MedsKaiColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          child: Column(
              children: <Widget>[
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        tr(LocaleKeys.courses_title),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      // Filter button
                      GestureDetector(
                        onTap: () => showCourseFilterSheet(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.sectionBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                color: value.activeFilterCount > 0
                                    ? MedsKaiColors.primary
                                    : colors.textPrimary,
                                size: 20,
                              ),
                              if (value.activeFilterCount > 0)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: MedsKaiColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: colors.cardBg, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${value.activeFilterCount}',
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: MedsKaiColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Search button
                      GestureDetector(
                        onTap: () => value.onSearch(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.sectionBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: colors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Search indicator and filter row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (value.search != "")
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: MedsKaiColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${tr(LocaleKeys.courses_searching)} ${value.search}',
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: MedsKaiColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => value.setKeywordSearch(""),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: MedsKaiColors.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: MedsKaiColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(),
                      // Filter dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.border,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          hint: Container(),
                          value: value.dropdownValue,
                          iconSize: 0.0,
                          underline: const SizedBox(),
                          isDense: true,
                          icon: null,
                          onChanged: (String? v) {
                            if (v != null) value.onFilterValue(v);
                          },
                          items: value.list
                              .map<DropdownMenuItem<String>>((dynamic value) {
                            return DropdownMenuItem<String>(
                              value: value['key'].toString(),
                              child: Text(
                                value['label'],
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          alignment: Alignment.centerRight,
                          selectedItemBuilder: (BuildContext context) {
                            return value.list.map<Widget>((dynamic item) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item['label'],
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      color: colors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: colors.textSecondary,
                                    size: 20,
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Categories with skeleton
                value.isLoadingCategories
                    ? const SkeletonCategoryList()
                    : CategoriesCourse(categoriesList: value.cateList),
                const SizedBox(height: 16),
                // Course list with skeleton during initial loading
                if (value.isInitialLoading)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => const SkeletonCourseCard(),
                        ),
                      ),
                    ),
                  )
                else if (value.coursesList.isNotEmpty)
                  Expanded(
                    child: RefreshIndicator(
                      color: MedsKaiColors.primary,
                      onRefresh: () => value.refreshData(),
                      child: ListView.builder(
                        controller: value.scrollController,
                        padding: const EdgeInsets.only(bottom: 100),
                        physics: const AlwaysScrollableScrollPhysics(),
                        cacheExtent: 500,
                        itemCount: value.coursesList.length +
                            (value.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == value.coursesList.length) {
                            return Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 20),
                                child: const SizedBox(
                                  width: 24.0,
                                  height: 24.0,
                                  child: CircularProgressIndicator(
                                    color: MedsKaiColors.primary,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            );
                          } else if (index < value.coursesList.length) {
                            return Container(
                              key: ValueKey(value.coursesList[index].id ?? index),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ItemCourse(
                                item: value.coursesList[index],
                                onToggleWishlist: () async => {
                                  await value.onToggleWishlist(
                                      value.coursesList[index]),
                                  homeController.refreshScreen(),
                                },
                                courseDetailParser: Get.find(),
                              ),
                            );
                          } else {
                            return _buildEmptyState();
                          }
                        },
                      ),
                    ),
                  )
                // Empty state
                else
                  Expanded(
                    child: Center(
                      child: _buildEmptyState(),
                    ),
                  ),
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
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.sectionBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.school_outlined,
            size: 40,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          tr(LocaleKeys.dataNotFound),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr(LocaleKeys.empty_tryAdjustingSearch),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: colors.textHint,
          ),
        ),
      ],
    );
  }
}
