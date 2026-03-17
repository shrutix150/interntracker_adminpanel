import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  const AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: _lightColorScheme,
    textTheme: AppTextStyles.textTheme,
    appBarTheme: _appBarTheme,
    cardTheme: _cardTheme,
    inputDecorationTheme: _inputDecorationTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    dividerTheme: _dividerTheme,
    dataTableTheme: _dataTableTheme,
    chipTheme: _chipTheme,
    splashColor: AppColors.primary.withValues(alpha: 0.08),
    highlightColor: AppColors.hover,
    hoverColor: AppColors.hover,
    dividerColor: AppColors.divider,
    canvasColor: AppColors.surface,
  );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );

  static final AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    centerTitle: false,
    titleTextStyle: AppTextStyles.sectionTitle,
    toolbarHeight: 72,
    surfaceTintColor: Colors.transparent,
  );

  static final CardThemeData _cardTheme = CardThemeData(
    color: AppColors.card,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: AppColors.shadow,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: const BorderSide(color: AppColors.border, width: 1),
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.label,
        helperStyle: AppTextStyles.bodySmall,
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
      );

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.surface,
        ),
      );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  );

  static final DataTableThemeData _dataTableTheme = DataTableThemeData(
    headingRowColor: WidgetStatePropertyAll(AppColors.primarySoft),
    headingTextStyle: AppTextStyles.tableHeader,
    dataTextStyle: AppTextStyles.tableCell,
    dividerThickness: 1,
    headingRowHeight: 52,
    dataRowMinHeight: 56,
    dataRowMaxHeight: 64,
    horizontalMargin: 20,
    columnSpacing: 24,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
  );

  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.primarySoft,
    selectedColor: AppColors.primary,
    disabledColor: AppColors.divider,
    secondarySelectedColor: AppColors.secondary,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    labelStyle: AppTextStyles.bodySmall.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    brightness: Brightness.light,
    side: const BorderSide(color: AppColors.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
  );
}
