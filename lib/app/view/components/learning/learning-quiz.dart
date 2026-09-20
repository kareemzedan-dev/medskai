import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:flutter_app/app/helper/function_helper.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class LearningQuiz extends StatelessWidget with GetItMixin {
  final LearningLessonModel data;
  final QuizModel dataQuiz;

  LearningQuiz({super.key, required this.data, required this.dataQuiz});

  final courseStore = locator<CourseStore>();

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<LearningController>(builder: (value) {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 20,
                      color: MedsKaiColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Helper.handleTranslationsDuration(data.duration.toString()) ?? "",
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        color: MedsKaiColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  data.name ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      tr(LocaleKeys.learningScreen_quiz_questionCount),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.questions != null && data.questions != null
                          ? data.questions!.length.toString()
                          : "0",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      tr(LocaleKeys.learningScreen_quiz_passingGrade),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.meta_data?.lp_passing_grade != null &&
                              data.meta_data?.lp_passing_grade != 0
                          ? "${data.meta_data!.lp_passing_grade}%"
                          : "0%",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                child: HtmlWidget(
                  data.content.toString(),
                  textStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MedsKaiColors.success,
                    foregroundColor: MedsKaiColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: value.onStartQuiz,
                  child: Text(
                    tr(LocaleKeys.learningScreen_quiz_btnStart),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ));
    });
  }
}
