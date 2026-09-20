import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:flutter_app/app/controller/learning_controller.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_just_audio/fwfh_just_audio.dart';
import 'package:fwfh_webview/fwfh_webview.dart';
import 'package:flutter_app/app/view/components/learning/lesson_nav_buttons.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LearningLesson extends StatelessWidget with GetItMixin {
  final LearningLessonModel data;

  LearningLesson({super.key, required this.data});

  final courseStore = locator<CourseStore>();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  get webView => true;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final String? pdfUrl = _extractPdfUrl(data.content);
    return GetBuilder<LearningController>(builder: (value) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Video is now rendered in learning.dart _buildVideoArea

        // ── Lesson Title ──
        if (data.name != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              data.name!,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Manrope',
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),

        // ── Lesson Content (HTML) ──
        if (data.content != null && pdfUrl == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HtmlWidget(
              data.content.toString(),
              factoryBuilder: () => MyWidgetFactory(),
              textStyle: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                color: colors.textPrimary,
                fontWeight: FontWeight.w400,
                height: 1.8,
              ),
            ),
          ),

        // ── PDF Viewer ──
        if (data.content != null && pdfUrl != null)
          Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: SfPdfViewer.network(pdfUrl, key: _pdfViewerKey),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (value.courseModel.course_data?.status == 'enrolled')
                if (value.courseModel.sections != null &&
                    value.courseModel.sections!.isNotEmpty &&
                    value.lesson?.status != 'completed')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: MedsKaiColors.white,
                      backgroundColor: MedsKaiColors.success,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => {value.onCompleteLesson()},
                    child: Text(
                      tr(LocaleKeys.learningScreen_lesson_btnComplete),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              if (data.can_finish_course == true)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: MedsKaiColors.white,
                    backgroundColor: colors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => {value.onFinishCourse()},
                  child: Text(
                    tr(LocaleKeys.learningScreen_finishCourse),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Previous / Next Navigation ──
        LessonNavButtons(
          previousLesson: value.previousLesson,
          nextLesson: value.nextLesson,
          onPrevious: () => value.onPrevious(),
          onNext: () => value.onNext(),
        ),
      ]);
    });
  }

  /// Build video player: extract any video URL and load directly in WebView
  Widget _buildVideoPlayer(BuildContext context, String videoHtml) {
    debugPrint('video_intro HTML: $videoHtml');

    final videoUrl = _extractVideoUrl(videoHtml);
    debugPrint('Extracted video URL: $videoUrl');

    if (videoUrl != null) {
      // Load the video URL directly — works for YouTube, Vimeo, or any embed
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..enableZoom(false)
        ..loadRequest(Uri.parse(videoUrl));

      return Container(
        width: double.infinity,
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: WebViewWidget(controller: controller),
        ),
      );
    }

    // No URL found — try loading the raw HTML as a last resort
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadHtmlString(
        '<html><body style="margin:0;background:#000;">$videoHtml</body></html>',
      );

    return Container(
      width: double.infinity,
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: WebViewWidget(controller: controller),
      ),
    );
  }

  /// Extract any video URL from HTML (iframe src, embed src, video src, or plain URL)
  String? _extractVideoUrl(String html) {
    // 1. Try iframe/embed src attribute
    final srcMatch = RegExp(
      r'(?:iframe|embed|source|video)[^>]+src\s*=\s*["\x27]([^"\x27]+)["\x27]',
      caseSensitive: false,
    ).firstMatch(html);

    if (srcMatch != null) {
      var url = srcMatch.group(1)!;
      // Convert youtube.com/watch?v=X to youtube.com/embed/X
      if (url.contains('youtube.com/watch')) {
        final videoId = Uri.parse(url).queryParameters['v'];
        if (videoId != null) url = 'https://www.youtube.com/embed/$videoId';
      }
      // Convert youtu.be/X to youtube.com/embed/X
      if (url.contains('youtu.be/')) {
        final videoId = url.split('youtu.be/').last.split('?').first;
        url = 'https://www.youtube.com/embed/$videoId';
      }
      return url;
    }

    // 2. Try any YouTube URL in the text
    final ytMatch = RegExp(
      r'https?://(?:www\.)?(?:youtube\.com/(?:embed/|watch\?v=)|youtu\.be/)([\w-]+)',
    ).firstMatch(html);

    if (ytMatch != null) {
      return 'https://www.youtube.com/embed/${ytMatch.group(1)!}';
    }

    // 3. Try any video URL (vimeo, dailymotion, etc.)
    final anyUrlMatch = RegExp(
      r'https?://[^\s"<>\x27]+\.(?:mp4|webm|ogg|m3u8)',
      caseSensitive: false,
    ).firstMatch(html);

    if (anyUrlMatch != null) {
      return anyUrlMatch.group(0);
    }

    return null;
  }

  String? _extractPdfUrl(String? content) {
    if (content == null) return null;
    String? url = "";
    RegExp regex = RegExp(r'<a\s+[^>]*href="([^"]+\.pdf)"[^>]*>');

    Iterable<RegExpMatch> matches = regex.allMatches(content);

    for (final match in matches) {
      url = match.group(1);
      break;
    }
    return (url == null || url.isEmpty) ? null : url;
  }
}

class MyWidgetFactory extends WidgetFactory
    with WebViewFactory, JustAudioFactory {
  @override
  bool get webViewMediaPlaybackAlwaysAllow => true;
}
