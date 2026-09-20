import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../l10n/locale_keys.g.dart';
import '../controller/jobs_controller.dart';

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

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({Key? key}) : super(key: key);

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Get the user token
    final token = Get.find<JobsController>().parser.getToken();
    
    // Try passing the token in the URL as a query parameter (common for WP auto-login plugins)
    final String _url = 'https://medskai.com/en/post-a-job-2/?token=$token';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) {
            _controller.runJavaScript(_buildHideScript());
            
            // Also try to inject the token into localStorage/cookies just in case the site uses it via JS
            _controller.runJavaScript("localStorage.setItem('token', '$token'); localStorage.setItem('jwt', '$token'); document.cookie = 'token=$token; path=/;';");
            
            setState(() => _isLoading = false);
          },
          onWebResourceError: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(
        Uri.parse(_url),
        // Also pass as Authorization header just in case the site handles it via headers
        headers: {'Authorization': 'Bearer $token'},
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
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
