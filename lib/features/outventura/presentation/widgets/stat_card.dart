import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.colorScheme,
    required this.textTheme,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(60),
            width: 1,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Valor
            Text(
              value,
              style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 2),
            // Etiqueta
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}