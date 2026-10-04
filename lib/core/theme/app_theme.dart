import 'package:flutter/material.dart';

abstract final class AppColors {
  static const pageBackground = Color(0xFFF4F1EA);
  static const surface = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF2C2C2C);
  static const secondaryText = Color(0xFF8C8275);
  static const primary = Color(0xFF4A7C59);
  static const border = Color(0xFFE7E2D8);
}

abstract final class AppTheme {
  static final light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.surface,
      secondary: AppColors.primary,
      onSecondary: AppColors.surface,
      surface: AppColors.surface,
      surfaceDim: AppColors.surface,
      surfaceBright: AppColors.surface,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surface,
      surfaceContainerHighest: AppColors.surface,
      onSurface: AppColors.primaryText,
      onSurfaceVariant: AppColors.secondaryText,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    );
    final baseTextTheme = Typography.material2021().black.apply(
      bodyColor: AppColors.primaryText,
      displayColor: AppColors.primaryText,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.pageBackground,
      dividerColor: AppColors.border,
      cardTheme: const CardThemeData(color: AppColors.surface),
      textTheme: baseTextTheme.copyWith(
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.secondaryText,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.secondaryText,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          color: AppColors.secondaryText,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      useMaterial3: true,
    );
  }
}