import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.offWhite,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkGreen,
      // Color del texto y los íconos
      foregroundColor: AppColors.offWhite,
      // Reacción del AppBar al scroll
      surfaceTintColor: Colors.transparent,
      // Estilo del título del AppBar
      titleTextStyle: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.offWhite,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.green,
      onPrimary: AppColors.offWhite,        

      secondary: AppColors.tan,
      onSecondary: AppColors.lightBrown,

      tertiary: AppColors.darkBlue,
      onTertiary: AppColors.offWhite,

      primaryContainer: AppColors.paleGreen,
      onPrimaryContainer: AppColors.brown,

      secondaryContainer: AppColors.lightBlue,
      onSecondaryContainer: AppColors.darkBrown,

      surface: AppColors.white,
      onSurface: AppColors.black,  

      inverseSurface: AppColors.darkGreen,
      onInverseSurface: AppColors.white,

      surfaceContainer: AppColors.white,      
      onSurfaceVariant: AppColors.gray,      

      error: AppColors.red,
      onError: AppColors.offWhite,
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
    scaffoldBackgroundColor: AppColors.darkBlue,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      // Los colores se tomarán del Theme (colorScheme) automáticamente
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.green,
      onPrimary: AppColors.offWhite,

      secondary: AppColors.tan,
      onSecondary: AppColors.offWhite,

      tertiary: AppColors.lightBlue,
      onTertiary: AppColors.offWhite,

      primaryContainer: AppColors.darkGreen,
      onPrimaryContainer: AppColors.white,

      secondaryContainer: AppColors.darkBrown,
      onSecondaryContainer: AppColors.lightBlue,

      surface: AppColors.darkBlue,
      onSurface: AppColors.offWhite,

      inverseSurface: AppColors.white,
      onInverseSurface: AppColors.darkGreen,

      surfaceContainer: AppColors.darkBlue,
      onSurfaceVariant: AppColors.gray,

      error: AppColors.red,
      onError: AppColors.offWhite,
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
