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
final AsyncNotifierProvider<ReservationsNotifier, List<Reserva>> reservasProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<Reserva>>(ReservationsNotifier.new);

// TEMPORAL: el filtro se moverá al backend → GET /api/reservas?q=...&idUsuario=... Eliminar este provider.
// Filtra reservas por nombre de usuario o excursión. Simula búsqueda en backend.
final reservasFiltadasProvider = Provider.family<AsyncValue<List<Reserva>>, ({String query, int? idUsuario})>((ref, params) {

  // Observa el estado asíncrono de todas las reservas (notifica si cambia y recalcula la lista)
  final AsyncValue<List<Reserva>> asyncTodas = ref.watch(reservasProvider);

  // Obtiene las listas de usuarios y excursiones para resolver nombres
  final List<Usuario> usuarios = ref.watch(usuariosProvider).value ?? [];
  final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];

  // Aplica el filtro solo cuando los datos están disponibles
  return asyncTodas.whenData((List<Reserva> todas) {
    // Si hay idUsuario, filtra previamente por ese usuario
    List<Reserva> base;
    if (params.idUsuario != null) {
      base = todas.where((Reserva r) => r.idUsuario == params.idUsuario).toList();
    } else {
      base = todas;
    }

    // Si no hay query, devuelve la lista base sin filtrar
    if (params.query.isEmpty) {
      return base;
    }
    
    final String q = params.query.toLowerCase();
    // Filtra por nombre de usuario o nombre de excursión
    return base.where((Reserva r) {
      final String nombreU = resolverNombreUsuario(r.idUsuario, usuarios).toLowerCase();
      final String nombreExc = (resolverNombreExcursion(r.idExcursion, excursiones) ?? '').toLowerCase();

      // Si el nombre de usuario o el nombre de excursión contiene la query, se incluye la reserva
      if (nombreU.contains(q)) {
        return true;
      }
      if (nombreExc.contains(q)) {
        return true;
      }
      return false;
    }).toList();
  });
});

// --- Notifier ---
class ReservationsNotifier extends AsyncNotifier<List<Reserva>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/reservas') y eliminar import de reservations_fake.dart.
  Future<List<Reserva>> build() async {
    // Simula GET /api/reservas
    await Future.delayed(ApiDelay.carga);
    return [...reservasFake];
  }

  // TEMPORAL: reemplazar cuerpo por await dio.post('/reservas', data: reserva.toJson()).
  // Simula POST /api/reservas
  Future<void> agregar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Reserva> listaActual = [...(state.value ?? [])];
    // Agrega la nueva reserva a la lista
    listaActual.add(reserva);
    // Actualiza el estado con la nueva lista
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.put('/reservas/${viejo.id}', data: nuevo.toJson()).
  // Simula PUT /api/reservas/:id
  Future<void> actualizar(Reserva viejo, Reserva nuevo) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Reserva> listaActual = [...(state.value ?? [])];
    // Busca el índice de la reserva a actualizar
    final int index = listaActual.indexWhere((Reserva r) => r.id == viejo.id);
    if (index != -1) {
      // Reemplaza la reserva en la posición encontrada
      listaActual[index] = nuevo;
    }
    // Actualiza el estado con la lista modificada
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.delete('/reservas/${reserva.id}').
  // Simula DELETE /api/reservas/:id
  Future<void> eliminar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Reserva> listaActual = [...(state.value ?? [])];
    // Elimina la reserva con el ID coincidente
    listaActual.removeWhere((Reserva r) => r.id == reserva.id);
    // Actualiza el estado con la lista sin la reserva eliminada
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/reservas/${reserva.id}/aprobar').
  // Simula PATCH /api/reservas/:id/aprobar
  Future<void> aprobar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la reserva con estado confirmada
    final Reserva aprobada = reserva.copyWith(estado: EstadoReserva.confirmada);
    // Delega la actualización al método actualizar
    await actualizar(reserva, aprobada);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/reservas/${reserva.id}/rechazar').
  // Simula PATCH /api/reservas/:id/rechazar
  Future<void> rechazar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la reserva con estado cancelada
    final Reserva rechazada = reserva.copyWith(estado: EstadoReserva.cancelada);
    // Delega la actualización al método actualizar
    await actualizar(reserva, rechazada);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/reservas/${reserva.id}/cancelar').
  // Simula PATCH /api/reservas/:id/cancelar
  Future<void> cancelar(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la reserva con estado cancelada
    final Reserva cancelada = reserva.copyWith(estado: EstadoReserva.cancelada);
    // Delega la actualización al método actualizar
    await actualizar(reserva, cancelada);
  }

  // Simula PATCH /api/reservas/:id/devolver
  Future<void> registrarDevolucion(Reserva reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la reserva con estado devuelta
    final Reserva devuelta = reserva.copyWith(estado: EstadoReserva.finalizada);
    // Delega la actualización al método actualizar
    await actualizar(reserva, devuelta);
  }
}
