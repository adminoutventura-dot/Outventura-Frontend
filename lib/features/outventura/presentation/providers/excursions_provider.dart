import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/outventura/data/fakes/excursions_fake.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

// Expone una lista de excursiones. Simula llamadas al backend.
final AsyncNotifierProvider<ExcursionsNotifier, List<Excursion>> excursionesProvider =
    AsyncNotifierProvider<ExcursionsNotifier, List<Excursion>>(ExcursionsNotifier.new);

// TEMPORAL: el filtro se moverá al backend - GET /api/excursiones?q=... Eliminar este provider.
// Filtra excursiones por ruta (puntoInicio + puntoFin). Simula búsqueda en backend.
final excursionesFiltadasProvider = Provider.family<AsyncValue<List<Excursion>>, String>((ref, query) {

  // Observa el estado asíncrono de todas las excursiones (notifica si cambia y recalcula la lista)
  final AsyncValue<List<Excursion>> asyncTodas = ref.watch(excursionesProvider);

  // Aplica el filtro solo cuando los datos están disponibles
  return asyncTodas.whenData((List<Excursion> todas) {
    // Si no hay query, devuelve todas las excursiones sin filtrar
    if (query.isEmpty) {
      return todas;
    }
    
    final String q = query.toLowerCase();
    // Filtra por la ruta: punto de inicio y punto de fin
    return todas.where((Excursion e) =>
      '${e.puntoInicio} ${e.puntoFin}'.toLowerCase().contains(q)
    ).toList();
  });
});

class ExcursionsNotifier extends AsyncNotifier<List<Excursion>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/excursiones') y eliminar import de excursions_fake.dart.
  Future<List<Excursion>> build() async {
    // Simula GET /api/excursiones
    await Future.delayed(ApiDelay.carga);
    return [...catalogoExcursiones];
  }

  // Simula POST /api/excursiones
  Future<void> agregar(Excursion excursion) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Excursion> listaActual = [...(state.value ?? [])];
    // Agrega la nueva excursión a la lista
    listaActual.add(excursion);
    // Actualiza el estado con la nueva lista
    state = AsyncData(listaActual);
  }

  // Simula PUT /api/excursiones/:id
  Future<void> actualizar(Excursion viejo, Excursion nuevo) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Excursion> listaActual = [...(state.value ?? [])];
    // Busca el índice de la excursión a actualizar
    final int index = listaActual.indexWhere((Excursion e) => e.id == viejo.id);
    if (index != -1) {
      // Reemplaza la excursión en la posición encontrada
      listaActual[index] = nuevo;
    }
    // Actualiza el estado con la lista modificada
    state = AsyncData(listaActual);
  }

  // Simula DELETE /api/excursiones/:id
  Future<void> eliminar(Excursion excursion) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Excursion> listaActual = [...(state.value ?? [])];
    // Elimina la excursión con el ID coincidente
    listaActual.removeWhere((Excursion e) => e.id == excursion.id);
    // Actualiza el estado con la lista sin la excursión eliminada
    state = AsyncData(listaActual);
  }
}
