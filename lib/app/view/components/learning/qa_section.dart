import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/backend/parse/qa_parse.dart';
import 'package:flutter_app/app/controller/qa_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class QaSection extends StatefulWidget {
  final int courseId;

  const QaSection({Key? key, required this.courseId}) : super(key: key);

  @override
  State<QaSection> createState() => _QaSectionState();
}

class _QaSectionState extends State<QaSection> {
  late QaController qaController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<QaController>()) {
      Get.delete<QaController>();
    }
    
    // Register QaParser if not already registered
    if (!Get.isRegistered<QaParser>()) {
      Get.put(QaParser(
        apiService: Get.find(),
        sharedPreferencesManager: Get.find(),
      ));
    }
    
    qaController = Get.put(QaController(
      parser: Get.find<QaParser>(),
      courseId: widget.courseId,
    ));
  }

  bool _isInstructor() {
    final sessionStore = locator<SessionStore>();
    final courseStore = locator<CourseStore>();
    final userId = sessionStore.userInfo?.id;
    
    // Check if the current user is the course instructor
    dynamic instructor = courseStore.detail?.instructor;
    int? instructorId;
    if (instructor is Map) {
      instructorId = int.tryParse(instructor['id']?.toString() ?? '');
    } else {
      try {
        instructorId = instructor?.id;
      } catch (e) {}
    }
    
    if (userId != null && instructorId != null && userId == instructorId) {
      return true;
    }
    
    // Removed faulty instructorData fallback as it incorrectly flags students as instructors
    return false;
  }

  void _showAskDialog() {
    final colors = context.kaiColors;
    qaController.subjectController.clear();
    qaController.questionController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ask a Question',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qaController.subjectController,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: colors.textSecondary),
                  filled: true,
                  fillColor: colors.sectionBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qaController.questionController,
                style: TextStyle(color: colors.textPrimary),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: TextStyle(color: colors.textSecondary),
                  filled: true,
                  fillColor: colors.sectionBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: GetBuilder<QaController>(
                  builder: (ctrl) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MedsKaiColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: ctrl.isSubmitLoading ? null : ctrl.submitQuestion,
                    child: ctrl.isSubmitLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showReplyDialog(int questionId) {
    final colors = context.kaiColors;
    qaController.replyController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reply to Question',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qaController.replyController,
                style: TextStyle(color: colors.textPrimary),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Reply',
                  labelStyle: TextStyle(color: colors.textSecondary),
                  filled: true,
                  fillColor: colors.sectionBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: GetBuilder<QaController>(
                  builder: (ctrl) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MedsKaiColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: ctrl.isSubmitLoading ? null : () => ctrl.submitReply(questionId),
                    child: ctrl.isSubmitLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Reply',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final isInstructor = _isInstructor();

    return GetBuilder<QaController>(
      builder: (ctrl) {
        if (ctrl.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: MedsKaiColors.primary),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          body: ctrl.questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No questions yet.',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: ctrl.questions.length,
                  itemBuilder: (context, index) {
                    final q = ctrl.questions[index];
                    final isAnswered = q.status?.toLowerCase() == 'answered' || (q.answer != null && q.answer!.isNotEmpty);
                    
                    String formattedDate = '';
                    if (q.date != null) {
                      try {
                        DateTime dt = DateTime.parse(q.date!);
                        formattedDate = DateFormat.yMMMd().format(dt);
                      } catch (e) {}
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.sectionBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  q.subject ?? 'No Subject',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAnswered ? MedsKaiColors.success.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAnswered ? 'Answered' : 'Pending',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isAnswered ? MedsKaiColors.success : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (formattedDate.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            q.question ?? '',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (isAnswered) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: MedsKaiColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(left: BorderSide(color: MedsKaiColors.primary, width: 4)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instructor Reply:',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: MedsKaiColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    q.answer ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 14,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (!isAnswered && isInstructor && q.id != null) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _showReplyDialog(q.id!),
                                icon: const Icon(Icons.reply, size: 16, color: MedsKaiColors.primary),
                                label: const Text(
                                  'Reply',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    color: MedsKaiColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
          floatingActionButton: !isInstructor
              ? FloatingActionButton.extended(
                  onPressed: _showAskDialog,
                  backgroundColor: MedsKaiColors.primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Ask Question',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
