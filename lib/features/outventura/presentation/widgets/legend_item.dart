import 'package:flutter/material.dart';

// Línea de leyenda para el gráfico de pastel.
class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final TextTheme tt;
  final ColorScheme cs;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    required this.tt,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Indicador de color
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          
          // Texto de la leyenda
          Expanded(child: Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant))),

          // Valor numérico
          Text('$value', style: tt.labelMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
