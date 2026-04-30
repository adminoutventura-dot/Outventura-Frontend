import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

// Expone una lista de equipamientos. Simula llamadas al backend.
final AsyncNotifierProvider<EquipamientosNotifier, List<Equipamiento>> equipamientosProvider =
    AsyncNotifierProvider<EquipamientosNotifier, List<Equipamiento>>(EquipamientosNotifier.new);

// Filtra equipamientos por nombre. Simula búsqueda en backend.
final equipamientosFiltradosProvider = Provider.family<AsyncValue<List<Equipamiento>>, String>((ref, query) {
  final AsyncValue<List<Equipamiento>> asyncTodos = ref.watch(equipamientosProvider);
  return asyncTodos.whenData((List<Equipamiento> todos) {
    if (query.isEmpty) return todos;
    final String q = query.toLowerCase();
    return todos.where((Equipamiento e) => e.nombre.toLowerCase().contains(q)).toList();
  });
});

class EquipamientosNotifier extends AsyncNotifier<List<Equipamiento>> {
  @override
  Future<List<Equipamiento>> build() async {
    // Simula GET /api/equipamientos
    await Future.delayed(ApiDelay.carga);
    return [...equipamientosFake];
  }

  // Simula POST /api/equipamientos
  Future<void> agregar(Equipamiento equipamiento) async {
    await Future.delayed(ApiDelay.accion);
    final List<Equipamiento> listaActual = [...(state.value ?? [])];
    listaActual.add(equipamiento);
    state = AsyncData(listaActual);
  }

  // Simula PUT /api/equipamientos/:id
  Future<void> actualizar(Equipamiento viejo, Equipamiento nuevo) async {
    await Future.delayed(ApiDelay.accion);
    final List<Equipamiento> listaActual = [...(state.value ?? [])];
    final int index = listaActual.indexWhere((Equipamiento e) => e.id == viejo.id);
    if (index != -1) {
      listaActual[index] = nuevo;
    }
    state = AsyncData(listaActual);
  }

  // Simula DELETE /api/equipamientos/:id
  Future<void> eliminar(Equipamiento equipamiento) async {
    await Future.delayed(ApiDelay.accion);
    final List<Equipamiento> listaActual = [...(state.value ?? [])];
    listaActual.removeWhere((Equipamiento e) => e.id == equipamiento.id);
    state = AsyncData(listaActual);
  }
}
