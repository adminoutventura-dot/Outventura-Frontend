import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/data/services/reservation_api_service.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/services/resolvers.dart';

// Expone una lista de reservas desde el backend.
final AsyncNotifierProvider<ReservationsNotifier, List<Reserva>> reservasProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<Reserva>>(ReservationsNotifier.new);

// Filtro local — el backend también acepta ?search= y ?userId= en GET /reservations.
final reservasFiltadasProvider = Provider.family<AsyncValue<List<Reserva>>, ({String query, int? idUsuario})>((ref, params) {
  final AsyncValue<List<Reserva>> asyncTodas = ref.watch(reservasProvider);
  final List<Usuario> usuarios = ref.watch(usuariosProvider).value ?? [];
  final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];

  return asyncTodas.whenData((List<Reserva> todas) {
    List<Reserva> base = params.idUsuario != null
        ? todas.where((r) => r.idUsuario == params.idUsuario).toList()
        : todas;
    if (params.query.isEmpty) return base;
    final String q = params.query.toLowerCase();
    return base.where((Reserva r) {
      final String nombreU = resolverNombreUsuario(r.idUsuario, usuarios).toLowerCase();
      final String nombreExc = (resolverNombreExcursion(r.idExcursion, excursiones) ?? '').toLowerCase();
      return nombreU.contains(q) || nombreExc.contains(q);
    }).toList();
  });
});

// --- Notifier ---
class ReservationsNotifier extends AsyncNotifier<List<Reserva>> {
  @override
  Future<List<Reserva>> build() async {
    return ref.read(reservationApiProvider).getAll();
  }

  Future<void> agregar(Reserva reserva) async {
    await ref.read(reservationApiProvider).create({
      'start_date': reserva.fechaInicio.toIso8601String(),
      'end_date': reserva.fechaFin.toIso8601String(),
      'userId': reserva.idUsuario,
      'excursionId': reserva.idExcursion,
      'lines': reserva.lineas
          .map((l) => {'equipmentId': l.idEquipamiento, 'quantity': l.cantidad})
          .toList(),
    });
    ref.invalidateSelf();
  }

  Future<void> actualizar(Reserva viejo, Reserva nuevo) async {
    await ref.read(reservationApiProvider).update(viejo.id, {
      'start_date': nuevo.fechaInicio.toIso8601String(),
      'end_date': nuevo.fechaFin.toIso8601String(),
      'lines': nuevo.lineas
          .map((l) => {'equipmentId': l.idEquipamiento, 'quantity': l.cantidad})
          .toList(),
    });
    ref.invalidateSelf();
  }

  Future<void> eliminar(Reserva reserva) async {
    await ref.read(reservationApiProvider).delete(reserva.id);
    ref.invalidateSelf();
  }

  Future<void> aprobar(Reserva reserva) async {
    await ref.read(reservationApiProvider).approve(reserva.id);
    ref.invalidateSelf();
  }

  Future<void> rechazar(Reserva reserva) async {
    await ref.read(reservationApiProvider).reject(reserva.id);
    ref.invalidateSelf();
  }

  Future<void> cancelar(Reserva reserva) async {
    await ref.read(reservationApiProvider).cancel(reserva.id);
    ref.invalidateSelf();
  }

  Future<void> registrarDevolucion(Reserva reserva) async {
    final Map<String, dynamic>? damages = reserva.itemsDaniados.isNotEmpty
        ? {
            'damaged_items': reserva.itemsDaniados
                .map((k, v) => MapEntry(k.toString(), v)),
            'damage_fee': reserva.cargoDanios,
          }
        : null;
    await ref.read(reservationApiProvider).returnReservation(reserva.id, damages: damages);
    ref.invalidateSelf();
  }
}
