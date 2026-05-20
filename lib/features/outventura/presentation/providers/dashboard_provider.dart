import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/models/weekly_data.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';

// Conteo de solicitudes agrupadas por estado.
class AdminRequestsStats {
  final int pendientes;
  final int enCurso;
  final int confirmadas;
  final int finalizadas;
  final int canceladas;

  const AdminRequestsStats({
    required this.pendientes,
    required this.enCurso,
    required this.confirmadas,
    required this.finalizadas,
    required this.canceladas,
  });
}

// Número de actividades y reservas que ocurren hoy.
class AdminDailyStats {
  final int actividadesHoy;
  final int reservasHoy;

  const AdminDailyStats({
    required this.actividadesHoy,
    required this.reservasHoy,
  });
}

// Conteo de solicitudes por cada estado.
final adminRequestsStatsProvider = Provider<AdminRequestsStats>((ref) {
  final solicitudes = ref.watch(requestsProvider).value ?? [];
  return AdminRequestsStats(
    pendientes: solicitudes.where((r) => r.status == RequestStatus.pendiente).length,
    enCurso: solicitudes.where((r) => r.status == RequestStatus.enCurso).length,
    confirmadas: solicitudes.where((r) => r.status == RequestStatus.confirmada).length,
    finalizadas: solicitudes.where((r) => r.status == RequestStatus.finalizada).length,
    canceladas: solicitudes.where((r) => r.status == RequestStatus.cancelada).length,
  );
});

// Número de actividades y reservas activas hoy.
final adminDailyStatsProvider = Provider<AdminDailyStats>((ref) {
  final actividades = ref.watch(activitiesProvider).value ?? [];
  final reservas = ref.watch(reservationsProvider).value ?? [];
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  return AdminDailyStats(
    actividadesHoy: actividades
        .where((a) => a.initDate.isBefore(todayEnd) && a.endDate.isAfter(todayStart))
        .length,
    reservasHoy: reservas
        .where((r) => r.startDate.isBefore(todayEnd) && r.endDate.isAfter(todayStart))
        .length,
  );
});

// Suma de ingresos de solicitudes confirmadas o finalizadas.
final adminRevenueProvider = Provider<double>((ref) {
  final solicitudes = ref.watch(requestsProvider).value ?? [];
  return solicitudes
      .where((r) => r.status == RequestStatus.confirmada || r.status == RequestStatus.finalizada)
      .fold(0.0, (sum, r) => sum + r.totalPrice);
});

// Datos de actividad por día para la semana actual.
final weeklyStatsProvider = Provider<WeeklyData>((ref) {
  final reservas = ref.watch(reservationsProvider).value ?? [];
  final solicitudes = ref.watch(requestsProvider).value ?? [];
  final actividades = ref.watch(activitiesProvider).value ?? [];
  return WeeklyData.calculate(
    reservas: reservas,
    solicitudes: solicitudes,
    actividades: actividades,
    today: DateTime.now(),
  );
});
