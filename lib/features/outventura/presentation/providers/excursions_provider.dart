import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/outventura/data/fakes/excursions_fake.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

// Expone una lista de excursiones. Simula llamadas al backend.
final AsyncNotifierProvider<ExcursionesNotifier, List<Excursion>> excursionesProvider =
    AsyncNotifierProvider<ExcursionesNotifier, List<Excursion>>(ExcursionesNotifier.new);

// Filtra excursiones por ruta (puntoInicio + puntoFin). Simula búsqueda en backend.
final excursionesFiltadasProvider = Provider.family<AsyncValue<List<Excursion>>, String>((ref, query) {
  final AsyncValue<List<Excursion>> asyncTodas = ref.watch(excursionesProvider);
  return asyncTodas.whenData((List<Excursion> todas) {
    if (query.isEmpty) return todas;
    final String q = query.toLowerCase();
    return todas.where((Excursion e) =>
      '${e.puntoInicio} ${e.puntoFin}'.toLowerCase().contains(q)
    ).toList();
  });
});

class ExcursionesNotifier extends AsyncNotifier<List<Excursion>> {
  @override
  Future<List<Excursion>> build() async {
    // Simula GET /api/excursiones
    await Future.delayed(ApiDelay.carga);
    return [...catalogoExcursiones];
  }

  // Simula POST /api/excursiones
  Future<void> agregar(Excursion excursion) async {
    await Future.delayed(ApiDelay.accion);
    final List<Excursion> listaActual = [...(state.value ?? [])];
    listaActual.add(excursion);
    state = AsyncData(listaActual);
  }

  // Simula PUT /api/excursiones/:id
  Future<void> actualizar(Excursion viejo, Excursion nuevo) async {
    await Future.delayed(ApiDelay.accion);
    final List<Excursion> listaActual = [...(state.value ?? [])];
    final int index = listaActual.indexWhere((Excursion e) => e.id == viejo.id);
    if (index != -1) {
      listaActual[index] = nuevo;
    }
    state = AsyncData(listaActual);
  }

  // Simula DELETE /api/excursiones/:id
  Future<void> eliminar(Excursion excursion) async {
    await Future.delayed(ApiDelay.accion);
    final List<Excursion> listaActual = [...(state.value ?? [])];
    listaActual.removeWhere((Excursion e) => e.id == excursion.id);
    state = AsyncData(listaActual);
  }
}
