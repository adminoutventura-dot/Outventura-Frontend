import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

class CalendarPageController {
  // Devuelve todos los eventos (reservas y solicitudes) que ocurren en el día.
  List<Object> eventosDelDia(
    DateTime day,
    List<Booking> misReservas,
    List<Request> misSolicitudes,
    List<Activity> actividades,
  ) {
    final normalized = DateTime(day.year, day.month, day.day);
    final List<Object> result = [];

    for (final r in misReservas) {
      final start = DateTime(r.startDate.year, r.startDate.month, r.startDate.day);
      final end = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
      if (!normalized.isBefore(start) && !normalized.isAfter(end)) {
        result.add(r);
      }
    }

    for (final s in misSolicitudes) {
      final act = actividades.where((e) => e.id == s.activityId).firstOrNull;
      if (act != null) {
        final start = DateTime(act.initDate.year, act.initDate.month, act.initDate.day);
        final end = DateTime(act.endDate.year, act.endDate.month, act.endDate.day);
        if (!normalized.isBefore(start) && !normalized.isAfter(end)) {
          result.add(s);
        }
      }
    }

    return result;
  }
}
