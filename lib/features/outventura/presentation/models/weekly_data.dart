import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

/// Datos de reservas y solicitudes para una semana.
class WeeklyData {
  final List<double> reservasData;
  final List<double> solicitudesData;

  WeeklyData({
    required this.reservasData,
    required this.solicitudesData,
  });

  // Calcula los datos semanales de reservas y solicitudes.
  factory WeeklyData.calculate({
    required List<Booking> reservas,
    required List<Request> solicitudes,
    required List<Activity> actividades,
    required DateTime today,
  }) {
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final reservasData = List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final dayEnd = day.add(const Duration(days: 1));
      // Para reservas, usa las fechas de la Activity asociada
      return reservas.where((r) {
        final act = actividades.where((a) => a.id == r.activityId).firstOrNull;
        if (act == null) return false;
        return act.initDate.isBefore(dayEnd) && act.endDate.isAfter(day);
      }).length.toDouble();
    });
    final solicitudesData = List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final dayEnd = day.add(const Duration(days: 1));
      return solicitudes
          .where((s) {
            final act = actividades
                .where((a) => a.id == s.activityId)
                .firstOrNull;
            if (act == null) return false;
            return act.initDate.isBefore(dayEnd) && act.endDate.isAfter(day);
          })
          .length
          .toDouble();
    });
    return WeeklyData(
      reservasData: reservasData,
      solicitudesData: solicitudesData,
    );
  }
}
