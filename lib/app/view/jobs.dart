import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../helper/router.dart';
import '../../l10n/locale_keys.g.dart';

/// Builds the JavaScript injection that hides header/footer/nav inside the WebView.
String _buildHideScript() {
  return r"""
    (function() {
      var css = document.createElement('style');
      css.type = 'text/css';
      css.innerHTML = `
        /* Hide by HTML tag */
        header, footer, nav { display: none !important; }

        /* WordPress common selectors */
        #masthead, #colophon, #site-navigation,
        .site-header, .site-footer,
        .main-navigation, .main-nav,
        .nav-bar, .navbar, .top-bar,
        .header-sticky, .sticky-header,
        .primary-menu, .primary-nav,
        .mega-menu, .mega-nav,
        .woocommerce-notices-wrapper > :not(.woocommerce-message),
        .breadcrumb, .breadcrumbs,
        .elementor-location-header,
        .elementor-location-footer,
        .hfcm-container,
        [class*="header-"], [id*="header-"],
        [class*="footer-"], [id*="footer-"],
        [class*="-header"], [id*="-footer"],

        /* Site-specific selectors */
        .thim-ekit__header,
        .thim-ekit__footer,
        .navbar-mobile-button
        { display: none !important; }
      `;
      document.head.appendChild(css);
    })();
  """;
}

class JobsScreen extends StatefulWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const String _url = 'https://medskai.com/en/explore-jobs/';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) {
            _controller.runJavaScript(_buildHideScript());
            setState(() => _isLoading = false);
          },
          onWebResourceError: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.jobs_title)),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRouter.addJob),
        backgroundColor: MedsKaiColors.primary,
        tooltip: 'Post a Job',
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Post a Job',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: MedsKaiColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
