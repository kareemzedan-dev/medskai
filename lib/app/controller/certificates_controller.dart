import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';

import '../backend/parse/certificates_parse.dart';
import '../helper/router.dart';
import '../util/toast.dart';

class CertificateModel {
  final int courseId;
  final String courseName;
  final String? completedDate;
  final String? instructor;
  final String? grade;
  final String? thumbnail;
  final String certificateUrl;
  final String certificateImage;

  CertificateModel({
    required this.courseId,
    required this.courseName,
    this.completedDate,
    this.instructor,
    this.grade,
    this.thumbnail,
    required this.certificateUrl,
    required this.certificateImage,
  });

  String get formattedCompletedDate {
    if (completedDate == null || completedDate!.isEmpty) return '-';
    try {
      final timestamp = int.tryParse(completedDate!);
      DateTime dt;
      if (timestamp != null) {
        dt = DateTime.fromMillisecondsSinceEpoch(
            timestamp < 10000000000 ? timestamp * 1000 : timestamp);
      } else {
        dt = DateTime.parse(completedDate!);
      }
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      final val = completedDate!;
      final timeRegex = RegExp(r'(\d{1,2}):(\d{2}):(\d{2})');
      if (timeRegex.hasMatch(val)) {
        return val.replaceAllMapped(timeRegex, (match) => '${match.group(1)}:${match.group(2)}');
      }
      return val;
    }
  }

  factory CertificateModel.fromCourseJson(Map<String, dynamic> json) {
    final course = json['course'] ?? {};
    // certificate_image from API, fallback to course thumbnail
    final certImg = json['certificate_image']?.toString() ?? '';
    final courseThumbnail = course['thumbnail']?.toString() ?? course['image']?.toString() ?? '';
    return CertificateModel(
      courseId: course['id'] ?? 0,
      courseName: course['title'] ?? '',
      completedDate: json['completion_date']?.toString(),
      instructor: null,
      grade: null,
      thumbnail: courseThumbnail,
      certificateUrl: json['certificate_url']?.toString() ?? '',
      certificateImage: certImg,
    );
  }

  factory CertificateModel.fromPassedCourseJson(Map<String, dynamic> json) {
    final courseData = json['course_data'];
    final result = courseData is Map ? courseData['result'] : null;
    final instructor = json['instructor'];
    String? instructorName;
    if (instructor is Map) {
      instructorName = instructor['display_name']?.toString() ??
          instructor['name']?.toString();
    } else {
      instructorName = instructor?.toString();
    }

    return CertificateModel(
      courseId:
          json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      courseName: json['name']?.toString() ?? json['title']?.toString() ?? '',
      completedDate:
          courseData is Map ? courseData['end_time']?.toString() : null,
      instructor: instructorName,
      grade: result is Map && result['result'] != null
          ? '${result['result']}%'
          : null,
      thumbnail: json['image']?.toString(),
      certificateUrl: json['permalink']?.toString() ?? '',
      certificateImage: '',
    );
  }
}

class CertificatesController extends GetxController {
  final CertificatesParser parser;

  CertificatesController({required this.parser});

  List<CertificateModel> certificates = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int _page = 1;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadCertificates();
  }

  Future<void> loadCertificates() async {
    if (parser.getToken().isEmpty) {
      isLoading = false;
      hasError = true;
      errorMessage = tr(LocaleKeys.alert_notLoggedIn);
      update();
      return;
    }

    isLoading = true;
    hasError = false;
    update();

    try {
      final response = await parser.getMyCertificates(page: _page);
      debugPrint('Certificates API response: ${response.statusCode}');
      debugPrint('Certificates API response body: ${response.bodyString ?? response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = [];

        if (response.body is List) {
          data = response.body;
        } else if (response.body is Map) {
          final body = response.body as Map;
          data = body['data'] ?? body['items'] ?? body['certificates'] ?? [];
        }

        debugPrint('Found ${data.length} certificates');

        if (_page == 1) {
          certificates =
              data.map((e) => CertificateModel.fromCourseJson(e)).toList();
        } else {
          certificates.addAll(
            data.map((e) => CertificateModel.fromCourseJson(e)).toList(),
          );
        }

        hasMore = data.length >= 20; // Per page is 20 in the new API
        hasError = false;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('Certificates endpoint unauthorized (401/403)');
        if (_page == 1) {
          hasError = true;
          String msg = tr(LocaleKeys.errors_auth_sessionExpired);
          if (response.body is Map && response.body["message"] != null) {
            msg = response.body["message"].toString();
          }
          errorMessage = msg;
          showToast(errorMessage, isError: true);
          // Redirect to login screen
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.offAllNamed(AppRouter.getLoginRoute());
          });
        }
      } else {
        debugPrint('API Error: ${response.statusCode}');
        if (_page == 1) {
          hasError = true;
          String msg = tr(LocaleKeys.toast_networkError);
          if (response.body is Map && response.body["message"] != null) {
            msg = response.body["message"].toString();
          } else if (response.statusText != null && response.statusText!.isNotEmpty) {
            msg = response.statusText!;
          }
          errorMessage = msg;
        }
      }
    } catch (e) {
      debugPrint('loadCertificates error: $e');
      if (_page == 1) {
        hasError = true;
        errorMessage = tr(LocaleKeys.toast_networkError);
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshCertificates() async {
    _page = 1;
    hasMore = true;
    await loadCertificates();
  }

  Future<void> loadMoreCertificates() async {
    if (!hasMore || isLoading) return;
    _page++;
    await loadCertificates();
  }

  /// View certificate in in-app WebView
  Future<void> viewCertificate(CertificateModel certificate) async {
    try {
      debugPrint('View button clicked! certificateUrl is: "${certificate.certificateUrl}"');
      if (certificate.certificateUrl.isEmpty) {
        showToast(tr(LocaleKeys.toast_networkError), isError: true);
        return;
      }
      
      final uri = Uri.parse(certificate.certificateUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showToast(tr(LocaleKeys.toast_networkError), isError: true);
      }
    } catch (e) {
      debugPrint('viewCertificate error: $e');
      showToast(tr(LocaleKeys.toast_networkError), isError: true);
    }
  }

  /// Download certificate (opens in browser with download param)
  Future<void> downloadCertificate(CertificateModel certificate) async {
    try {
      final downloadUrl = '${certificate.certificateUrl}?download=true';
      final uri = Uri.parse(downloadUrl);
      debugPrint('Downloading certificate from: $downloadUrl');

      if (await canLaunchUrl(uri)) {
        final token = parser.getToken();
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: WebViewConfiguration(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      } else {
        // Fallback: try launching directly anyway
        try {
          final token = parser.getToken();
          await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
            webViewConfiguration: WebViewConfiguration(
              headers: {'Authorization': 'Bearer $token'},
            ),
          );
        } catch (_) {
          showToast(tr(LocaleKeys.toast_networkError), isError: true);
        }
      }
    } catch (e) {
      debugPrint('downloadCertificate error: $e');
      showToast(tr(LocaleKeys.toast_networkError), isError: true);
    }
  }

  /// Share certificate link
  Future<void> shareCertificate(CertificateModel certificate) async {
    try {
      final shareText = '${tr(LocaleKeys.certificate_shareMessage)}\n\n'
          '${certificate.courseName}\n'
          '${certificate.certificateUrl}';

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: shareText));
      showToast(tr(LocaleKeys.toast_copiedToClipboard), isError: false);
    } catch (e) {
      debugPrint('shareCertificate error: $e');
      showToast(tr(LocaleKeys.toast_networkError), isError: true);
    }
  }
}
