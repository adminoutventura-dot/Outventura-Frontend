import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/data/models/reservation_model.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/services/resolvers.dart';

// Lista completa de reservas. GET /booking.
final AsyncNotifierProvider<ReservationsNotifier, List<Booking>> reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<Booking>>(ReservationsNotifier.new);

// Filtra reservas en el frontend por usuario, estado, rango de fechas y texto libre.
// Las fechas se comparan contra la Activity asociada (las reservas no tienen fechas propias).
// El filtrado es local mientras no haya query params en el backend.
final filteredReservationsProvider = Provider.family<AsyncValue<List<Booking>>, ({String query, int? idUsuario, WorkflowStatus? estado, DateTime? fechaDesde, DateTime? fechaHasta})>((ref, params) {

  // Observa el estado asíncrono de todas las reservas (notifica si cambia y recalcula la lista)
  final AsyncValue<List<Booking>> asyncTodas = ref.watch(reservationsProvider);

  // Necesita usuarios y actividades para resolver nombres en la búsqueda por texto
  final List<User> usuarios = ref.watch(usuariosProvider).value ?? [];
  final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];

  return asyncTodas.whenData((List<Booking> todas) {
    // Pre-filtro opcional por usuario concreto (perfil de cliente)
    List<Booking> base;
    if (params.idUsuario != null) {
      base = todas.where((Booking r) => r.userId == params.idUsuario).toList();
    } else {
      base = todas;
    }

    // Filtro opcional por estado de la reserva
    if (params.estado != null) {
      base = base.where((Booking r) => r.status == params.estado).toList();
    }

    // Rango de fecha desde
    if (params.fechaDesde != null) {
      base = base.where((Booking r) => !r.endDate.isBefore(params.fechaDesde!)).toList();
    }

    // Rango de fecha hasta
    if (params.fechaHasta != null) {
      base = base.where((Booking r) => !r.startDate.isAfter(params.fechaHasta!)).toList();
    }

    // Filtro por texo libre en el nombre de usuario o nombre de la actividad asociada.
    if (params.query.isEmpty) {
      return base;
    }
    
    final String q = params.query.toLowerCase();
    // Busca por nombre de usuario o nombre de la actividad asociada
    return base.where((Booking r) {
      final String nombreU = resolverNombreUsuario(r.userId, usuarios).toLowerCase();
      final String nombreAct = (resolverNombreActividad(r.activityId, actividades) ?? '').toLowerCase();

      // La reserva entra si el texto de búsqueda coincide con el nombre del usuario o con el nombre de la actividad asociada

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

// Reservas de un usuario concreto (para la vista del cliente).
final userReservationsProvider = Provider.family<List<Booking>, int>((ref, userId) {
  return (ref.watch(reservationsProvider).value ?? [])
      .where((r) => r.userId == userId)
      .toList();
});

class ReservationsNotifier extends AsyncNotifier<List<Booking>> {
  @override
  // Carga todas las reservas desde el backend al inicializar.
  Future<List<Booking>> build() async {
    try {
      // Lee el token de autenticación del usuario actual para incluirlo en la cabecera Authorization.
      final dio = ref.read(dioProvider);

      // Llama al endpoint GET /booking para obtener la lista completa de reservas.
      final response = await dio.get('/booking');

      // Convierte la respuesta JSON en una lista de BookingModel.
      final List<dynamic> data = response.data as List<dynamic>;

      // Mapea cada elemento del JSON a un BookingModel y devuelve la lista de reservas.
      return data.map((e) => BookingModel.fromMap(e as Map<String, dynamic>)).toList();

    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // POST /booking - crea la reserva con sus líneas. Devuelve la reserva con el ID asignado por el backend.
  Future<Booking> agregar(Booking reserva) async {
    try {
      final dio = ref.read(dioProvider);

      // Llama al endpoint POST /booking para crear la reserva en el backend.
      final response = await dio.post('/booking', data: reserva.toMap());

      // Convierte la respuesta JSON en un BookingModel con el ID asignado.
      final Booking created = BookingModel.fromMap(response.data as Map<String, dynamic>);

      // Agrega la nueva reserva a la lista local (estado global) sin necesidad de recargar toda la lista.
      ref.invalidateSelf();

      // Devuelve la reserva creada con el ID asignado por el backend.
      return created;

    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // PATCH /booking/:id - actualiza la reserva en el backend y en la lista local.
  Future<void> actualizar(Booking viejo, Booking nuevo) async {
    if (viejo.id == null) {
      throw StateError('Booking has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      
      // Envia la reserva actualizada al backend para que la guarde y reenvie la versión actualizada (con el precio total calculado).
      final response = await dio.patch('/booking/${viejo.id}', data: nuevo.toMap());
      
      // Convierte la respuesta JSON en un BookingModel actualizado (con el precio total calculado por el backend).
      final Booking reservaServidor = BookingModel.fromMap(response.data as Map<String, dynamic>);
      
      // Crea una copia de la lista local de reservas para modificarla (inmutable).
      final List<Booking> listaActual = [...(state.value ?? [])];
      
      // Busca la posición de la reserva vieja
      final int index = listaActual.indexWhere((Booking r) => r.id == viejo.id);
      
      if (index != -1) {
        // Reemplaza la reserva vieja por la nueva (actualizada desde el servidor) en la lista local.
        listaActual[index] = reservaServidor;
      }
      
      // Notifica a Riverpod el cambio de la lista local
      state = AsyncData(listaActual);
      
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // DELETE /booking/:id - elimina la reserva del backend y de la lista local.
  Future<void> eliminar(Booking reserva) async {
    if (reserva.id == null) {
      throw StateError('Booking has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/booking/${reserva.id}');
      final List<Booking> listaActual = [...(state.value ?? [])];
      listaActual.removeWhere((Booking r) => r.id == reserva.id);
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // Cambia el estado de la reserva a CONFIRMED (el admin aprueba).
  Future<void> aprobar(Booking reserva) async {
    final Booking aprobada = reserva.copyWith(status: WorkflowStatus.confirmada);
    await actualizar(reserva, aprobada);
  }

  // Cambia el estado a CANCELLED (el admin rechaza antes de confirmar).
  Future<void> rechazar(Booking reserva) async {
    final Booking rechazada = reserva.copyWith(status: WorkflowStatus.cancelada);
    await actualizar(reserva, rechazada);
  }

  // Cambia el estado a CANCELLED (el propio cliente cancela).
  Future<void> cancelar(Booking reserva) async {
    final Booking cancelada = reserva.copyWith(status: WorkflowStatus.cancelada);
    await actualizar(reserva, cancelada);
  }

  // Cambia el estado a FINISHED al registrar la devolución del material.
  Future<void> registrarDevolucion(Booking reserva) async {
    final Booking devuelta = reserva.copyWith(status: WorkflowStatus.finalizada);
    await actualizar(reserva, devuelta);
  }
}
