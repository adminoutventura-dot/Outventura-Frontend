import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/outventura/data/fakes/activities_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

// Expone una lista de actividades. Simula llamadas al backend.
final AsyncNotifierProvider<ActivitiesNotifier, List<Activity>> activitiesProvider =
    AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>(ActivitiesNotifier.new);

// TEMPORAL: el filtro se moverá al backend - GET /api/actividades?q=... Eliminar este provider.
// Filtra actividades por ruta, estado, categoría y rango de fechas. Simula búsqueda en backend.
final filteredActivitiesProvider = Provider.family<AsyncValue<List<Activity>>, ({String query, ActivityStatus? estado, ActivityCategory? categoria, DateTime? fechaDesde, DateTime? fechaHasta})>((ref, params) {

  // Observa el estado asíncrono de todas las actividades (notifica si cambia y recalcula la lista)
  final AsyncValue<List<Activity>> asyncTodas = ref.watch(activitiesProvider);

  // Aplica el filtro solo cuando los datos están disponibles
  return asyncTodas.whenData((List<Activity> todas) {
    List<Activity> base = todas;

    if (params.estado != null) {
      base = base.where((Activity e) => e.status == params.estado).toList();
    }
    if (params.categoria != null) {
      base = base.where((Activity e) => e.categories.contains(params.categoria)).toList();
    }
    if (params.fechaDesde != null) {
      base = base.where((Activity e) => !e.endDate.isBefore(params.fechaDesde!)).toList();
    }
    if (params.fechaHasta != null) {
      base = base.where((Activity e) => !e.initDate.isAfter(params.fechaHasta!)).toList();
    }
    if (params.query.isEmpty) {
      return base;
    }
    
    final String q = params.query.toLowerCase();
    // Filtra por la ruta: punto de inicio y punto de fin
    return base.where((Activity e) =>
      '${e.startPoint} ${e.endPoint}'.toLowerCase().contains(q)
    ).toList();
  });
});

class ActivitiesNotifier extends AsyncNotifier<List<Activity>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/actividades') y eliminar import de activities_fake.dart.
  Future<List<Activity>> build() async {
    // Simula GET /api/actividades
    await Future.delayed(ApiDelay.carga);
    return [...activitiesFake];
  }

  // Simula POST /api/actividades
  Future<void> agregar(Activity actividad) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Activity> listaActual = [...(state.value ?? [])];
    // Agrega la nueva actividad a la lista
    listaActual.add(actividad);
    // Actualiza el estado con la nueva lista
    state = AsyncData(listaActual);
  }

  // Simula PUT /api/actividades/:id
  Future<void> actualizar(Activity viejo, Activity nuevo) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Activity> listaActual = [...(state.value ?? [])];
    // Busca el índice de la actividad a actualizar
    final int index = listaActual.indexWhere((Activity e) => e.id == viejo.id);
    if (index != -1) {
      // Reemplaza la actividad en la posición encontrada
      listaActual[index] = nuevo;
    }
    // Actualiza el estado con la lista modificada
    state = AsyncData(listaActual);
  }

  // Simula DELETE /api/actividades/:id
  Future<void> eliminar(Activity actividad) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Activity> listaActual = [...(state.value ?? [])];
    // Elimina la actividad con el ID coincidente
    listaActual.removeWhere((Activity a) => a.id == actividad.id);
    // Actualiza el estado con la lista sin la actividad eliminada
    state = AsyncData(listaActual);
  }
}
