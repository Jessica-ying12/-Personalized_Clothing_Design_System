import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme,
        textTheme: _textTheme,
        scaffoldBackgroundColor: AppColors.background,
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          space: 1,
          thickness: 1,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTextStyles.labelLg,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smd,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.grey200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.grey200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.grey800,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.titleMd.copyWith(
            color: AppColors.grey800,
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: _darkColorScheme,
        textTheme: _textTheme,
        scaffoldBackgroundColor: AppColors.grey900,
      );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.grey600,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.grey100,
    onSecondaryContainer: AppColors.grey800,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.error,
    surface: AppColors.surface,
    onSurface: AppColors.grey800,
    surfaceContainerHighest: AppColors.grey50,
    outline: AppColors.grey200,
    outlineVariant: AppColors.grey100,
    scrim: AppColors.scrim,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7A9EFF),
    onPrimary: Color(0xFF0D1117),
    primaryContainer: Color(0xFF1A2E66),
    onPrimaryContainer: Color(0xFFBDD1FF),
    secondary: Color(0xFF9AA3B2),
    onSecondary: Color(0xFF1E2430),
    secondaryContainer: Color(0xFF333A47),
    onSecondaryContainer: Color(0xFFDDE1EB),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF0D1117),
    errorContainer: Color(0xFF5C1A1A),
    onErrorContainer: Color(0xFFFFB3B3),
    surface: Color(0xFF1E2430),
    onSurface: Color(0xFFDDE1EB),
    surfaceContainerHighest: Color(0xFF333A47),
    outline: Color(0xFF4A5263),
    outlineVariant: Color(0xFF333A47),
    scrim: AppColors.scrim,
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayLg,
    headlineLarge: AppTextStyles.headingLg,
    headlineMedium: AppTextStyles.headingMd,
    headlineSmall: AppTextStyles.headingSm,
    titleLarge: AppTextStyles.titleLg,
    titleMedium: AppTextStyles.titleMd,
    bodyLarge: AppTextStyles.bodyLg,
    bodyMedium: AppTextStyles.bodyMd,
    bodySmall: AppTextStyles.bodySm,
    labelLarge: AppTextStyles.labelLg,
    labelMedium: AppTextStyles.labelMd,
    labelSmall: AppTextStyles.caption,
  );
}
