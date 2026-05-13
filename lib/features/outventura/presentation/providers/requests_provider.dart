import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/outventura/data/fakes/requests_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';

// Expone una lista de solicitudes. Simula llamadas al backend.
final AsyncNotifierProvider<RequestsNotifier, List<Request>> requestsProvider =
    AsyncNotifierProvider<RequestsNotifier, List<Request>>(RequestsNotifier.new);

// TEMPORAL: el filtro se moverá al backend → GET /api/solicitudes?q=...&idUsuario=... Eliminar este provider.
// Filtra solicitudes por ruta de actividad, estado y rango de fechas. Simula búsqueda en backend.
// params es un record con cinco campos: query, idUsuario, estado, fechaDesde y fechaHasta
final filteredRequestsProvider = Provider.family<AsyncValue<List<Request>>, ({String query, int? idUsuario, RequestStatus? estado, DateTime? fechaDesde, DateTime? fechaHasta})>((ref, params) {

  // Observa el estado asíncrono de todas las solicitudes (notifica si cambia y recalcula la lista)
  final AsyncValue<List<Request>> asyncTodas = ref.watch(requestsProvider);

  // Obtiene la lista de actividades para resolver la ruta
  final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];

  // Aplica el filtro solo cuando los datos están disponibles
  return asyncTodas.whenData((List<Request> todas) {
    // Si hay idUsuario, filtra previamente por ese usuario
    List<Request> base;
    if (params.idUsuario != null) {
      base = todas.where((Request s) => s.userId == params.idUsuario).toList();
    } else {
      base = todas;
    }
    if (params.estado != null) {
      base = base.where((Request s) => s.status == params.estado).toList();
    }
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
    
    // Filtra por la ruta de la actividad asociada a la solicitud
    return base.where((Request s) {
      // Busca la actividad asociada a la solicitud (null si no existe)
      // firstOrNull devuelve el primer elemento de una lista que cumpla la condición, o null si no hay ninguno.
      final Activity? exc = actividades.where((Activity e) => e.id == s.activityId).firstOrNull;

      // Si no se encuentra la actividad, no se incluye la solicitud
      final String ruta = exc != null ? '${exc.startPoint} ${exc.endPoint}'.toLowerCase() : '';
      return ruta.contains(q);
    }).toList();
  });
});

class RequestsNotifier extends AsyncNotifier<List<Request>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/solicitudes') y eliminar import de requests_fake.dart.
  Future<List<Request>> build() async {
    // Simula GET /api/solicitudes
    await Future.delayed(ApiDelay.carga);
    return [...requestsFake];
  }

  // TEMPORAL: reemplazar cuerpo por await dio.post('/solicitudes', data: solicitud.toJson()).
  // Simula POST /api/solicitudes
  Future<void> agregar(Request solicitud) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Request> listaActual = [...(state.value ?? [])];
    
    // Agrega la nueva solicitud a la lista
    listaActual.add(solicitud);

    // Actualiza el estado con la nueva lista
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.put('/solicitudes/${viejo.id}', data: nuevo.toJson()).
  // Simula PUT /api/solicitudes/:id
  Future<void> actualizar(Request viejo, Request nuevo) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Request> listaActual = [...(state.value ?? [])];
    // Busca el índice de la solicitud a actualizar
    final int index = listaActual.indexWhere((Request s) => s.id == viejo.id);
    if (index != -1) {
      // Reemplaza la solicitud en la posición encontrada
      listaActual[index] = nuevo;
    }
    // Actualiza el estado con la lista modificada
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.delete('/solicitudes/${solicitud.id}').
  // Simula DELETE /api/solicitudes/:id
  Future<void> eliminar(Request solicitud) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Request> listaActual = [...(state.value ?? [])];
    // Elimina la solicitud con el ID coincidente
    listaActual.removeWhere((Request s) => s.id == solicitud.id);
    // Actualiza el estado con la lista sin la solicitud eliminada
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/solicitudes/${solicitud.id}/aceptar').
  // Simula PATCH /api/solicitudes/:id/aceptar
  Future<void> aceptar(Request solicitud) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la solicitud con estado confirmada
    final Request aceptada = solicitud.copyWith(status: RequestStatus.confirmada);
    // Delega la actualización al método actualizar
    await actualizar(solicitud, aceptada);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/solicitudes/${solicitud.id}/rechazar').
  // Simula PATCH /api/solicitudes/:id/rechazar
  Future<void> rechazar(Request solicitud) async {
    await Future.delayed(ApiDelay.accion);
    // Crea una copia de la solicitud con estado cancelada
    final Request rechazada = solicitud.copyWith(status: RequestStatus.cancelada);
    // Delega la actualización al método actualizar
    await actualizar(solicitud, rechazada);
  }
}
