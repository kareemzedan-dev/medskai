import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/controller/course_detail_controller.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/app/view/components/error_state_widget.dart';
import 'package:flutter_app/app/view/components/learning/learning-assignment.dart';
import 'package:flutter_app/app/view/components/learning/learning-lesson.dart';
import 'package:flutter_app/app/view/components/learning/learning-quiz.dart';
import 'package:flutter_app/app/view/components/learning/learning-result.dart';
import 'package:flutter_app/app/view/components/learning/discussion_section.dart';
import 'package:flutter_app/app/view/components/learning/qa_section.dart';
import 'package:flutter_app/app/view/components/learning/learning-start-quiz.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../backend/models/lesson-model.dart';
import 'components/learning/learning-assignment-start.dart';
import 'package:flutter_app/app/util/orientation_service.dart';
import 'package:flutter_app/app/view/components/learning/secure_video_wrapper.dart';

class LearningScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  LearningScreen({Key? key}) : super(key: key);

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  final courseStore = locator<CourseStore>();
  CourseDetailController? get courseDetailController {
    try {
      return Get.find<CourseDetailController>();
    } catch (_) {
      return null;
    }
  }

  late TabController _tabController;

  // Video WebView controller - managed lifecycle to prevent memory leaks
  WebViewController? _videoController;
  String? _currentVideoHtml;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 2, vsync: this);
    OrientationService.unlockAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeVideoController();
    OrientationService.lockPortrait();
    super.dispose();
  }

  void _disposeVideoController() {
    if (_videoController != null) {
      _videoController!.loadRequest(Uri.parse('about:blank'));
      _videoController = null;
      _currentVideoHtml = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GetBuilder<LearningController>(builder: (value) {
      // Error state
      if (value.hasError) {
        return Scaffold(
          backgroundColor: colors.background,
          body: ErrorStateWidget(
            appError: value.appError,
            errorMessage: value.errorMessage,
            onRetry: value.retryLoadData,
          ),
        );
      }

      // Loading state
      if (value.isLoadingLesson) {
        return const Scaffold(
          backgroundColor: Color(0xFF1C1C1E),
          body: Center(
              child: CircularProgressIndicator(color: MedsKaiColors.primary)),
        );
      }

      bool isStatusResultAssignmentEmpty =
          value.dataAssignment.results is List &&
              value.dataAssignment.results.isEmpty;

      return Scaffold(
        backgroundColor: colors.background,
        body: Column(
          children: [
            // ── Video Player Area ──
            _buildVideoArea(value),

            // ── Course Info + Tabs + Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course title & author
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      courseStore.detail?.name ?? value.courseModel.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      _getInstructorName(courseStore.detail?.instructor),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),

                  // Tab bar: Lectures | More
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colors.border)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: colors.textPrimary,
                      unselectedLabelColor: colors.textSecondary,
                      indicatorColor: MedsKaiColors.primary,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: [
                        Tab(text: tr(LocaleKeys.ui_lecturesTab)),
                        const Tab(text: 'Q&A'),
                        Tab(text: tr(LocaleKeys.ui_moreTab)),
                      ],
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // ── Tab 1: Lectures (Curriculum) ──
                        _buildLecturesTab(value),

                        // ── Tab 2: Q&A ──
                        QaSection(courseId: int.tryParse(value.courseId.toString()) ?? 0),

                        // ── Tab 3: More (Lesson Content) ──
                        _buildContentTab(value, isStatusResultAssignmentEmpty),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Video player area at the top
  Widget _buildVideoArea(LearningController value) {
    final colors = context.kaiColors;
    final videoHtml = value.isLesson ? value.data.video_intro : null;
    final hasVideo = videoHtml != null && videoHtml.isNotEmpty;

    return Container(
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Video or placeholder
            if (hasVideo)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: SecureVideoWrapper(
                  child: _buildVideoWebView(videoHtml),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: SecureVideoWrapper(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MedsKaiColors.primary.withOpacity(0.15),
                          colors.sectionBg,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lecture ${(value.currentFlatIndex + 1).clamp(1, 999)}',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              value.data.name ?? value.lesson?.title ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Close button
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () {
                  courseDetailController?.refreshData();
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.textPrimary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: colors.textPrimary, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build WebView for video - reuses controller to prevent memory leaks
  Widget _buildVideoWebView(String videoHtml) {
    // Only recreate controller if video content changed
    if (_videoController == null || _currentVideoHtml != videoHtml) {
      _disposeVideoController();
      _currentVideoHtml = videoHtml;

      final videoUrl = _extractVideoUrl(videoHtml);
      _videoController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..enableZoom(false);

      if (videoUrl != null) {
        _videoController!.loadRequest(Uri.parse(videoUrl));
      } else {
        _videoController!.loadHtmlString(
          '<html><body style="margin:0;background:#000;">$videoHtml</body></html>',
        );
      }
    }
    return WebViewWidget(controller: _videoController!);
  }

  /// Extract video URL from HTML
  String? _extractVideoUrl(String html) {
    // iframe/embed src
    final srcMatch = RegExp(
      r'(?:iframe|embed|source|video)[^>]+src\s*=\s*["\x27]([^"\x27]+)["\x27]',
      caseSensitive: false,
    ).firstMatch(html);

    if (srcMatch != null) {
      var url = srcMatch.group(1)!;
      // Extract YouTube video ID and use mobile URL (embed URLs cause Error 153)
      final ytId = _extractYoutubeId(url);
      if (ytId != null) return 'https://m.youtube.com/watch?v=$ytId';
      return url;
    }

    // YouTube URL in text
    final ytMatch = RegExp(
      r'https?://(?:www\.)?(?:youtube\.com/(?:embed/|watch\?v=)|youtu\.be/)([\w-]+)',
    ).firstMatch(html);
    if (ytMatch != null)
      return 'https://m.youtube.com/watch?v=${ytMatch.group(1)!}';

    // Direct video file
    final fileMatch = RegExp(
      r'https?://[^\s"<>\x27]+\.(?:mp4|webm|ogg|m3u8)',
      caseSensitive: false,
    ).firstMatch(html);
    if (fileMatch != null) return fileMatch.group(0);

    return null;
  }

  String _getInstructorName(dynamic instructor) {
    if (instructor == null) return '';
    if (instructor is Map) return instructor['name']?.toString() ?? '';
    try {
      return instructor.name ?? '';
    } catch (_) {
      return '';
    }
  }

  String? _extractYoutubeId(String url) {
    // embed URL
    final embedMatch = RegExp(r'youtube\.com/embed/([\w-]+)').firstMatch(url);
    if (embedMatch != null) return embedMatch.group(1);
    // watch URL
    final watchId = Uri.tryParse(url)?.queryParameters['v'];
    if (watchId != null) return watchId;
    // youtu.be
    final shortMatch = RegExp(r'youtu\.be/([\w-]+)').firstMatch(url);
    if (shortMatch != null) return shortMatch.group(1);
    return null;
  }

  /// Lectures tab: progress + curriculum list
  Widget _buildLecturesTab(LearningController value) {
    final colors = context.kaiColors;
    final sections = value.courseModel.sections;
    if (sections == null || sections.isEmpty) {
      return Center(
        child: Text(tr(LocaleKeys.ui_noLecturesAvailable),
            style: TextStyle(color: colors.textSecondary)),
      );
    }

    final percent = value.progressPercent;
    final total = value.totalCount;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Progress bar
        if (total > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 4,
                      backgroundColor: colors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          MedsKaiColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MedsKaiColors.primary,
                  ),
                ),
              ],
            ),
          ),

        // Sections & lessons
        ...sections.asMap().entries.map((entry) {
          final sectionIndex = entry.key;
          final section = entry.value;
          return _buildSection(value, section, sectionIndex);
        }),

        const SizedBox(height: 100),
      ],
    );
  }

  /// Build a section with its lessons
  Widget _buildSection(
      LearningController value, LessonModel section, int sectionIndex) {
    final colors = context.kaiColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Section ${sectionIndex + 1} - ${section.title ?? ""}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Lesson items
        ...?section.items?.asMap().entries.map((entry) {
          final item = entry.value;
          final isActive = item.id == value.lesson?.id;
          // Calculate the global lesson number
          int globalNum = 0;
          for (final s in value.courseModel.sections!) {
            if (s.id == section.id) {
              globalNum += entry.key + 1;
              break;
            }
            globalNum += s.items?.length ?? 0;
          }

          return GestureDetector(
            onTap: () {
              if (item.locked != true) {
                value.sectionId = section.id;
                value.indexLesson = sectionIndex;
                value.onNavigateLearning(item);
                // Switch to content tab
                _tabController.animateTo(1);
              }
            },
            child: Container(
              color: isActive ? MedsKaiColors.primary.withOpacity(0.08) : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Lesson number
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$globalNum',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? MedsKaiColors.primary
                            : colors.textSecondary,
                      ),
                    ),
                  ),

                  // Title + duration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive
                                ? colors.textPrimary
                                : colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lessonSubtitle(item),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status icon
                  const SizedBox(width: 8),
                  _buildStatusIcon(item),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _lessonSubtitle(ItemLesson item) {
    final type = item.type == 'lp_quiz'
        ? tr(LocaleKeys.ui_quizType)
        : item.type == 'lp_assignment'
            ? tr(LocaleKeys.ui_assignmentType)
            : tr(LocaleKeys.ui_videoType);
    final duration = item.duration != null && item.duration!.isNotEmpty
        ? ' - ${item.duration}'
        : '';
    return '$type$duration';
  }

  Widget _buildStatusIcon(ItemLesson item) {
    final colors = context.kaiColors;
    if (item.status == 'completed') {
      return const Icon(Icons.check_circle,
          color: MedsKaiColors.success, size: 20);
    }
    if (item.locked == true) {
      return Icon(Icons.lock_outline, color: colors.textSecondary, size: 20);
    }
    return Icon(Icons.play_circle_outline,
        color: colors.textSecondary, size: 20);
  }

  /// Content tab: shows the lesson/quiz/assignment content
  Widget _buildContentTab(
      LearningController value, bool isStatusResultAssignmentEmpty) {
    final colors = context.kaiColors;
    return RefreshIndicator(
      onRefresh: () => value.refreshData(),
      color: MedsKaiColors.primary,
      child: SingleChildScrollView(
        controller: value.scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        child: Container(
          color: colors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.isLesson) LearningLesson(data: value.data),
              if (value.isQuiz &&
                  !value.isStartQuiz &&
                  value.data.results?.status == '')
                LearningQuiz(data: value.data, dataQuiz: value.dataQuiz),
              if (value.isAssignment && !isStatusResultAssignmentEmpty)
                LearningAssignment(id: value.id),
              if (value.isAssignment && isStatusResultAssignmentEmpty)
                LearningAssignmentStart(
                  data: value.dataAssignment,
                  value: value,
                  itemLesson: value.lesson ?? ItemLesson(),
                ),
              if (value.isStartQuiz && value.isQuiz)
                LearningStartQuiz(
                  data: value.data,
                  dataQuiz: value.dataQuiz,
                  itemQuestion: value.itemQuestion,
                ),
              if (value.isQuiz &&
                  !value.isStartQuiz &&
                  value.data.results?.status != '')
                LearningResult(data: value.data),
              if (value.data.can_finish_course == true && value.isQuiz)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(top: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: value.onFinishCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MedsKaiColors.success,
                        foregroundColor: MedsKaiColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        tr(LocaleKeys.learningScreen_finishCourse),
                        style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
              // Discussion section
              if (!value.isQuiz &&
                  !value.isAssignment &&
                  value.sectionId != null)
                DiscussionSection(
                  postId: value.sectionId!,
                  tag: 'lesson_${value.sectionId}',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
