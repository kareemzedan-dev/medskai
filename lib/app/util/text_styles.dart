import 'package:flutter/material.dart';
import 'package:flutter_app/app/util/theme.dart';

/// Centralized text styles to replace 1,360+ inline TextStyle declarations.
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const heading1 = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: MedsKaiColors.textPrimary,
  );

  static const heading2 = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: MedsKaiColors.textPrimary,
  );

  static const heading3 = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: MedsKaiColors.textPrimary,
  );

  static const heading4 = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: MedsKaiColors.textPrimary,
  );

  // Body text
  static const bodyLarge = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: MedsKaiColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: MedsKaiColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: MedsKaiColors.textSecondary,
  );

  // Labels
  static const label = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: MedsKaiColors.textSecondary,
  );

  static const labelBold = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: MedsKaiColors.textPrimary,
  );

  // Buttons
  static const button = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: MedsKaiColors.white,
  );

  static const buttonSmall = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: MedsKaiColors.white,
  );

  // Prices
  static const price = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: MedsKaiColors.success,
  );

  static const priceOld = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: MedsKaiColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );

  // Section titles
  static const sectionTitle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: MedsKaiColors.textPrimary,
  );

  // Navigation
  static const navLabel = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static const appBarTitle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: MedsKaiColors.textPrimary,
  );
}
