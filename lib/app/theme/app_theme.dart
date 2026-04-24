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
      backgroundColor: AppColors.inverseSurface,
      foregroundColor: AppColors.onPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.onPrimary,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,

      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,

      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onPrimary,

      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,

      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,

      surface: AppColors.surface,
      onSurface: AppColors.onSurface,

      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.surface,

      surfaceContainer: AppColors.surface,
      onSurfaceVariant: AppColors.onSurfaceVariant,

      error: AppColors.error,
      onError: AppColors.onPrimary,
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
      backgroundColor: AppColors.darkInverseSurface,
      foregroundColor: AppColors.darkOnPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.darkOnPrimary,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,

      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,

      tertiary: AppColors.darkTertiary,
      onTertiary: AppColors.darkOnPrimary,

      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,

      secondaryContainer: AppColors.darkSecondaryContainer,
      onSecondaryContainer: AppColors.darkOnSecondaryContainer,

      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,

      inverseSurface: AppColors.darkInverseSurface,
      onInverseSurface: AppColors.darkSurface,

      surfaceContainer: AppColors.darkSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,

      error: AppColors.darkError,
      onError: AppColors.darkOnPrimary,
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
