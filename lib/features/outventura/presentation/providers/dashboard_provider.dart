import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';

// Provider para obtener todas las reservas sin paginación para el dashboard
final allReservationsProvider = Provider<AsyncValue<List<Booking>>>((ref) {
  // Asegura que reservationsProvider se ejecute para poblar allBookings.
  final reservasAsync = ref.watch(reservationsProvider);
  final reservationsNotifier = ref.read(reservationsProvider.notifier);
  return reservasAsync.whenData((_) => reservationsNotifier.allBookings);
});

// Genera las estadísticas para el panel principal
final adminDashboardStatsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final reservasAsync = ref.watch(allReservationsProvider);

  return reservasAsync.whenData((List<Booking> todas) {
    final int materialesPuros = todas
        .where((b) => !b.lines.any((l) => l.activityId != null))
        .length;
    final int excursionesContratadas = todas
        .where((b) => b.lines.any((l) => l.activityId != null))
        .length;

    // Calcular estadísticas para hoy
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final int materialesHoy = todas
        .where((b) => 
            !b.lines.any((l) => l.activityId != null) &&
            b.startDate.isAfter(today) &&
            b.startDate.isBefore(tomorrow))
        .length;
    
    final int actividadesHoy = todas
        .where((b) => 
            b.lines.any((l) => l.activityId != null) &&
            b.startDate.isAfter(today) &&
            b.startDate.isBefore(tomorrow))
        .length;

    return {
      'totalMateriales': materialesPuros,
      'totalExcursiones': excursionesContratadas,
      'pendientesAprobacion': todas
          .where((b) => b.status.code == 'PENDING')
          .length,
      'materialesHoy': materialesHoy,
      'actividadesHoy': actividadesHoy,
    };
  });
});
