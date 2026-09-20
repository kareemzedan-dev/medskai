import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../env.dart';

class LearningAssignmentResult extends StatelessWidget with GetItMixin {
  final LessonsAssignment data;

  LearningAssignmentResult({super.key, required this.data});

  final courseStore = locator<CourseStore>();

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
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

    return GetBuilder<LearningController>(builder: (value) {
      int countRetake =
          (value.dataAssignment.retake_count ?? 0) - (value.dataAssignment.retaken ?? 0);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(LocaleKeys.learningScreen_assignment_attachmentFile),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: (value.dataAssignment.attachment.isEmpty)
                              ? Text(
                                  tr(LocaleKeys
                                      .learningScreen_assignment_missingAttachments),
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    color: colors.textSecondary,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    _launchUrl(value
                                        .dataAssignment.attachment[0]['url']);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add_link_sharp,
                                        color: MedsKaiColors.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          value.dataAssignment.attachment[0]
                                              ['name'],
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            color: MedsKaiColors.primary,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      tr(LocaleKeys.learningScreen_assignment_yourAnswer),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 10),
                      child: Text(
                        value.dataAssignment.assignment_answer?.note ?? "",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(LocaleKeys.learningScreen_assignment_yourUploadedFiles),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (value.dataAssignment.assignment_answer?.file != null &&
                        (value.dataAssignment.assignment_answer?.file?.length ?? 0) !=
                            0)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListView.builder(
                                itemCount: value.dataAssignment
                                    .assignment_answer?.file?.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    key: ValueKey(index),
                                    height: 36,
                                    child: GestureDetector(
                                      onTap: () {
                                        _launchUrl(Environments.apiBaseURL +
                                            (value
                                                .dataAssignment
                                                .assignment_answer
                                                ?.file?[index]
                                                .values
                                                .first['url'] ?? ''));
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.link,
                                            size: 16,
                                            color: MedsKaiColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(
                                            value
                                                .dataAssignment
                                                .assignment_answer
                                                ?.file?[index]
                                                .values
                                                .first['filename'] ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              color: MedsKaiColors.primary,
                                            ),
                                          ))
                                        ],
                                      ),
                                    ),
                                  );
                                })
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (countRetake > 0) {
                            value.onRetakeAssignment(value.dataAssignment.id);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MedsKaiColors.error,
                          foregroundColor: MedsKaiColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (countRetake <= 0)
                              Text(
                                tr(LocaleKeys
                                    .learningScreen_quiz_result_btnRetakeUnlimited),
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            if (countRetake > 0)
                              Text(
                                tr(LocaleKeys
                                    .learningScreen_quiz_result_btnRetake),
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            if (countRetake > 0)
                              Text(
                                " (" + countRetake.toString() + ")",
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ])),
        ],
      );
    });
  }
}
