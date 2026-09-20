import 'dart:ui';

/// Supported Locales Configuration
///
/// Defines all supported languages and their locales
///
/// Usage:
/// ```dart
/// EasyLocalization(
///   supportedLocales: SupportedLocales.all,
///   fallbackLocale: SupportedLocales.fallback,
///   path: SupportedLocales.translationsPath,
///   child: MyApp(),
/// )
/// ```
class SupportedLocales {
  SupportedLocales._();

  // ============================================================
  // Locale Definitions
  // ============================================================

  /// English (US)
  static const Locale english = Locale('en', 'US');

  /// Arabic (Saudi Arabia)
  static const Locale arabic = Locale('ar', 'SA');

  // ============================================================
  // Collections
  // ============================================================

  /// All supported locales
  static const List<Locale> all = [
    english,
    arabic,
  ];

  /// RTL locales (Right-to-Left)
  static const List<Locale> rtlLocales = [
    arabic,
  ];

  /// Language codes
  static const List<String> languageCodes = [
    'en',
    'ar',
  ];

  // ============================================================
  // Configuration
  // ============================================================

  /// Fallback locale when device locale is not supported
  static const Locale fallback = english;

  /// Path to translation files
  static const String translationsPath = 'assets/translations';

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Check if locale is RTL
  static bool isRtl(Locale locale) {
    return rtlLocales.contains(locale) ||
        locale.languageCode == 'ar';
  }

  /// Get locale by language code
  static Locale? getLocaleByCode(String code) {
    try {
      return all.firstWhere(
        (locale) => locale.languageCode == code,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get display name for locale
  static String getDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode;
    }
  }

  /// Get native display name for locale
  static String getNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return languageCode;
    }
  }

  /// Get country code for language code
  static String getCountryCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'US';
      case 'ar':
        return 'SA';
      default:
        return 'US';
    }
  }

  /// Build Locale from language code
  static Locale buildLocale(String languageCode) {
    return Locale(languageCode, getCountryCode(languageCode));
  }
}
