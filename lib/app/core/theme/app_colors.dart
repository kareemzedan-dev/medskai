import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// MedsKai Brand Colors - Exact Match to Website https://medskai.com/
///
/// Static const colors for compile-time usage.
/// For theme-aware colors, use [MedsKaiThemeColors.of(context)].
class MedsKaiColors {
  MedsKaiColors._();

  // ============================================================
  // Primary Colors
  // ============================================================

  /// Primary Color (Purple-Blue from website)
  static const Color primary = Color(0xFF707BED);

  /// Secondary Color (Deep Purple - button color from website)
  static const Color secondary = Color(0xFF673ABF);

  /// Button Color (Deep Purple - exact from website buttons)
  static const Color buttonColor = Color(0xFF673ABF);

  /// Purple Accent (for gradient end/hover states)
  static const Color purpleAccent = Color(0xFF3A2374);

  /// Dark Blue (used for some text)
  static const Color darkBlue = Color(0xFF082645);

  // ============================================================
  // Background Colors
  // ============================================================

  /// Main background - White
  static const Color background = Color(0xFFFFFFFF);

  /// Section background - Light Gray (exact)
  static const Color sectionBg = Color(0xFFF5F7F8);

  /// Alternative Light Gray
  static const Color sectionBgAlt = Color(0xFFECEEEF);

  /// Pure White
  static const Color white = Color(0xFFFFFFFF);

  // ============================================================
  // Text Colors (exact from website)
  // ============================================================

  /// Dark Gray (body text)
  static const Color textPrimary = Color(0xFF212427);

  /// Secondary Dark Blue
  static const Color textDark = Color(0xFF082645);

  /// Body text color from website
  static const Color textBody = Color(0xFF444444);

  /// Medium Gray
  static const Color textSecondary = Color(0xFF7A7A7A);

  /// Light Gray (hints)
  static const Color textHint = Color(0xFF9CA3AF);

  // ============================================================
  // Border & Divider
  // ============================================================

  /// Light Gray Border
  static const Color border = Color(0xFFECEEEF);

  /// Divider color
  static const Color divider = Color(0xFFE4E4E4);

  // ============================================================
  // Accent Colors (from website)
  // ============================================================

  /// Orange (highlights)
  static const Color accent = Color(0xFFFF6900);

  /// Gold (ratings/stars)
  static const Color gold = Color(0xFFFF971A);

  // ============================================================
  // Status Colors (exact from website)
  // ============================================================

  /// Green (completed/success)
  static const Color success = Color(0xFF00D084);

  /// Red (failed/error)
  static const Color error = Color(0xFFF02D00);

  /// Red for prices
  static const Color price = Color(0xFFF02D00);

  /// Info color
  static const Color info = Color(0xFF707BED);

  /// Warning color
  static const Color warning = Color(0xFFFF6900);

  // ============================================================
  // Utility Colors
  // ============================================================

  /// Pure Black
  static const Color black = Color(0xFF000000);

  /// Transparent
  static const Color transparent = Colors.transparent;

  // ============================================================
  // Shadow Colors
  // ============================================================

  /// Card Shadow Color (purple tint like website)
  static Color get cardShadow => const Color(0xFF6B39BF).withOpacity(0.64);

  /// Light shadow for elevation
  static Color get shadowLight => Colors.black.withOpacity(0.07);

  /// Medium shadow
  static Color get shadowMedium => Colors.black.withOpacity(0.12);

  // ============================================================
  // Gradients
  // ============================================================

