import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.offWhite,
    colorScheme: const ColorScheme.light(
      primary: AppColors.green,
      onPrimary: AppColors.offWhite,        

      secondary: AppColors.darkGreen,
      onSecondary: AppColors.offWhite,

      surface: AppColors.offWhite,           
      onSurface: AppColors.darkBrown,        
      onSurfaceVariant: AppColors.gray,      

      tertiary: AppColors.darkBlue,
      onTertiary: AppColors.offWhite,

      error: AppColors.tan,
      onError: AppColors.offWhite,
    ),
    
    textTheme: const TextTheme(
      displaySmall: AppTextStyles.appTitle,
      bodySmall: AppTextStyles.tagline,
      bodyMedium: AppTextStyles.body,
      labelLarge: AppTextStyles.bodyBold,
    ),
  );
}