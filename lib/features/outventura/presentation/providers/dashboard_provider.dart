import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';

// Genera las estadísticas para el panel principal
final adminDashboardStatsProvider = Provider<AsyncValue<Map<String, int>>>((
  ref,
) {
  final reservasAsync = ref.watch(reservationsProvider);

  return reservasAsync.whenData((List<Booking> todas) {
    final int materialesPuros = todas
        .where((b) => !b.lines.any((l) => l.activityId != null))
        .length;
    final int excursionesContratadas = todas
        .where((b) => b.lines.any((l) => l.activityId != null))
        .length;

    return {
      'totalMateriales': materialesPuros,
      'totalExcursiones': excursionesContratadas,
      'pendientesAprobacion': todas
          .where((b) => b.status.code == 'PENDING')
          .length,
    };
  });
});
