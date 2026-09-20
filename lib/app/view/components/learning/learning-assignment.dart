import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_app/app/helper/validators.dart';
import '../countdown.dart';
import 'learning-assignment-result.dart';

class _LearningAssignment extends State<LearningAssignment> {
  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  final courseStore = locator<CourseStore>();
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  void initState() {
    LearningController learningController = Get.find<LearningController>();
    learningController.handleResetFileAssignment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<LearningController>(builder: (value) {
      num answerFile =
          value.dataAssignment.assignment_answer?.file?.length ?? 0;
      var countFile = (value.dataAssignment.files_amount ?? 0) - answerFile;
      final results = value.dataAssignment.results;
      if (results == null || results.isEmpty) {
        return Container();
      }
      return results['status'] == "completed"
          ? LearningAssignmentResult(
              data: value.dataAssignment,
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timer container
                    Container(
                      width: screenWidth,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            MedsKaiColors.info.withOpacity(0.2),
                            MedsKaiColors.info.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: MedsKaiColors.info.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Countdown(
                            duration: value.dataAssignment.duration != null
                                ? value.dataAssignment.duration
                                        ?.time_remaining ??
                                    0
                                : 0,
                            callBack: () {
                              value.onSaveOrSendAssignment(
                                  value.dataAssignment.id, 'send');
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr(LocaleKeys
                                .learningScreen_assignment_timeRemaining),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Content
                    HtmlWidget(
                      value.dataAssignment.content ?? "",
                      textStyle: TextStyle(
                        fontFamily: 'Manrope',
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Attachment file row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          tr(LocaleKeys
                              .learningScreen_assignment_attachmentFile),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        value.dataAssignment.attachment.isEmpty
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
                                  _launchUrl(
                                      value.dataAssignment.attachment.isEmpty
                                          ? ""
                                          : value.dataAssignment.attachment[0]
                                              ['url']);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_link_sharp,
                                      color: MedsKaiColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: 190,
                                      child: Text(
                                        value.dataAssignment.attachment.isEmpty
                                            ? ""
                                            : value.dataAssignment.attachment[0]
                                                ['name'],
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          color: MedsKaiColors.primary,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Answer label
                    Text(
                      tr(LocaleKeys.learningScreen_assignment_answer),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Answer text field
                    Container(
                      decoration: BoxDecoration(
                        color: colors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: TextFormField(
                        minLines: 8,
                        keyboardType: TextInputType.multiline,
                        controller: value.answerAssignment,
                        maxLines: null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) => AppValidators.required(val,
                            tr(LocaleKeys.learningScreen_assignment_answer)),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          color: colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintText:
                              tr(LocaleKeys.learningScreen_assignment_answer),
                          hintStyle: TextStyle(
                            fontFamily: 'Manrope',
                            color: colors.textSecondary.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // File upload container
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.border,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.sectionBg,
                                  foregroundColor: colors.textPrimary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: colors.border),
                                  ),
                                ),
                                icon: const Icon(Icons.upload_file, size: 18),
                                label: Text(
                                  tr(LocaleKeys
                                      .learningScreen_assignment_chooseFile),
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                onPressed: () {
                                  if (countFile > 0) {
                                    if (value.assignmentFiles.length <
                                        int.parse(value
                                            .dataAssignment.files_amount
                                            .toString())) {
                                      value.onUploadFiles();
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          (value.isAssignmentFileUpload)
                              ? Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    value.assignmentFiles.length,
                                    (i) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: MedsKaiColors.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.insert_drive_file,
                                            size: 14,
                                            color: MedsKaiColors.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: screenWidth * 0.4),
                                            child: Text(
                                              value.assignmentFiles[i].name,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: MedsKaiColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => value
                                                .onActionDeleteFileAssignmentChoose(
                                                    value.assignmentFiles[i]),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: MedsKaiColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  tr(LocaleKeys
                                      .learningScreen_assignment_nofile),
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // File description
                    Text(
                      tr(LocaleKeys
                              .learningScreen_assignment_chooseFileDescription)
                          .replaceAll("{{files_amount}}", countFile.toString())
                          .replaceAll("{{allow_file_type}}",
                              value.dataAssignment.allow_file_type.toString()),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                    // Existing files list
                    if (value.dataAssignment.assignment_answer?.file != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              tr(LocaleKeys
                                  .learningScreen_assignment_yourUploadedFiles),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListView.builder(
                              itemCount: value.dataAssignment.assignment_answer
                                  ?.file?.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  key: ValueKey(index),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: colors.sectionBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.insert_drive_file,
                                        size: 18,
                                        color: MedsKaiColors.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          (() {
                                            try {
                                              return value
                                                      .dataAssignment
                                                      .assignment_answer!
                                                      .file![index]
                                                      .values
                                                      .first['filename']
                                                      ?.toString() ??
                                                  '';
                                            } catch (_) {
                                              return '';
                                            }
                                          })(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Alert(
                                            context: context,
                                            title: tr(LocaleKeys
                                                .learningScreen_assignment_deleteFileTitle),
                                            desc: tr(LocaleKeys
                                                .learningScreen_assignment_deleteFileMessage),
                                            buttons: [
                                              DialogButton(
                                                color: colors.sectionBg,
                                                child: Text(
                                                  tr(LocaleKeys
                                                      .learningScreen_assignment_cancel),
                                                  style: TextStyle(
                                                    fontFamily: 'Manrope',
                                                    color: colors.textPrimary,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                              DialogButton(
                                                color: MedsKaiColors.error,
                                                child: Text(
                                                  tr(LocaleKeys
                                                      .learningScreen_assignment_ok),
                                                  style: const TextStyle(
                                                    fontFamily: 'Manrope',
                                                    color: MedsKaiColors.white,
                                                  ),
                                                ),
                                                onPressed: () => {
                                                  Navigator.pop(context),
                                                  value.onDeleteFileAssignment(
                                                      value.dataAssignment.id,
                                                      value
                                                          .dataAssignment
                                                          .assignment_answer
                                                          ?.file?[index]
                                                          .keys
                                                          .first
                                                          .toString())
                                                },
                                              ),
                                            ],
                                          ).show();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: MedsKaiColors.error
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            size: 16,
                                            color: MedsKaiColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => value.onSaveOrSendAssignment(
                                value.dataAssignment.id, "save"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.sectionBg,
                              foregroundColor: colors.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: colors.border),
                              ),
                            ),
                            child: Text(
                              tr(LocaleKeys.learningScreen_assignment_save),
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => value.onSaveOrSendAssignment(
                                value.dataAssignment.id, "send"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MedsKaiColors.primary,
                              foregroundColor: MedsKaiColors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              tr(LocaleKeys.learningScreen_assignment_send),
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
    });
  }
}

class LearningAssignment extends StatefulWidget {
  final int? id;

  const LearningAssignment({super.key, required this.id});

  @override
  State<LearningAssignment> createState() => _LearningAssignment();
}
