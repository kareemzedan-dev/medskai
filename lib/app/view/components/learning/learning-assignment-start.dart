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
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../backend/models/lesson-model.dart';

class LearningAssignmentStart extends StatelessWidget with GetItMixin {
  final LessonsAssignment data;
  final LearningController value;
  final ItemLesson itemLesson;

  LearningAssignmentStart(
      {super.key,
      required this.data,
      required this.value,
      required this.itemLesson});

  final courseStore = locator<CourseStore>();

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    void showReviewQuizModal() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              insetPadding: EdgeInsets.zero,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Text(
                  tr(LocaleKeys.learningScreen_assignment_timeRemaining),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                  ),
                ),
              ));
        },
      );
    }

    final colors = context.kaiColors;
    return GetBuilder<LearningController>(builder: (value) {
      return Column(
        children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      tr(LocaleKeys.learningScreen_assignment_title),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      tr(LocaleKeys.learningScreen_assignment_acceptAllowed),
                      data.files_amount.toString(),
                      colors,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      tr(LocaleKeys.learningScreen_assignment_durations),
                      Helper.handleTranslationsDuration(
                          data.duration?.format?.toString() ?? ''),
                      colors,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      tr(LocaleKeys.learningScreen_assignment_passingGrade),
                      tr(LocaleKeys.learningScreen_assignment_point)
                          .replaceAll('{{point}}', data.passing_grade.toString()),
                      colors,
                    ),
                    if (data.introdution.toString() != '')
                      const SizedBox(height: 24),
                    if (data.introdution.toString() != '')
                      Text(
                        tr(LocaleKeys.learningScreen_assignment_overview),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    if (data.introdution.toString() != '')
                      const SizedBox(height: 14),
                    HtmlWidget(
                      data.introdution.toString(),
                      textStyle: TextStyle(
                        fontFamily: 'Manrope',
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          value.onStartAssignment(itemLesson.id.toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MedsKaiColors.accent,
                          foregroundColor: colors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          tr(LocaleKeys.learningScreen_assignment_start),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  ])),
        ],
      );
    });
  }

  Widget _buildInfoRow(String label, String value, MedsKaiThemeColors colors) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            color: colors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Manrope',
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
