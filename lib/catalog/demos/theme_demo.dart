import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_colors.dart';
import 'package:outventura/app/theme/app_text_styles.dart';

class ThemeDemo extends StatelessWidget {
  const ThemeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Colores y Tipografía')),
      body: DefaultTextStyle.merge(
        style: tt.bodyMedium?.copyWith(color: cs.onSurface) ?? const TextStyle(),
        child: ListView(
          padding: const EdgeInsets.all(30),
          children: [
          // ---- COLORES ----
          Text(
            'COLORES',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 20),

          const Text('AppColors – onSecondaryContainer'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.onTertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#201A14',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – onPrimaryContainer'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.onPrimaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#3E3327',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – secondary'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#A6774E',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – primary'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#588C23',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – inverseSurface'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#3B593F',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – onPrimary'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.onPrimary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.onSurfaceVariant.withAlpha(80)),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              '#F2F0F2',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – onSurfaceVariant'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.onSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#9A979A',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – surface'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.onSurfaceVariant.withAlpha(80)),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              '#FFFFFF',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – onSurface'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.onSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#1C1C1C',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – primaryContainer'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              '#D4E8C2',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – error'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#B53A3A',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – secondaryContainer'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#88C1E9',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – tertiary'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#324756',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          // ---- TIPOGRAFÍA ----
          const SizedBox(height: 50),
          Text(
            'TIPOGRAFÍAS',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 20),

          const Text('AppTextStyles – titleLarge'),
          const SizedBox(height: 15),
          const Text('• Título', style: AppTextStyles.titleLarge),

          const SizedBox(height: 20),
          const Text('AppTextStyles – headlineSmall'),
          const SizedBox(height: 15),
          const Text('• Encabezado', style: AppTextStyles.headlineSmall),

          const SizedBox(height: 20),
          const Text('AppTextStyles – titleMedium'),
          const SizedBox(height: 15),
          const Text('• Subtítulo', style: AppTextStyles.titleMedium),

          const SizedBox(height: 20),
          const Text('AppTextStyles – bodyLarge'),
          const SizedBox(height: 15),
          const Text('• Texto en negrita', style: AppTextStyles.bodyLarge),

          const SizedBox(height: 20),
          const Text('AppTextStyles – bodyMedium'),
          const SizedBox(height: 15),
          const Text('• Texto estándar del cuerpo', style: AppTextStyles.bodyMedium),

          const SizedBox(height: 20),
          const Text('AppTextStyles – bodySmall'),
          const SizedBox(height: 15),
          const Text('• Etiqueta de apoyo', style: AppTextStyles.bodySmall),

          const SizedBox(height: 20),
          const Text('AppTextStyles – labelLarge'),
          const SizedBox(height: 15),
          const Text('• Botón', style: AppTextStyles.labelLarge),

          const SizedBox(height: 20),
          const Text('AppTextStyles – labelMedium'),
          const SizedBox(height: 15),
          const Text('• Texto pequeño/caption', style: AppTextStyles.labelMedium),

          const SizedBox(height: 20),
          const Text('AppTextStyles – labelSmall'),
          const SizedBox(height: 15),
          const Text('• Texto para chips', style: AppTextStyles.labelSmall),

          const SizedBox(height: 20),
          const Text('AppTextStyles – titleSmall'),
          const SizedBox(height: 15),
          const Text('• Overline', style: AppTextStyles.titleSmall),
          
          ],
        ),
      ),
    );
  }
}
