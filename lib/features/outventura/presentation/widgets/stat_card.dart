import 'package:flutter/material.dart';

// Tarjeta de estadística reutilizable con dos modos:
class StatCard extends StatelessWidget {
  final String value;
  final String label;

  // Si se especifica, activa el modo plain con este color para el texto.
  final Color? foregroundColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bool isPlain = foregroundColor != null;
    final Color textColor = foregroundColor ?? cs.onSurface;
    final Color labelColor = foregroundColor?.withAlpha(200) ?? cs.onSurfaceVariant;

    final column = Column(
      crossAxisAlignment: isPlain ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: isPlain
              ? tt.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold)
              : tt.labelLarge?.copyWith(color: textColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: labelColor, letterSpacing: 0.8),
        ),
      ],
    );

    if (isPlain) return column;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: cs.surface.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.onSurfaceVariant.withAlpha(60),
          width: 1,
        ),
      ),
      child: column,
    );
  }
}