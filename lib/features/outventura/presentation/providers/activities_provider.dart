import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
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
      return data.map((e) => Activity.fromMap(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // POST /activity - crea la actividad. Devuelve la actividad con el ID asignado por el backend.
  Future<Activity> agregar(Activity actividad) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/activity', data: actividad.toMap());
      final Activity created = Activity.fromMap(response.data as Map<String, dynamic>);
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
      await dio.patch('/activity/${viejo.id}', data: nuevo.toMap());
      final List<Activity> listaActual = [...(state.value ?? [])];
      final int index = listaActual.indexWhere((Activity e) => e.id == viejo.id);
      if (index != -1) {
        listaActual[index] = nuevo;
      }
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
