import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/data/models/activity_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

// Lista completa de actividades. GET /activity.
final AsyncNotifierProvider<ActivitiesNotifier, List<Activity>> activitiesProvider =
    AsyncNotifierProvider<ActivitiesNotifier, List<Activity>>(ActivitiesNotifier.new);

// Filtra actividades en el frontend por estado, categoría, rango de fechas y texto libre
// (punto de inicio y punto de fin). El filtrado es local mientras no haya query params en el backend.
final filteredActivitiesProvider = Provider.family<AsyncValue<List<Activity>>, ({String query, ActivityStatus? estado, Category? categoria, DateTime? fechaDesde, DateTime? fechaHasta})>((ref, params) {

  // Se re-ejecuta automáticamente cuando cambia la lista de actividades
  final AsyncValue<List<Activity>> asyncTodas = ref.watch(activitiesProvider);

  return asyncTodas.whenData((List<Activity> todas) {
    List<Activity> base = todas;

    if (params.estado != null) {
      base = base.where((Activity e) => e.status == params.estado).toList();
    }
    if (params.categoria != null) {
      base = base.where((Activity e) => e.categories.contains(params.categoria)).toList();
    }
    // Una actividad entra en el rango si no terminó antes del fechaDesde
    if (params.fechaDesde != null) {
      base = base.where((Activity e) => !e.endDate.isBefore(params.fechaDesde!)).toList();
    }
    // Una actividad entra en el rango si no empieza después del fechaHasta
    if (params.fechaHasta != null) {
      base = base.where((Activity e) => !e.initDate.isAfter(params.fechaHasta!)).toList();
    }
    if (params.query.isEmpty) {
      return base;
    }
    final String q = params.query.toLowerCase();
    // Busca en la ruta: punto de salida + punto de llegada
    return base.where((Activity e) =>
      '${e.startPoint} ${e.endPoint}'.toLowerCase().contains(q)
    ).toList();
  });
});

// Las últimas [count] actividades de la lista (para el dashboard).
final recentActivitiesProvider = Provider.family<List<Activity>, int>((ref, count) {
  return (ref.watch(activitiesProvider).value ?? []).take(count).toList();
});

// Las [limit] categorías con más actividades asociadas, ordenadas de mayor a menor.
final popularCategoriesProvider = Provider.family<List<MapEntry<Category, int>>, int>((ref, limit) {
  final actividades = ref.watch(activitiesProvider).value ?? [];
  final categoriasCount = <Category, int>{};
  for (final act in actividades) {
    for (final cat in act.categories) {
      categoriasCount[cat] = (categoriasCount[cat] ?? 0) + 1;
    }
  }
  return (categoriasCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
      .take(limit)
      .toList();
});

class ActivitiesNotifier extends AsyncNotifier<List<Activity>> {
  @override
  // Carga todas las actividades desde el backend al inicializar.
  Future<List<Activity>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/activity');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((e) => ActivityModel.fromMap(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // POST /activity - crea la actividad. Devuelve la actividad con el ID asignado por el backend.
  Future<Activity> agregar(Activity actividad) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/activity', data: actividad.toMap());
      final Activity created = ActivityModel.fromMap(response.data as Map<String, dynamic>);
      ref.invalidateSelf();
      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // PATCH /activity/:id - actualiza la actividad en el backend y en la lista local.
  Future<void> actualizar(Activity viejo, Activity nuevo) async {
    if (viejo.id == null) {
      throw StateError('Activity has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      
      // Envia la actividad actualizada al backend para que la guarde y reenvie la versión actualizada.
      final response = await dio.patch('/activity/${viejo.id}', data: nuevo.toMap());
      
      // Convierte la respuesta JSON en un ActivityModel actualizado.
      final Activity actividadServidor = ActivityModel.fromMap(response.data as Map<String, dynamic>);
      
      // Crea una copia de la lista local de actividades para modificarla (inmutable).
      final List<Activity> listaActual = [...(state.value ?? [])];
      
      // Busca la posición de la actividad vieja
      final int index = listaActual.indexWhere((Activity e) => e.id == viejo.id);
      
      if (index != -1) {
        // Reemplaza la actividad vieja por la nueva (actualizada desde el servidor) en la lista local.
        listaActual[index] = actividadServidor;
      }
      
      // Notifica a Riverpod el cambio de la lista local
      state = AsyncData(listaActual);
      
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // DELETE /activity/:id - elimina la actividad del backend y de la lista local.
  Future<void> eliminar(Activity actividad) async {
    if (actividad.id == null) {
      throw StateError('Activity has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/activity/${actividad.id}');
      final List<Activity> listaActual = [...(state.value ?? [])];
      listaActual.removeWhere((Activity a) => a.id == actividad.id);
      state = AsyncData(listaActual);
      
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}
