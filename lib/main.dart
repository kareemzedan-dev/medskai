import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
// Core imports
import 'package:flutter_app/app/core/di/injection.dart';
import 'package:flutter_app/app/core/l10n/app_localizations.dart';
import 'package:flutter_app/app/core/theme/app_theme.dart';
// Error handling
import 'package:flutter_app/app/view/components/error_fallback_screen.dart';
// App imports
import 'package:flutter_app/app/backend/mobx-store/session_store.dart';
import 'package:flutter_app/app/controller/language_controller.dart';
import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/controller/firebase_api_controller.dart';
import 'package:flutter_app/app/util/constant.dart';
import 'package:flutter_app/app/util/orientation_service.dart';

void main() async {
  // 1. Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait by default
  await OrientationService.lockPortrait();

  // 2. Initialize Localization
  await AppLocalizations.initialize();

  // 3. Initialize Dependency Injection
  await DependencyInjection.init();

  // 4. Initialize Firebase-backed notifications when configured.
  await _initializeFirebaseServices();

  // 5. Setup global error handlers
  _setupErrorHandlers();

  // 6. Run app with localization wrapper
  runApp(
    AppLocalizations.wrap(
      MultiProvider(
        providers: [
          Provider<SessionStore>(
            create: (_) => SessionStore(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

Future<void> _initializeFirebaseServices() async {
  try {
    await Firebase.initializeApp();
    await FirebaseApiController().initNotifications();
  } catch (error, stack) {
    debugPrint('Firebase initialization skipped: $error');
    debugPrint('Firebase initialization stack: $stack');
  }
}

/// Setup global error boundary handlers
void _setupErrorHandlers() {
  // Catch Flutter framework errors (widget build errors, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log the error
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    if (kDebugMode) {
      // In debug mode, use default handler (red screen with details)
      FlutterError.presentError(details);
    }
    // In release mode, the ErrorWidget.builder below handles display
  };

  // Catch unhandled async errors (errors not caught by any widget)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error');
    debugPrint('Stack trace: $stack');
    return true; // Handled
  };

  // Custom error widget for release mode (replaces red screen)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      // Show default Flutter error widget in debug mode
      return ErrorWidget(details.exception);
    }
    // In release mode, show friendly fallback
    return ErrorFallbackScreen(errorDetails: details);
  };
}

class MyApp extends StatelessWidget with GetItMixin {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    LanguageController languageController = Get.find();
    String key =
        languageController.sharedPreferencesManager.getString("language") ??
            'en';
    var currentLanguage = languageController.handleChoiceLanguage(key);
    var currentLocale =
        Locale(currentLanguage['key'], currentLanguage['countryCode']);
    context.setLocale(currentLocale);
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: GlobalLoaderOverlay(
          child: GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            initialRoute: AppRouter.splash,
            getPages: AppRouter.routes,
            // Theme — saved preference loaded by ThemeController
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: (languageController.sharedPreferencesManager
                        .getString('theme_mode') ==
                    'dark')
                ? ThemeMode.dark
                : ThemeMode.light,
            // Localization
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          ),
        ));
  }
}
