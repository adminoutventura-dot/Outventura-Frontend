import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

// Expone una lista de equipamientos. Simula llamadas al backend.
final AsyncNotifierProvider<EquipmentNotifier, List<Equipamiento>> equipamientosProvider =
    AsyncNotifierProvider<EquipmentNotifier, List<Equipamiento>>(EquipmentNotifier.new);

// TEMPORAL: el filtro se moverá al backend - GET /api/equipamientos?q=... Eliminar este provider.
// Filtra equipamientos por nombre, estado y categoría. Simula búsqueda en backend.
final equipamientosFiltradosProvider = Provider.family<AsyncValue<List<Equipamiento>>, ({String query, EstadoEquipamiento? estado, CategoriaActividad? categoria})>((ref, params) {

  // Observa el estado asíncrono de todos los equipamientos (notifica si cambia y recalcula la lista)
  final AsyncValue<List<Equipamiento>> asyncTodos = ref.watch(equipamientosProvider);

  // Aplica el filtro solo cuando los datos están disponibles
  return asyncTodos.whenData((List<Equipamiento> todos) {
    List<Equipamiento> base = todos;

    if (params.estado != null) {
      base = base.where((Equipamiento e) => e.status == params.estado).toList();
    }
    if (params.categoria != null) {
      base = base.where((Equipamiento e) => e.categories.contains(params.categoria)).toList();
    }
    if (params.query.isEmpty) {
      return base;
    }
    final String q = params.query.toLowerCase();
    
    // Filtra por el nombre del equipamiento
    return base.where((Equipamiento e) => e.title.toLowerCase().contains(q)).toList();
  });
});

class EquipmentNotifier extends AsyncNotifier<List<Equipamiento>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/equipamientos') y eliminar import de equipment_fake.dart.
  Future<List<Equipamiento>> build() async {
    // Simula GET /api/equipamientos
    await Future.delayed(ApiDelay.carga);
    return [...equipamientosFake];
  }

  // TEMPORAL: reemplazar cuerpo por await dio.post('/equipamientos', data: equipamiento.toJson()).
  // Simula POST /api/equipamientos
  Future<void> agregar(Equipamiento equipamiento) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Equipamiento> listaActual = [...(state.value ?? [])];
    // Agrega el nuevo equipamiento a la lista
    listaActual.add(equipamiento);
    // Actualiza el estado con la nueva lista
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.put('/equipamientos/${viejo.id}', data: nuevo.toJson()).
  // Simula PUT /api/equipamientos/:id
  Future<void> actualizar(Equipamiento viejo, Equipamiento nuevo) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Equipamiento> listaActual = [...(state.value ?? [])];
    // Busca el índice del equipamiento a actualizar
    final int index = listaActual.indexWhere((Equipamiento e) => e.id == viejo.id);
    if (index != -1) {
      // Reemplaza el equipamiento en la posición encontrada
      listaActual[index] = nuevo;
    }
    // Actualiza el estado con la lista modificada
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.delete('/equipamientos/${equipamiento.id}').
  // Simula DELETE /api/equipamientos/:id
  Future<void> eliminar(Equipamiento equipamiento) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<Equipamiento> listaActual = [...(state.value ?? [])];
    // Elimina el equipamiento con el ID coincidente
    listaActual.removeWhere((Equipamiento e) => e.id == equipamiento.id);
    // Actualiza el estado con la lista sin el equipamiento eliminado
    state = AsyncData(listaActual);
  }
}
