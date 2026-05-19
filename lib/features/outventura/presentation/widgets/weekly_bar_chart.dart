import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Gráfico de barras semanal con barras apiladas: reservas (abajo) y solicitudes (arriba).
/// Destaca el día de hoy. Incluye una leyenda de color en la parte inferior.
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
    final combined = List.generate(7, (i) => reservasData[i] + solicitudesData[i]);
    final double maxY = combined.reduce((a, b) => a > b ? a : b);
    final double topY = maxY < 4 ? 4 : (maxY + 1).ceilToDouble();
    final int todayIndex = DateTime.now().weekday - 1;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: topY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => cs.inverseSurface,
                  getTooltipItem: (group, _, rod, _) {
                    final r = reservasData[group.x].toInt();
                    final s = solicitudesData[group.x].toInt();
                    return BarTooltipItem(
                      '${r + s}',
                      TextStyle(color: cs.onInverseSurface, fontWeight: FontWeight.w600, fontSize: 12),
                      children: [
                        TextSpan(
                          text: '\nR: $r  S: $s',
                          style: TextStyle(
                            color: cs.onInverseSurface.withValues(alpha: 0.70),
                            fontWeight: FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i < 0 || i >= dayLabels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(dayLabels[i], style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.10),
                  strokeWidth: 0.8,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (i) {
                final r = reservasData[i];
                final s = solicitudesData[i];
                final isToday = i == todayIndex;
                final reservaColor = isToday ? cs.secondary : cs.secondaryContainer;
                final solicitudColor = isToday ? cs.tertiary : cs.tertiaryContainer;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: r + s,
                      width: 22,
                      rodStackItems: [
                        BarChartRodStackItem(0, r, reservaColor),
                        BarChartRodStackItem(r, r + s, solicitudColor),
                      ],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: cs.secondary, label: reservasLabel, tt: tt, cs: cs),
            const SizedBox(width: 20),
            _LegendDot(color: cs.tertiary, label: solicitudesLabel, tt: tt, cs: cs),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final TextTheme tt;
  final ColorScheme cs;

  const _LegendDot({required this.color, required this.label, required this.tt, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
