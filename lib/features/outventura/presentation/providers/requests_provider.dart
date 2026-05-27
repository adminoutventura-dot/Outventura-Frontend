import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/data/models/request_model.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart'; // <-- AÑADIDO

// Lista completa de solicitudes de inscripción a actividades. GET /request.
final AsyncNotifierProvider<RequestsNotifier, List<Request>> requestsProvider =
    AsyncNotifierProvider<RequestsNotifier, List<Request>>(RequestsNotifier.new);

// Filtra solicitudes en el frontend por usuario, estado, rango de fechas y texto libre.
// Las fechas se comparan contra la Activity asociada a la solicitud.
// El filtrado es local mientras no haya query params en el backend.
final filteredRequestsProvider = Provider.family<AsyncValue<List<Request>>, ({String query, int? idUsuario, WorkflowStatus? estado, DateTime? fechaDesde, DateTime? fechaHasta})>((ref, params) {

  // Se re-ejecuta automáticamente cuando cambia la lista de solicitudes
  final AsyncValue<List<Request>> asyncTodas = ref.watch(requestsProvider);

  // Necesita actividades para filtrar por fechas y buscar por ruta
  final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];

  return asyncTodas.whenData((List<Request> todas) {
    // Pre-filtro opcional por usuario concreto (vista de cliente)
    List<Request> base;
    if (params.idUsuario != null) {
      base = todas.where((Request s) => s.userId == params.idUsuario).toList();
    } else {
      base = todas;
    }
    if (params.estado != null) {
      base = base.where((Request s) => s.status == params.estado).toList();
    }
    // Filtra por el rango de fechas de la actividad asociada.
    if (params.fechaDesde != null || params.fechaHasta != null) {
      base = base.where((Request s) {
        final Activity? exc = actividades.where((Activity e) => e.id == s.activityId).firstOrNull;
        if (exc == null) return false;
        if (params.fechaDesde != null && exc.endDate.isBefore(params.fechaDesde!)) return false;
        if (params.fechaHasta != null && exc.initDate.isAfter(params.fechaHasta!)) return false;
        return true;
      }).toList();
    }

    // Si no hay query, devuelve la lista base sin filtrar
    if (params.query.isEmpty) {
      return base;
    }
    final String q = params.query.toLowerCase();
    // Busca por la ruta de la actividad asociada (punto de inicio + punto de fin)
    return base.where((Request s) {
      final Activity? exc = actividades.where((Activity e) => e.id == s.activityId).firstOrNull;
      final String ruta = exc != null ? '${exc.startPoint} ${exc.endPoint}'.toLowerCase() : '';
      return ruta.contains(q);
    }).toList();
  });
});

// Solicitudes de un usuario concreto (para la vista del cliente).
final userRequestsProvider = Provider.family<List<Request>, int>((ref, userId) {
  return (ref.watch(requestsProvider).value ?? [])
      .where((s) => s.userId == userId)
      .toList();
});

// Número de solicitudes pendientes de un usuario (para badges y contadores).
final userPendingRequestsCountProvider = Provider.family<int, int>((ref, userId) {
  return ref.watch(userRequestsProvider(userId))
      .where((s) => s.status == WorkflowStatus.pendiente)
      .length;
});

class RequestsNotifier extends AsyncNotifier<List<Request>> {
  @override
  // Carga todas las solicitudes desde el backend al inicializar.
  Future<List<Request>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/request');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((e) => RequestModel.fromMap(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // POST /request - crea la solicitud. Devuelve la solicitud con el ID asignado por el backend.
  Future<Request> agregar(Request solicitud) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/request', data: solicitud.toMap());
      final Request created = RequestModel.fromMap(response.data as Map<String, dynamic>);
      ref.invalidateSelf();
      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // PATCH /request/:id - actualiza la solicitud en el backend y en la lista local.
  Future<void> actualizar(Request viejo, Request nuevo) async {
    if (viejo.id == null) {
      throw StateError('Request has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/request/${viejo.id}', data: nuevo.toMap());
      
      final List<Request> listaActual = [...(state.value ?? [])];
      final int index = listaActual.indexWhere((Request s) => s.id == viejo.id);
      if (index != -1) {
        listaActual[index] = nuevo;
      }
      state = AsyncData(listaActual);

      // REGLA DE SINCRONIZACIÓN INVERSA
      if (viejo.status != nuevo.status) {
        
        // Sincroniza la reserva asociada (Esto es lo que libera el stock en la Base de Datos)
        if (nuevo.bookingId != null) {
          await dio.patch('/booking/${nuevo.bookingId}', data: {'status': nuevo.status.code});
          ref.invalidate(reservationsProvider);
        }

        // Ya puede refrescar el inventario físico porque el backend ya ha devuelto los materiales
        ref.invalidate(equipmentProvider); 
      }

    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // DELETE /request/:id - elimina la solicitud del backend y de la lista local.
  Future<void> eliminar(Request solicitud) async {
    if (solicitud.id == null) {
      throw StateError('Request has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/request/${solicitud.id}');
      final List<Request> listaActual = [...(state.value ?? [])];
      listaActual.removeWhere((Request s) => s.id == solicitud.id);
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // Cambia el estado a CONFIRMED (el admin acepta la solicitud).
  Future<void> aceptar(Request solicitud) async {
    final Request aceptada = solicitud.copyWith(status: WorkflowStatus.confirmada);
    await actualizar(solicitud, aceptada);
  }

  // Cambia el estado a CANCELLED (el admin rechaza la solicitud).
  Future<void> rechazar(Request solicitud) async {
    final Request rechazada = solicitud.copyWith(status: WorkflowStatus.cancelada);
    await actualizar(solicitud, rechazada);
  }
}