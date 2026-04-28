import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.onPrimary,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surfaceContainer,
      foregroundColor: AppColors.onPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.onPrimary,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primaryContainer: AppColors.primaryContainer,
      surfaceContainer: AppColors.surfaceContainer,
      primary: AppColors.primary,

      onPrimaryContainer: AppColors.onPrimaryContainer,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      onPrimary: AppColors.onPrimary,

      secondary: AppColors.secondary,

      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,

      error: AppColors.error,
      onError: AppColors.onPrimary,

      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
    ),
    
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleLarge, 
      headlineSmall: AppTextStyles.headlineSmall,
      titleMedium: AppTextStyles.titleMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
      titleSmall: AppTextStyles.titleSmall,  
    ),
    
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkOnPrimary,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkSurfaceContainer,
      foregroundColor: AppColors.darkOnPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.darkOnPrimary,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primaryContainer: AppColors.darkPrimaryContainer,
      surfaceContainer: AppColors.darkSurfaceContainer,
      primary: AppColors.darkPrimary,

      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      onPrimary: AppColors.darkOnPrimary,

      secondary: AppColors.darkSecondary,

      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.darkOnTertiary,

      error: AppColors.darkError,
      onError: AppColors.darkOnPrimary,

      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
    ),
    
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleLarge,
      headlineSmall: AppTextStyles.headlineSmall,
      titleMedium: AppTextStyles.titleMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
      titleSmall: AppTextStyles.titleSmall,
    ),

  );
}
