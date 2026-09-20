import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

import 'supported_locales.dart';

/// App Localizations Manager
///
/// Handles all localization-related operations
///
/// Usage:
/// ```dart
/// // Initialize in main.dart
/// await AppLocalizations.initialize();
///
/// // Wrap app with EasyLocalization
/// runApp(AppLocalizations.wrap(MyApp()));
///
/// // Change language
/// AppLocalizations.changeLanguage(context, SupportedLocales.arabic);
/// ```
class AppLocalizations {
  AppLocalizations._();

  // ============================================================
  // Initialization
  // ============================================================

  /// Initialize localization (call in main.dart)
  static Future<void> initialize() async {
    await EasyLocalization.ensureInitialized();
  }

  /// Wrap app with EasyLocalization widget
  static Widget wrap(Widget child) {
    return EasyLocalization(
      supportedLocales: SupportedLocales.all,
      fallbackLocale: SupportedLocales.fallback,
      path: SupportedLocales.translationsPath,
      useOnlyLangCode: false,
      child: child,
    );
  }

  // ============================================================
  // Language Management
  // ============================================================

  /// Change app language
  static void changeLanguage(BuildContext context, Locale locale) {
    context.setLocale(locale);
    Get.updateLocale(locale);
  }

  /// Change language by code
  static void changeLanguageByCode(BuildContext context, String languageCode) {
    final locale = SupportedLocales.buildLocale(languageCode);
    changeLanguage(context, locale);
  }

  /// Get current locale
  static Locale getCurrentLocale(BuildContext context) {
    return context.locale;
  }

  /// Get current language code
  static String getCurrentLanguageCode(BuildContext context) {
    return context.locale.languageCode;
  }

  /// Check if current locale is RTL
  static bool isCurrentRtl(BuildContext context) {
    return SupportedLocales.isRtl(context.locale);
  }

  // ============================================================
  // Text Direction
  // ============================================================

  /// Get text direction for current locale
  static ui.TextDirection getTextDirection(BuildContext context) {
    return isCurrentRtl(context) ? ui.TextDirection.rtl : ui.TextDirection.ltr;
  }

  /// Get text direction for specified locale
  static ui.TextDirection getTextDirectionForLocale(Locale locale) {
    return SupportedLocales.isRtl(locale)
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
  }

  // ============================================================
  // Delegates
  // ============================================================

  /// Get localization delegates from context
  static List<LocalizationsDelegate> getDelegates(BuildContext context) {
    return context.localizationDelegates;
  }

  /// Get supported locales from context
  static List<Locale> getSupportedLocales(BuildContext context) {
    return context.supportedLocales.toList();
  }

  // ============================================================
  // Utilities
  // ============================================================

  /// Translate a key
  static String translate(String key) {
    return tr(key);
  }

  /// Translate with arguments
  static String translateWithArgs(String key, {List<String>? args}) {
    return tr(key, args: args);
  }

  /// Translate with named arguments
  static String translateWithNamedArgs(
    String key, {
    Map<String, String>? namedArgs,
  }) {
    return tr(key, namedArgs: namedArgs);
  }

  /// Pluralize translation
  static String plural(String key, num value, {List<String>? args}) {
    return key.plural(value);
  }
}

/// Extension on BuildContext for localization
extension LocalizationExtension on BuildContext {
  /// Change app language
  void changeLanguage(Locale locale) {
    AppLocalizations.changeLanguage(this, locale);
  }

  /// Check if current locale is RTL
  bool get isRtl => AppLocalizations.isCurrentRtl(this);

  /// Get current language code
  String get languageCode => AppLocalizations.getCurrentLanguageCode(this);
}
