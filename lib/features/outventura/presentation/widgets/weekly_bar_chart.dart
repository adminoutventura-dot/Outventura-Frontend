import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Gráfico de barras semanal con barras apiladas: reservas (abajo) y solicitudes (arriba).
class WeeklyBarChart extends StatelessWidget {
  final List<double> reservasData;
  final List<double> solicitudesData;
  final ColorScheme cs;
  final TextTheme tt;
  final List<String> dayLabels;
  final String reservasLabel;
  final String solicitudesLabel;

  const WeeklyBarChart({
    super.key,
    required this.reservasData,
    required this.solicitudesData,
    required this.cs,
    required this.tt,
    required this.dayLabels,
    required this.reservasLabel,
    required this.solicitudesLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Combina reservas y solicitudes para calcular el máximo del eje Y.
    final combined = <double>[];

    // Suma reservas y solicitudes por día para obtener el total de cada barra.
    for (int dia = 0; dia < 7; dia++) {
      final reservasDelDia = reservasData[dia];
      final solicitudesDelDia = solicitudesData[dia];
      final totalDia = reservasDelDia + solicitudesDelDia;
      combined.add(totalDia);
    }

    // Valalor máximo entre reservas y solicitudes.
    double maxY = combined.first;
    for (final val in combined) {
      if (val > maxY) {
        maxY = val;
      }
    }

    // Maximo del eje Y: si maxY es menor que 4, se fija en 4. 
    // .ceilToDouble(): Redondea hacia arriba.
    final double topY = maxY < 4 ? 4 : (maxY + 1).ceilToDouble();

    // Índice del día de hoy (lunes = 0, domingo = 6) para destacarlo visualmente.
    final int todayIndex = DateTime.now().weekday - 1;

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

              // Datos de las barras: se generan 7 grupos (uno por día) con barras apiladas de reservas y solicitudes.
              barGroups: List.generate(7, (i) {
                final r = reservasData[i];
                final s = solicitudesData[i];

                // El día de hoy usa colores más saturados.
                final isToday = i == todayIndex;
                final reservaColor = isToday ? cs.tertiary : cs.onTertiary;
                final solicitudColor = isToday ? cs.primary : cs.primaryContainer;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: r + s,
                      width: 22,
                      // La barra tiene segmentos apilados: inferior las reservas y el superior las solicitudes.
                      rodStackItems: [
                        BarChartRodStackItem(0, r, reservaColor),
                        BarChartRodStackItem(r, r + s, solicitudColor),
                      ],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Leyenda del gráfico: puntos de color con etiquetas para reservas y solicitudes.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Leyenda para reservas.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 5),
                Text(reservasLabel, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(width: 20),
            
            // Leyenda para solicitudes.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.tertiary, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 5),
                Text(solicitudesLabel, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
