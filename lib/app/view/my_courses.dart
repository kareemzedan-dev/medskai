import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';
import 'package:flutter_app/app/controller/tabs_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/item-my-course.dart';
import 'package:flutter_app/app/view/components/skeleton/skeleton_widgets.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onLogin() {
    Future.delayed(Duration.zero, () {
      Get.offAllNamed(AppRouter.getLoginRoute());
    });
  }

  late double screenWidth;
  late double screenHeight;

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
    return GetBuilder<MyCoursesController>(builder: (value) {
      if (value.hasError && value.coursesList.isEmpty && value.parser.getToken() != '') {
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
                  child: value.isSearch
                      ? _buildSearchBar(value)
                      : _buildHeader(value),
                ),
                const SizedBox(height: 12),
                // Not logged in state
                if (value.parser.getToken() == '')
                  Expanded(
                    child: Center(
                      child: _buildLoginPrompt(),
                    ),
                  ),
                // Filter dropdown for logged in users
                if (value.parser.getToken() != '')
                  _buildFilterRow(value),
                // Course list or empty state
                if (value.parser.getToken() != '')
                  value.isInitialLoading
                      ? Expanded(
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
                                          return ItemMyCourse(
                                            key: ValueKey(value.coursesList[index].id ?? index),
                                            item: value.coursesList[index],
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  ),
                                )
                              : Expanded(
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

  Widget _buildHeader(MyCoursesController value) {
    final colors = context.kaiColors;
    return Row(
      children: [
        Text(
          tr(LocaleKeys.myCourse_title),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (value.parser.getToken() != '')
          GestureDetector(
            onTap: () => value.toggleSearch(true),
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
    );
  }

  Widget _buildSearchBar(MyCoursesController value) {
    final colors = context.kaiColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => value.toggleSearch(false),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: colors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              autofocus: true,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: tr(LocaleKeys.searchScreen_placeholder),
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: colors.textHint,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              controller: value.keywordController,
              onSubmitted: (_) => value.onSearch(),
            ),
          ),
          GestureDetector(
            onTap: () => value.onSearch(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MedsKaiColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 20,
                color: MedsKaiColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(MyCoursesController value) {
    final colors = context.kaiColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Course count
          if (value.coursesList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: MedsKaiColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    size: 16,
                    color: MedsKaiColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${value.coursesList.length} ${value.coursesList.length == 1 ? tr(LocaleKeys.common_courseSingular) : tr(LocaleKeys.common_coursePlural)}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MedsKaiColors.primary,
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
              items: value.list.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item['key'],
                  child: Text(
                    item['label'],
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
                return value.list.map<Widget>((item) {
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
    );
  }

  Widget _buildEmptyState() {
    final colors = context.kaiColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Empty illustration
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MedsKaiColors.primary.withOpacity(0.15),
                MedsKaiColors.primary.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                size: 60,
                color: MedsKaiColors.primary.withOpacity(0.5),
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
                    Icons.search_rounded,
                    size: 18,
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
            tr(LocaleKeys.empty_notEnrolledCourses),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon illustration
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
              Icons.play_circle_rounded,
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
            tr(LocaleKeys.auth_signInEnrolledCourses),
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
