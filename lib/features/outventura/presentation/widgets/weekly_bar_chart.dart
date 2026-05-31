import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Gráfico de barras semanal con barras de reservas de material y actividad.
class WeeklyBarChart extends StatelessWidget {
  final List<double> actividadesData;
  final List<double> materialesData;
  final ColorScheme cs;
  final TextTheme tt;
  final List<String> dayLabels;
  final String actividadesLabel;
  final String materialesLabel;

  const WeeklyBarChart({
    super.key,
    required this.actividadesData,
    required this.materialesData,
    required this.cs,
    required this.tt,
    required this.dayLabels,
    required this.actividadesLabel,
    required this.materialesLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Valor máximo entre todas las series.
    double maxY = 0;
    for (final val in actividadesData) {
      if (val > maxY) {
        maxY = val;
      }
    }
    for (final val in materialesData) {
      if (val > maxY) {
        maxY = val;
      }
    }

    // Maximo del eje Y: si maxY es menor que 4, se fija en 4. 
    // .ceilToDouble(): Redondea hacia arriba.
    final double topY = maxY < 4 ? 4 : (maxY + 1).ceilToDouble();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: topY,
              titlesData: FlTitlesData(
                // Oculta títulos de los ejes izquierdo, derecho y superior. 
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                // Solo muestra títulos en el eje inferior con las etiquetas de los días.
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      // Convierte el valor del eje (0 a 6) en la etiqueta del día correspondiente.
                      final i = value.toInt();

                      // Si el índice está fuera del rango de etiquetas, devuelve un widget vacío.
                      if (i < 0 || i >= dayLabels.length) {
                        return const SizedBox.shrink();
                      }
                      // Si el índice es válido, devuelve un widget de texto con la etiqueta del día.
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(dayLabels[i], style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      );
                    },
                  ),
                ),
              ),

              // Líneas de la cuadrícula horizontal.
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.10),
                  strokeWidth: 0.8,
                ),
              ),

              // Bordes de las barras: sin bordes.
              borderData: FlBorderData(show: false),

              // Datos de las barras: se generan 7 grupos (uno por día) con barras de actividades y materiales.
              barGroups: List.generate(7, (i) {
                final a = actividadesData[i];
                final m = materialesData[i];

                // Colores consistentes para evitar confusión en la leyenda.
                final actividadColor = cs.primary;
                final materialColor = cs.tertiary;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: a,
                      width: 22,
                      color: actividadColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                    BarChartRodData(
                      toY: m,
                      width: 22,
                      color: materialColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Leyenda del gráfico: puntos de color con etiquetas para actividades y materiales.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Leyenda para actividades.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 5),
                Text(actividadesLabel, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(width: 16),
            // Leyenda para materiales.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.tertiary, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 5),
                Text(materialesLabel, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
