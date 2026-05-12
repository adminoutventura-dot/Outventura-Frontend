import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/outventura/data/fakes/excursions_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

// Expone una lista de excursiones. Simula llamadas al backend.
final AsyncNotifierProvider<ExcursionsNotifier, List<Activity>> excursionesProvider =
    AsyncNotifierProvider<ExcursionsNotifier, List<Activity>>(ExcursionsNotifier.new);

// TEMPORAL: el filtro se moverá al backend - GET /api/excursiones?q=... Eliminar este provider.
// Filtra excursiones por ruta, estado, categoría y rango de fechas. Simula búsqueda en backend.
final excursionesFiltadasProvider = Provider.family<AsyncValue<List<Activity>>, ({String query, EstadoExcursion? estado, CategoriaActividad? categoria, DateTime? fechaDesde, DateTime? fechaHasta})>((ref, params) {

  // Observa el estado asíncrono de todas las excursiones (notifica si cambia y recalcula la lista)
  final AsyncValue<List<Activity>> asyncTodas = ref.watch(excursionesProvider);

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

class ExcursionsNotifier extends AsyncNotifier<List<Activity>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/excursiones') y eliminar import de excursions_fake.dart.
  Future<List<Activity>> build() async {
    // Simula GET /api/excursiones
    await Future.delayed(ApiDelay.carga);
    return [...catalogoExcursiones];
  }

  // Simula POST /api/excursiones
  Future<void> agregar(Activity excursion) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Activity> listaActual = [...(state.value ?? [])];
    // Agrega la nueva excursión a la lista
    listaActual.add(excursion);
    // Actualiza el estado con la nueva lista
    state = AsyncData(listaActual);
  }

  // Simula PUT /api/excursiones/:id
  Future<void> actualizar(Activity viejo, Activity nuevo) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Activity> listaActual = [...(state.value ?? [])];
    // Busca el índice de la excursión a actualizar
    final int index = listaActual.indexWhere((Activity e) => e.id == viejo.id);
    if (index != -1) {
      // Reemplaza la excursión en la posición encontrada
      listaActual[index] = nuevo;
    }
    // Actualiza el estado con la lista modificada
    state = AsyncData(listaActual);
  }

  // Simula DELETE /api/excursiones/:id
  Future<void> eliminar(Activity excursion) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Activity> listaActual = [...(state.value ?? [])];
    // Elimina la excursión con el ID coincidente
    listaActual.removeWhere((Activity e) => e.id == excursion.id);
    // Actualiza el estado con la lista sin la excursión eliminada
    state = AsyncData(listaActual);
  }
}
