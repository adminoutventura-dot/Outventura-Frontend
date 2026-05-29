import 'package:outventura/features/outventura/domain/entities/booking.dart';

class WeeklyData {
  final DateTime startOfWeek;
  final List<Booking>
  bookingsDeLaSemana; 

  const WeeklyData({
    required this.startOfWeek,
    required this.bookingsDeLaSemana,
  });

  // Cuenta cuántas excursiones se han solicitado esta semana
  int get totalExcursionesSemana {
    return bookingsDeLaSemana.where((b) {
      return b.lines.any((l) => l.activityId != null);
    }).length;
  }
}
