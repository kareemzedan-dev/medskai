import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:flutter_app/app/helper/function_helper.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/learning/lesson_nav_buttons.dart';
import 'package:flutter_app/app/view/components/learning/review-quiz.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class LearningResult extends StatelessWidget with GetItMixin {
  final LearningLessonModel data;
  LearningResult({super.key, required this.data});
  final courseStore = locator<CourseStore>();

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
                child: ReviewQuiz(
                    data: data, onClose: () => Navigator.pop(context))),
          );
        },
      );
    }

    final colors = context.kaiColors;
    return GetBuilder<LearningController>(builder: (value) {
      String result =
          (data.results?.results?["result"] is num ? (data.results!.results!["result"] as num).round().toString() : "0");
      String passingGrade =
          data.results?.results?["passing_grade"].toString() ?? "";
      debugPrint('data: ${data.results?.results}');

      bool isFailed = data.results?.results?["graduation"] == 'failed';

      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B39BF).withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CircularPercentIndicator(
                    radius: 70,
                    percent: ((data.results?.results?["result"] is num ? (data.results!.results!["result"] as num).round() : 0) / 100).clamp(0.0, 1.0),
                    lineWidth: 10,
                    backgroundColor: colors.sectionBg,
                    progressColor:
                        isFailed ? MedsKaiColors.error : MedsKaiColors.info,
                    center: Text(
                      "${data.results?.results?["result"] is num ? (data.results!.results!["result"] as num).round() : 0}%",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(LocaleKeys.learningScreen_quiz_result_title),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helper.handleTranslationsGraduationText(
                            data.results?.results?["graduationText"]?.toString() ?? ""),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          color: isFailed
                              ? MedsKaiColors.error
                              : MedsKaiColors.info,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                if (isFailed)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: MedsKaiColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tr(LocaleKeys.reviewQuiz_graduation,
                          args: [result, passingGrade]),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        color: MedsKaiColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                _buildResultRow(
                  tr(LocaleKeys.learningScreen_quiz_result_questions),
                  data.results?.results?['question_count']?.toString() ?? '0',
                  colors,
                ),
                _buildResultRow(
                  tr(LocaleKeys.learningScreen_quiz_result_correct),
                  data.results?.results?['question_correct']?.toString() ?? '0',
                  colors,
                ),
                _buildResultRow(
                  tr(LocaleKeys.learningScreen_quiz_result_wrong),
                  data.results?.results?['question_wrong']?.toString() ?? '0',
                  colors,
                ),
                _buildResultRow(
                  tr(LocaleKeys.learningScreen_quiz_result_skipped),
                  data.results?.results?['question_empty']?.toString() ?? '0',
                  colors,
                ),
                _buildResultRow(
                  tr(LocaleKeys.learningScreen_quiz_result_points),
                  data.results?.results?['user_mark']?.toString() ?? '0',
                  colors,
                ),
                _buildResultRow(
                  tr(LocaleKeys.learningScreen_quiz_result_timespent),
                  data.results?.results?['time_spend']?.toString() ?? '0:00',
                  colors,
                ),
                 const SizedBox(height: 24),
                 Wrap(
                   spacing: 12,
                   runSpacing: 12,
                   alignment: WrapAlignment.center,
                   children: [
                     if ((data.results?.retake_count == -1 ||
                         (data.results?.retake_count != null &&
                             data.results?.retaken != null &&
                             ((data.results?.retake_count ?? 0) -
                                     (data.results?.retaken ?? 0) >
                                 0))))
                       ElevatedButton(
                           onPressed: () => {value.onStartQuiz()},
                           style: ElevatedButton.styleFrom(
                             backgroundColor: MedsKaiColors.error,
                             foregroundColor: MedsKaiColors.white,
                             padding: const EdgeInsets.symmetric(
                                 horizontal: 24, vertical: 14),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(12),
                             ),
                             elevation: 0,
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Text(
                                 tr(LocaleKeys
                                     .learningScreen_quiz_result_btnRetake),
                                 style: const TextStyle(
                                   fontFamily: 'Manrope',
                                   fontWeight: FontWeight.w600,
                                   fontSize: 14,
                                 ),
                               ),
                               const SizedBox(width: 4),
                               if ((data.results?.retake_count ?? 0).toString() ==
                                   "-1")
                                 Text(
                                   tr(LocaleKeys
                                       .learningScreen_quiz_result_btnRetakeUnlimited),
                                   style: const TextStyle(
                                     fontFamily: 'Manrope',
                                     fontWeight: FontWeight.w600,
                                     fontSize: 14,
                                   ),
                                 ),
                               if ((data.results?.retake_count ?? 0).toString() !=
                                   "-1")
                                 Text(
                                   "(" +
                                       ((data.results?.retake_count ?? 0) -
                                               (data.results?.retaken ?? 0))
                                           .toString() +
                                       ")",
                                   style: const TextStyle(
                                     fontFamily: 'Manrope',
                                     fontWeight: FontWeight.w600,
                                     fontSize: 14,
                                   ),
                                 ),
                             ],
                           )),
                     ElevatedButton(
                       onPressed: showReviewQuizModal,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: MedsKaiColors.accent,
                         foregroundColor: colors.textPrimary,
                         padding: const EdgeInsets.symmetric(
                             horizontal: 24, vertical: 14),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                         elevation: 0,
                       ),
                       child: Text(
                         tr(LocaleKeys.learningScreen_quiz_result_btnReview),
                         style: const TextStyle(
                           fontFamily: 'Manrope',
                           fontWeight: FontWeight.w700,
                           fontSize: 14,
                         ),
                       ),
                     )
                   ],
                 ),
                 // Next / Previous Lecture navigation after quiz
                 LessonNavButtons(
                   previousLesson: value.previousLesson,
                   nextLesson: value.nextLesson,
                   onPrevious: value.onPrevious,
                   onNext: value.onNext,
                 ),
               ])),
         ],
       );
     });
   }

  Widget _buildResultRow(String label, String value, MedsKaiThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
