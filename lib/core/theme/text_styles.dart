import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get display => GoogleFonts.poppins(
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.9,
    color: AppColors.textPrimary,
  );

  static TextStyle get pageTitle => GoogleFonts.poppins(
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get sectionTitle => GoogleFonts.poppins(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.poppins(
    fontSize: 14,
    height: 1.55,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static TextStyle get label => GoogleFonts.poppins(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get tableHeader => GoogleFonts.poppins(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get tableCell => GoogleFonts.poppins(
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: display,
    headlineLarge: pageTitle,
    headlineMedium: sectionTitle,
    titleLarge: cardTitle,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: bodySmall,
    labelLarge: button,
    labelMedium: label,
    titleMedium: tableCell,
  );
}
