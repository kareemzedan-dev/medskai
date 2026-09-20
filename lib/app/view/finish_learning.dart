import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/learning/learning-assignment.dart';
import 'package:flutter_app/app/view/components/learning/learning-lesson.dart';
import 'package:flutter_app/app/view/components/learning/learning-quiz.dart';
import 'package:flutter_app/app/view/components/learning/learning-start-quiz.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:indexed/indexed.dart';

class FinishLearningScreen extends StatefulWidget
    with GetItStatefulWidgetMixin {
  FinishLearningScreen({Key? key}) : super(key: key);

  @override
  State<FinishLearningScreen> createState() => _FinishLearningState();
}

class _FinishLearningState extends State<FinishLearningScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final courseStore = locator<CourseStore>();
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<LearningController>(builder: (value) {
      if (value.data.id == null) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.background,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(MedsKaiColors.primary),
            ),
          ),
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
                    height: (200 / 375) * screenWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MedsKaiColors.success.withOpacity(0.12),
                          MedsKaiColors.primary.withOpacity(0.06),
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
                  SafeArea(
                    bottom: false,
                    child: Container(
                      height: 60.0,
                      width: screenWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6B39BF).withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.menu_rounded,
                                color: colors.textPrimary,
                                size: 22,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6B39BF).withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: colors.textPrimary,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => value.refreshData(),
                      color: MedsKaiColors.primary,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (value.isLesson)
                              LearningLesson(
                                data: value.data,
                              ),
                            if (value.isQuiz &&
                                !value.isStartQuiz &&
                                value.data.results?.status == '')
                              LearningQuiz(
                                  data: value.data, dataQuiz: value.dataQuiz),
                            if (value.isAssignment)
                              LearningAssignment(id: value.id),
                            if (value.isStartQuiz && value.isQuiz)
                              LearningStartQuiz(
                                data: value.data,
                                dataQuiz: value.dataQuiz,
                                itemQuestion: value.itemQuestion,
                              ),
                            if (value.data.can_finish_course == true &&
                                value.isQuiz)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                margin: const EdgeInsets.only(top: 30),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: value.onFinishCourse,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MedsKaiColors.success,
                                      foregroundColor: MedsKaiColors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      tr(LocaleKeys.learningScreen_finishCourse),
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
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
            ],
          ),
        );
      }
    });
  }
}
