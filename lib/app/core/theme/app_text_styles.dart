import 'package:flutter/material.dart';
import 'app_colors.dart';

/// MedsKai Text Styles - Consistent Typography
///
/// Based on Manrope font family (exact from website)
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTextStyles.displayLarge)
/// ```
class AppTextStyles {
  AppTextStyles._();

  // ============================================================
  // Font Family
  // ============================================================

  /// Primary font family
  static const String fontFamily = 'Manrope';

  /// Secondary font family (legacy support)
  static const String fontFamilySecondary = 'Poppins';

  // ============================================================
  // Font Weights
  // ============================================================

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // ============================================================
  // Display Styles (Large headers)
  // ============================================================

  /// Display Large - 32px, Extra Bold
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: extraBold,
    color: MedsKaiColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Display Medium - 28px, Bold
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: bold,
    color: MedsKaiColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// Display Small - 24px, Bold
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: bold,
    color: MedsKaiColors.textPrimary,
    height: 1.3,
  );

  // ============================================================
  // Headline Styles
  // ============================================================

  /// Headline Large - 21px, SemiBold
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    fontWeight: semiBold,
    color: MedsKaiColors.textPrimary,
    height: 1.4,
  );

  /// Headline Medium - 18px, SemiBold
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: semiBold,
    color: MedsKaiColors.textPrimary,
    height: 1.4,
  );

  /// Headline Small - 16px, SemiBold
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    color: MedsKaiColors.textPrimary,
    height: 1.4,
  );

  // ============================================================
  // Title Styles
  // ============================================================

  /// Title Large - 16px, SemiBold
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    color: MedsKaiColors.textPrimary,
    height: 1.4,
  );

  /// Title Medium - 14px, SemiBold
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    color: MedsKaiColors.textPrimary,
    height: 1.2,
  );

  /// Title Small - 12px, SemiBold
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: semiBold,
    color: MedsKaiColors.textPrimary,
    height: 1.4,
  );

  // ============================================================
  // Body Styles
  // ============================================================

  /// Body Large - 16px, Regular
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    color: MedsKaiColors.textPrimary,
    height: 1.5,
  );

  /// Body Medium - 14px, Regular
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    color: MedsKaiColors.textPrimary,
    height: 1.5,
  );

  /// Body Small - 12px, Regular
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    color: MedsKaiColors.textSecondary,
    height: 1.5,
  );

  // ============================================================
  // Label Styles
  // ============================================================

  /// Label Large - 14px, SemiBold
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    color: MedsKaiColors.textPrimary,
    height: 1.4,
  );

  /// Label Medium - 12px, Medium
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    color: MedsKaiColors.textPrimary,
    height: 1.4,
  );

  /// Label Small - 10px, Medium
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: medium,
    color: MedsKaiColors.textSecondary,
    height: 1.4,
  );

  // ============================================================
  // Button Styles
  // ============================================================

  /// Primary Button Text
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    color: MedsKaiColors.white,
    letterSpacing: 0.3,
  );

  /// Secondary Button Text
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    color: MedsKaiColors.buttonColor,
    letterSpacing: 0.3,
  );

  /// Text Button
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    color: MedsKaiColors.primary,
  );

  // ============================================================
  // Special Styles
  // ============================================================

  /// Price text - Bold, Red
  static const TextStyle priceText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: bold,
    color: MedsKaiColors.price,
  );

  /// Price original (strikethrough)
  static const TextStyle priceOriginal = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    color: MedsKaiColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );

  /// Hint text
  static const TextStyle hintText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    color: MedsKaiColors.textHint,
  );

  /// Link text
  static const TextStyle linkText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    color: MedsKaiColors.primary,
  );

  /// AppBar title
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: bold,
    color: MedsKaiColors.textPrimary,
  );

  /// AppBar title on dark
  static const TextStyle appBarTitleDark = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: bold,
    color: MedsKaiColors.white,
  );

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Create style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Create style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Create style for on-primary surfaces
  static TextStyle onPrimary(TextStyle style) {
    return style.copyWith(color: MedsKaiColors.white);
  }
}
