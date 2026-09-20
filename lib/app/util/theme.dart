/// Theme Backwards Compatibility File
///
/// This file re-exports from the new core/theme location
/// for backwards compatibility with existing imports.
///
/// New code should import from:
/// ```dart
/// import 'package:flutter_app/app/core/theme/theme.dart';
/// ```
library theme;

// Re-export all theme files from core
export '../core/theme/app_colors.dart';
export '../core/theme/app_text_styles.dart';
export '../core/theme/app_dimensions.dart';
export '../core/theme/app_theme.dart';

// Legacy exports for backwards compatibility
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Legacy ThemeProvider for backwards compatibility
@Deprecated('Use MedsKaiColors instead')
class ThemeProvider {
  static const appColor = MedsKaiColors.primary;
  static const secondaryAppColor = MedsKaiColors.textPrimary;
  static const whiteColor = MedsKaiColors.white;
  static const blackColor = MedsKaiColors.black;
  static const greyColor = MedsKaiColors.textSecondary;
  static const backgroundColor = MedsKaiColors.background;
  static const orangeColor = MedsKaiColors.primary;
  static const greenColor = MedsKaiColors.success;
  static const redColor = MedsKaiColors.error;
  static const transparent = MedsKaiColors.transparent;
  static const sectionBackgroundColor = MedsKaiColors.sectionBg;
  static const borderColor = MedsKaiColors.border;
  static const accentColor = MedsKaiColors.primary;
  static const textColor = MedsKaiColors.textPrimary;

  static const titleStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: MedsKaiColors.white,
  );
}

/// Legacy theme data - use AppTheme.light instead
@Deprecated('Use AppTheme.light instead')
ThemeData get light => AppTheme.light;

/// Legacy theme data - use AppTheme.dark instead
@Deprecated('Use AppTheme.dark instead')
ThemeData get dark => AppTheme.dark;

/// Legacy text theme
@Deprecated('Use AppTheme.light.textTheme instead')
TextTheme get txtTheme => AppTheme.light.textTheme;
