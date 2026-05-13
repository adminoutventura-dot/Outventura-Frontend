import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/data/fakes/reservations_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/services/resolvers.dart';

// Expone una lista de reservas. Simula llamadas al backend.
final AsyncNotifierProvider<ReservationsNotifier, List<Reservation>> reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<Reservation>>(ReservationsNotifier.new);

// TEMPORAL: el filtro se moverá al backend → GET /api/reservas?q=...&idUsuario=... Eliminar este provider.
// Filtra reservas por nombre de usuario, actividad, estado y rango de fechas. Simula búsqueda en backend.
final filteredReservationsProvider = Provider.family<AsyncValue<List<Reservation>>, ({String query, int? idUsuario, ReservationStatus? estado, DateTime? fechaDesde, DateTime? fechaHasta})>((ref, params) {

  // Observa el estado asíncrono de todas las reservas (notifica si cambia y recalcula la lista)
  final AsyncValue<List<Reservation>> asyncTodas = ref.watch(reservationsProvider);

  // Obtiene las listas de usuarios y actividades para resolver nombres
  final List<User> usuarios = ref.watch(usuariosProvider).value ?? [];
  final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];

  // Aplica el filtro solo cuando los datos están disponibles
  return asyncTodas.whenData((List<Reservation> todas) {
    // Si hay idUsuario, filtra previamente por ese usuario
    List<Reservation> base;
    if (params.idUsuario != null) {
      base = todas.where((Reservation r) => r.userId == params.idUsuario).toList();
    } else {
      base = todas;
    }
    if (params.estado != null) {
      base = base.where((Reservation r) => r.status == params.estado).toList();
    }
    if (params.fechaDesde != null) {
      base = base.where((Reservation r) => !r.endDate.isBefore(params.fechaDesde!)).toList();
    }
    if (params.fechaHasta != null) {
      base = base.where((Reservation r) => !r.startDate.isAfter(params.fechaHasta!)).toList();
    }

    // Si no hay query, devuelve la lista base sin filtrar
    if (params.query.isEmpty) {
      return base;
    }
    
    final String q = params.query.toLowerCase();
    // Filtra por nombre de usuario o nombre de actividad
    return base.where((Reservation r) {
      final String nombreU = resolverNombreUsuario(r.userId, usuarios).toLowerCase();
      final String nombreAct = (resolverNombreActividad(r.activityId, actividades) ?? '').toLowerCase();

      // Si el nombre de usuario o el nombre de excursión contiene la query, se incluye la reserva
      if (nombreU.contains(q)) {
        return true;
      }
      if (nombreAct.contains(q)) {
        return true;
      }
      return false;
    }).toList();
  });
});

// --- Notifier ---
class ReservationsNotifier extends AsyncNotifier<List<Reservation>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/reservas') y eliminar import de reservations_fake.dart.
  Future<List<Reservation>> build() async {
    // Simula GET /api/reservas
    await Future.delayed(ApiDelay.carga);
    return [...reservationsFake];
  }

  // TEMPORAL: reemplazar cuerpo por await dio.post('/reservas', data: reserva.toJson()).
  // Simula POST /api/reservas
  Future<void> agregar(Reservation reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Reservation> listaActual = [...(state.value ?? [])];
    // Agrega la nueva reserva a la lista
    listaActual.add(reserva);
    // Actualiza el estado con la nueva lista
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.put('/reservas/${viejo.id}', data: nuevo.toJson()).
  // Simula PUT /api/reservas/:id
  Future<void> actualizar(Reservation viejo, Reservation nuevo) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Reservation> listaActual = [...(state.value ?? [])];
    // Busca el índice de la reserva a actualizar
    final int index = listaActual.indexWhere((Reservation r) => r.id == viejo.id);
    if (index != -1) {
      // Reemplaza la reserva en la posición encontrada
      listaActual[index] = nuevo;
    }
    // Actualiza el estado con la lista modificada
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.delete('/reservas/${reserva.id}').
  // Simula DELETE /api/reservas/:id
  Future<void> eliminar(Reservation reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Reservation> listaActual = [...(state.value ?? [])];
    // Elimina la reserva con el ID coincidente
    listaActual.removeWhere((Reservation r) => r.id == reserva.id);
    // Actualiza el estado con la lista sin la reserva eliminada
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/reservas/${reserva.id}/aprobar').
  // Simula PATCH /api/reservas/:id/aprobar
  Future<void> aprobar(Reservation reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la reserva con estado confirmada
    final Reservation aprobada = reserva.copyWith(status: ReservationStatus.confirmada);
    // Delega la actualización al método actualizar
    await actualizar(reserva, aprobada);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/reservas/${reserva.id}/rechazar').
  // Simula PATCH /api/reservas/:id/rechazar
  Future<void> rechazar(Reservation reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la reserva con estado cancelada
    final Reservation rechazada = reserva.copyWith(status: ReservationStatus.cancelada);
    // Delega la actualización al método actualizar
    await actualizar(reserva, rechazada);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/reservas/${reserva.id}/cancelar').
  // Simula PATCH /api/reservas/:id/cancelar
  Future<void> cancelar(Reservation reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la reserva con estado cancelada
    final Reservation cancelada = reserva.copyWith(status: ReservationStatus.cancelada);
    // Delega la actualización al método actualizar
    await actualizar(reserva, cancelada);
  }

  // Simula PATCH /api/reservas/:id/devolver
  Future<void> registrarDevolucion(Reservation reserva) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la reserva con estado devuelta
    final Reservation devuelta = reserva.copyWith(status: ReservationStatus.finalizada);
    // Delega la actualización al método actualizar
    await actualizar(reserva, devuelta);
  }
}