  /// Header gradient (exact from website: 180deg, #707BED 0%, #3A2374 100%)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, purpleAccent],
  );

  /// Button gradient
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [buttonColor, Color(0xFF5A2FA8)],
  );

  /// Primary gradient (horizontal)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, Color(0xFF5A6BE0)],
  );

  /// Success gradient
  static LinearGradient get successGradient => LinearGradient(
        colors: [success, success.withOpacity(0.85)],
      );

  // ============================================================
  // Box Shadows
  // ============================================================

  /// Website shadow (exact: -5px 5px 25px rgba(0,0,0,0.07))
  static List<BoxShadow> get websiteShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 25,
          offset: const Offset(-5, 5),
        ),
      ];

  /// Card shadow
  static List<BoxShadow> get cardBoxShadow => [
        BoxShadow(
          color: const Color(0xFF6B39BF).withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Button shadow
  static List<BoxShadow> buttonShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // ============================================================
  // Backwards Compatibility Aliases
  // ============================================================

  static const Color cardBg = white;
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================================
  // Pre-computed Opacity Variants (avoid repeated withOpacity calls)
  // ============================================================

  /// Primary at 20% opacity
  static const Color primary20 = Color(0x33707BED);

  /// Primary at 15% opacity
  static const Color primary15 = Color(0x26707BED);

  /// Primary at 10% opacity
  static const Color primary10 = Color(0x1A707BED);

  /// Primary at 8% opacity
  static const Color primary08 = Color(0x14707BED);

  /// Primary at 5% opacity
  static const Color primary05 = Color(0x0D707BED);

  /// Shadow purple (#6B39BF) at 15% opacity
  static const Color shadow15 = Color(0x266B39BF);

  /// Shadow purple (#6B39BF) at 8% opacity
  static const Color shadow08 = Color(0x146B39BF);

  /// Success at 12% opacity
  static const Color success12 = Color(0x1F00D084);

  /// Success at 10% opacity
  static const Color success10 = Color(0x1A00D084);

  /// Black at 15% opacity
  static const Color black15 = Color(0x26000000);

  /// Black at 10% opacity
  static const Color black10 = Color(0x1A000000);

  /// Black at 8% opacity
  static const Color black08 = Color(0x14000000);

  /// Error at 10% opacity
  static const Color error10 = Color(0x1AF02D00);

  /// TextSecondary at 70% opacity
  static const Color textSecondary70 = Color(0xB37A7A7A);
}

/// Theme-aware color extension for dark mode support.
///
/// Usage: `MedsKaiThemeColors.of(context).background`
/// Or shortcut: `context.kaiColors.background`
@immutable
class MedsKaiThemeColors extends ThemeExtension<MedsKaiThemeColors> {
  final Color background;
  final Color surface;
  final Color sectionBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color divider;
  final Color cardBg;

  const MedsKaiThemeColors({
    required this.background,
    required this.surface,
    required this.sectionBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.divider,
    required this.cardBg,
  });

  /// Light theme colors
  static const light = MedsKaiThemeColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    sectionBg: Color(0xFFF5F7F8),
    textPrimary: Color(0xFF212427),
    textSecondary: Color(0xFF7A7A7A),
    textHint: Color(0xFF9CA3AF),
    border: Color(0xFFECEEEF),
    divider: Color(0xFFE4E4E4),
    cardBg: Color(0xFFFFFFFF),
  );

  /// Dark theme colors
  static const dark = MedsKaiThemeColors(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    sectionBg: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFE0E0E0),
    textSecondary: Color(0xFF9E9E9E),
    textHint: Color(0xFF757575),
    border: Color(0xFF2D2D2D),
    divider: Color(0xFF383838),
    cardBg: Color(0xFF1E1E1E),
  );

  /// Get theme-aware colors from context
  static MedsKaiThemeColors of(BuildContext context) {
    return Theme.of(context).extension<MedsKaiThemeColors>() ?? light;
  }

  @override
  MedsKaiThemeColors copyWith({
    Color? background, Color? surface, Color? sectionBg,
    Color? textPrimary, Color? textSecondary, Color? textHint,
    Color? border, Color? divider, Color? cardBg,
  }) {
    return MedsKaiThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      sectionBg: sectionBg ?? this.sectionBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      cardBg: cardBg ?? this.cardBg,
    );
  }

  @override
  MedsKaiThemeColors lerp(MedsKaiThemeColors? other, double t) {
    if (other is! MedsKaiThemeColors) return this;
    return MedsKaiThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      sectionBg: Color.lerp(sectionBg, other.sectionBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
    );
  }
}

/// Extension for easy access: `context.kaiColors`
extension MedsKaiThemeColorsExt on BuildContext {
  MedsKaiThemeColors get kaiColors => MedsKaiThemeColors.of(this);
}
