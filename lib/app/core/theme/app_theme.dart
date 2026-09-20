import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// MedsKai App Theme - Material Design 3
///
/// Usage:
/// ```dart
/// MaterialApp(theme: AppTheme.light)
/// ```
class AppTheme {
  AppTheme._();

  // ============================================================
  // Light Theme
  // ============================================================

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.fontFamily,
        primaryColor: MedsKaiColors.primary,
        scaffoldBackgroundColor: MedsKaiColors.background,
        disabledColor: const Color(0xFFBABFC4),
        brightness: Brightness.light,
        hintColor: MedsKaiColors.textHint,
        cardColor: MedsKaiColors.white,
        dividerColor: MedsKaiColors.border,
        extensions: const [MedsKaiThemeColors.light],

        // Color Scheme
        colorScheme: const ColorScheme.light(
          primary: MedsKaiColors.primary,
          secondary: MedsKaiColors.secondary,
          surface: MedsKaiColors.white,
          error: MedsKaiColors.error,
          onPrimary: MedsKaiColors.white,
          onSecondary: MedsKaiColors.white,
          onSurface: MedsKaiColors.textPrimary,
          onError: MedsKaiColors.white,
        ),

        // AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: MedsKaiColors.white,
          foregroundColor: MedsKaiColors.textPrimary,
          elevation: AppDimensions.appBarElevation,
          centerTitle: true,
          iconTheme: const IconThemeData(color: MedsKaiColors.textPrimary),
          titleTextStyle: AppTextStyles.appBarTitle,
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MedsKaiColors.buttonColor,
            foregroundColor: MedsKaiColors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.buttonPaddingH,
              vertical: AppDimensions.buttonPaddingV,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            textStyle: AppTextStyles.buttonPrimary,
          ),
        ),

        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: MedsKaiColors.buttonColor,
            side: const BorderSide(
              color: MedsKaiColors.buttonColor,
              width: AppDimensions.buttonBorderWidth,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.buttonPaddingH,
              vertical: AppDimensions.buttonPaddingV,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            textStyle: AppTextStyles.buttonSecondary,
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MedsKaiColors.buttonColor,
            textStyle: AppTextStyles.buttonText,
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: MedsKaiColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            borderSide: const BorderSide(color: MedsKaiColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            borderSide: const BorderSide(color: MedsKaiColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            borderSide: const BorderSide(
              color: MedsKaiColors.primary,
              width: AppDimensions.inputBorderWidthFocused,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            borderSide: const BorderSide(color: MedsKaiColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.inputPaddingH,
            vertical: AppDimensions.inputPaddingV,
          ),
          hintStyle: AppTextStyles.hintText,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: MedsKaiColors.textSecondary,
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: MedsKaiColors.white,
          elevation: AppDimensions.cardElevation,
          shadowColor: MedsKaiColors.cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          margin: const EdgeInsets.all(AppDimensions.cardMargin),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: MedsKaiColors.sectionBg,
          selectedColor: MedsKaiColors.primary,
          labelStyle: AppTextStyles.labelMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: MedsKaiColors.white,
          selectedItemColor: MedsKaiColors.primary,
          unselectedItemColor: MedsKaiColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall,
        ),

        // Tab Bar Theme
        tabBarTheme: TabBarThemeData(
          labelColor: MedsKaiColors.primary,
          unselectedLabelColor: MedsKaiColors.textSecondary,
          indicatorColor: MedsKaiColors.primary,
          labelStyle: AppTextStyles.labelLarge,
          unselectedLabelStyle: AppTextStyles.labelMedium,
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: MedsKaiColors.buttonColor,
          foregroundColor: MedsKaiColors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
        ),

        // Text Theme
        textTheme: _textTheme,
      );

  // ============================================================
  // Dark Theme
  // ============================================================

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.fontFamily,
        primaryColor: MedsKaiColors.primary,
        scaffoldBackgroundColor: const Color(0xFF121212),
        disabledColor: const Color(0xffa2a7ad),
        brightness: Brightness.dark,
        hintColor: const Color(0xFFbebebe),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: const Color(0xFF2D2D2D),
        extensions: const [MedsKaiThemeColors.dark],

        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: MedsKaiColors.primary,
          secondary: MedsKaiColors.secondary,
          surface: Color(0xFF1E1E1E),
          error: MedsKaiColors.error,
        ),

        // AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: AppTextStyles.appBarTitleDark,
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MedsKaiColors.buttonColor,
            foregroundColor: MedsKaiColors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.buttonPaddingH,
              vertical: AppDimensions.buttonPaddingV,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            textStyle: AppTextStyles.buttonPrimary,
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MedsKaiColors.buttonColor,
          ),
        ),

        // Text Theme (dark)
        textTheme: _textThemeDark,
      );

  // ============================================================
  // Text Themes
  // ============================================================

  static TextTheme get _textTheme => TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      );

  static TextTheme get _textThemeDark => TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.white),
        displayMedium:
            AppTextStyles.displayMedium.copyWith(color: Colors.white),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: Colors.white),
        headlineLarge:
            AppTextStyles.headlineLarge.copyWith(color: Colors.white),
        headlineMedium:
            AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        headlineSmall:
            AppTextStyles.headlineSmall.copyWith(color: Colors.white),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.white),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: Colors.white),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: Colors.white),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
      );
}

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
}
