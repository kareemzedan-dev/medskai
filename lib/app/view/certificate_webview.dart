import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A dedicated WebView screen for certificates that opens the URL in-app.
class CertificateWebViewScreen extends StatefulWidget {
  const CertificateWebViewScreen({Key? key}) : super(key: key);

  @override
  State<CertificateWebViewScreen> createState() => _CertificateWebViewScreenState();
}

class _CertificateWebViewScreenState extends State<CertificateWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  late final String _url;
  late final String _userName;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _url = args?['url'] as String? ?? '';
    _userName = args?['userName'] as String? ?? '';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      // Force desktop user-agent so the page renders its desktop layout
      ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.0.0 Safari/537.36',
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() { _isLoading = true; _hasError = false; });
        },
        onPageFinished: (url) async {
          // 1. Override viewport: use 1280px desktop width but allow
          //    the browser to scale it to fit the phone screen.
          // Force perfect desktop scaling using fabric.js with proper padding
          await _controller.runJavaScript('''
            (function() {
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=1280, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
              document.head.appendChild(meta);

              var styles = document.createElement('style');
              styles.innerHTML = 'body { overflow-x: hidden !important; background-color: #f5f5f5 !important; margin: 0; padding: 0; } .lp-btn, .button-download-certificate, .print-certificate, .download-certificate, [class*="download"], [class*="print"], button, .lp-certificate-social, .share-certificate, .social-share, #learn-press-certificate-social, .certificate-social, .social-wrap { display: none !important; }';
              document.head.appendChild(styles);

              function resizeCert() {
                  var cert = document.querySelector('.lp-certificate-wrapper') || document.querySelector('.learnpress-certificate');
                  if (cert) {
                      cert.style.transform = 'none';
                      var w = cert.scrollWidth;
                      var h = cert.scrollHeight;
                      if (w > 100) {
                          var scale = (window.innerWidth - 40) / w;
                          cert.style.transformOrigin = 'top left';
                          cert.style.transform = 'scale(' + scale + ')';
                          cert.style.marginLeft = '20px';
                          cert.style.marginTop = '20px';
                          // Fix document height so it doesn't leave huge blank space
                          document.body.style.height = (h * scale + 40) + 'px';
                      }
                  }
              }
              setInterval(resizeCert, 1000);
            })();
          ''');

          // 2. Inject user display name if the page didn't pick it up
          if (_userName.isNotEmpty) {
            final safeName = _userName.replaceAll("'", "\\'").replaceAll('"', '\\"');
            await _controller.runJavaScript('''
              (function() {
                var name = '$safeName';
                var selectors = [
                  '.lp-certificate-student-name',
                  '.student-name',
                  '[data-student]',
                  '#student-name',
                  '.user-name',
                  '.the-name',
                ];
                selectors.forEach(function(sel) {
                  var els = document.querySelectorAll(sel);
                  els.forEach(function(el) {
                    if (!el.innerText || el.innerText.trim() === '') {
                      el.innerText = name;
                    }
                  });
                });
              })();
            ''');
          }

          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (error) {
          if (mounted) setState(() { _isLoading = false; _hasError = true; });
        },
      ))
      ..loadRequest(
        Uri.parse(_url),
        headers: {'x-platform': 'flutter'},
      );
  }

  Future<void> _openInBrowser() async {
    try {
      final uri = Uri.parse(_url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Could not launch URL");
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open browser',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr(LocaleKeys.certificate_title),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textPrimary),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError) WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: colors.background,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: MedsKaiColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      tr(LocaleKeys.loading),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasError && !_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 48, color: colors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    tr(LocaleKeys.toast_networkError),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _controller.reload(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MedsKaiColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openInBrowser,
        backgroundColor: MedsKaiColors.primary,
        child: const Icon(Icons.open_in_browser_rounded, color: Colors.white),
      ),
    );
  }
}
