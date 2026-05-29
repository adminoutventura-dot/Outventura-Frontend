import 'package:outventura/features/outventura/domain/entities/booking.dart';

class CalendarPageController {
  // Filtra los bookings unificados que contienen excursiones para pintarlos en el calendario
  List<Booking> obtenerEventosActividades(List<Booking> todasLasReservas) {
    return todasLasReservas
        .where((b) => b.lines.any((l) => l.activityId != null))
        .toList();
  }
}
