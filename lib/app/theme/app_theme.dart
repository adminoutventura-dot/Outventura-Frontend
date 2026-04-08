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
      titleTextStyle: AppTextStyles.headline.copyWith(
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
      titleLarge: AppTextStyles.appTitle,     
      headlineSmall: AppTextStyles.headline,  
      titleMedium: AppTextStyles.subtitle,   
      bodyLarge: AppTextStyles.bodyBold,     
      bodyMedium: AppTextStyles.body, 
      bodySmall: AppTextStyles.tagline,   
      labelLarge: AppTextStyles.button,   
      labelMedium: AppTextStyles.caption,  
      labelSmall: AppTextStyles.tag,   
      titleSmall: AppTextStyles.overline,  
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
      titleLarge: AppTextStyles.appTitle,      // Para AppBar y títulos grandes
      headlineSmall: AppTextStyles.headline,  // Encabezados
      titleMedium: AppTextStyles.subtitle,    // Subtítulos
      bodyLarge: AppTextStyles.bodyBold,      // Texto en negrita
      bodyMedium: AppTextStyles.body,         // Texto normal
      bodySmall: AppTextStyles.tagline,       // Tagline
      labelLarge: AppTextStyles.button,       // Botones
      labelMedium: AppTextStyles.caption,     // Texto pequeño
      labelSmall: AppTextStyles.tag,          // Chips, etiquetas
      titleSmall: AppTextStyles.overline,     // Overline
    ),
  );
} 
