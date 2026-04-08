import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_colors.dart';
import 'package:outventura/app/theme/app_text_styles.dart';

class ThemeDemo extends StatelessWidget {
  const ThemeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

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

          const Text('AppColors – darkBrown'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.darkBrown,
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
          const Text('AppColors – brown'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brown,
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
          const Text('AppColors – tan'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tan,
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
          const Text('AppColors – green'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.green,
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
          const Text('AppColors – darkGreen'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
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
          const Text('AppColors – offWhite'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray.withAlpha(80)),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              '#F2F0F2',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.gray,
              ),
            ),
          ),


          const SizedBox(height: 12),
          const Text('AppColors – gray'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gray,
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
          const Text('AppColors – white'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray.withAlpha(80)),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              '#FFFFFF',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.gray,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – black'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#000000',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – lightGreen'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightBrown,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#F4F8EF',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.gray,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – paleGreen'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '#F1EFE8',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.gray,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text('AppColors – red'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.red,
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
          const Text('AppColors – lightBlue'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
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
          const Text('AppColors – darkBlue'),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
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

          const Text('AppTextStyles – appTitle'),
          const SizedBox(height: 15),
          const Text('• Título', style: AppTextStyles.appTitle),

          const SizedBox(height: 20),
          const Text('AppTextStyles – headline'),
          const SizedBox(height: 15),
          const Text('• Encabezado', style: AppTextStyles.headline),

          const SizedBox(height: 20),
          const Text('AppTextStyles – subtitle'),
          const SizedBox(height: 15),
          const Text('• Subtítulo', style: AppTextStyles.subtitle),

          const SizedBox(height: 20),
          const Text('AppTextStyles – bodyBold'),
          const SizedBox(height: 15),
          const Text('• Texto en negrita', style: AppTextStyles.bodyBold),

          const SizedBox(height: 20),
          const Text('AppTextStyles – body'),
          const SizedBox(height: 15),
          const Text('• Texto estándar del cuerpo', style: AppTextStyles.body),

          const SizedBox(height: 20),
          const Text('AppTextStyles – tagline'),
          const SizedBox(height: 15),
          const Text('• Etiqueta de apoyo', style: AppTextStyles.tagline),

          const SizedBox(height: 20),
          const Text('AppTextStyles – caption'),
          const SizedBox(height: 15),
          const Text('• Texto pequeño/caption', style: AppTextStyles.caption),

          const SizedBox(height: 20),
          const Text('AppTextStyles – tag'),
          const SizedBox(height: 15),
          const Text('• Texto para chips', style: AppTextStyles.tag),

          const SizedBox(height: 20),
          const Text('AppTextStyles – overline'),
          const SizedBox(height: 15),
          const Text('• Overline', style: AppTextStyles.overline),

          const SizedBox(height: 20),
          const Text('AppTextStyles – button'),
          const SizedBox(height: 15),
          const Text('• Botón', style: AppTextStyles.button),

          const SizedBox(height: 20),
          const Text('AppTextStyles – link'),
          const SizedBox(height: 15),
          const Text('• Enlace', style: AppTextStyles.link),
          
          ],
        ),
      ),
    );
  }
}
