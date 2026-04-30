import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/data/fakes/reservations_fake.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/services/resolvers.dart';

// Expone una lista de reservas. Simula llamadas al backend.
final AsyncNotifierProvider<ReservasNotifier, List<Reserva>> reservasProvider =
    AsyncNotifierProvider<ReservasNotifier, List<Reserva>>(ReservasNotifier.new);

// Filtra reservas por nombre de usuario o excursión. Simula búsqueda en backend.
typedef ReservasFiltroParams = ({String query, int? idUsuario});

final reservasFiltadasProvider = Provider.family<AsyncValue<List<Reserva>>, ReservasFiltroParams>((ref, params) {
  final AsyncValue<List<Reserva>> asyncTodas = ref.watch(reservasProvider);
  final List<Usuario> usuarios = ref.watch(usuariosProvider).value ?? [];
  final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];

  return asyncTodas.whenData((List<Reserva> todas) {
    final List<Reserva> base = params.idUsuario != null
        ? todas.where((Reserva r) => r.idUsuario == params.idUsuario).toList()
        : todas;

    if (params.query.isEmpty) return base;
    final String q = params.query.toLowerCase();
    return base.where((Reserva r) {
      final String nombreU = resolverNombreUsuario(r.idUsuario, usuarios);
      final String nombreExc = resolverNombreExcursion(r.idExcursion, excursiones) ?? '';
      return nombreU.toLowerCase().contains(q) || nombreExc.toLowerCase().contains(q);
    }).toList();
  });
});

// --- Notifier ---
class ReservasNotifier extends AsyncNotifier<List<Reserva>> {
  @override
  Future<List<Reserva>> build() async {
    // Simula GET /api/reservas
    await Future.delayed(ApiDelay.carga);
    return [...reservasFake];
  }

  // Simula POST /api/reservas
  Future<void> agregar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    final List<Reserva> listaActual = [...(state.value ?? [])];
    listaActual.add(reserva);
    state = AsyncData(listaActual);
  }

  // Simula PUT /api/reservas/:id
  Future<void> actualizar(Reserva viejo, Reserva nuevo) async {
    await Future.delayed(ApiDelay.accion);
    final List<Reserva> listaActual = [...(state.value ?? [])];
    final int index = listaActual.indexWhere((Reserva r) => r.id == viejo.id);
    if (index != -1) {
      listaActual[index] = nuevo;
    }
    state = AsyncData(listaActual);
  }

  // Simula DELETE /api/reservas/:id
  Future<void> eliminar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    final List<Reserva> listaActual = [...(state.value ?? [])];
    listaActual.removeWhere((Reserva r) => r.id == reserva.id);
    state = AsyncData(listaActual);
  }

  // Simula PATCH /api/reservas/:id/aprobar
  Future<void> aprobar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    final Reserva aprobada = reserva.copyWith(estado: EstadoReserva.confirmada);
    await actualizar(reserva, aprobada);
  }

  // Simula PATCH /api/reservas/:id/rechazar
  Future<void> rechazar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    final Reserva rechazada = reserva.copyWith(estado: EstadoReserva.cancelada);
    await actualizar(reserva, rechazada);
  }

  // Simula PATCH /api/reservas/:id/cancelar
  Future<void> cancelar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    final Reserva cancelada = reserva.copyWith(estado: EstadoReserva.cancelada);
    await actualizar(reserva, cancelada);
  }

  // Simula PATCH /api/reservas/:id/devolver
  Future<void> registrarDevolucion(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    final Reserva devuelta = reserva.copyWith(estado: EstadoReserva.devuelta);
    await actualizar(reserva, devuelta);
  }
}
