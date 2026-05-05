import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/services/equipment_api_service.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

// Expone una lista de equipamientos desde el backend.
final AsyncNotifierProvider<EquipmentNotifier, List<Equipamiento>> equipamientosProvider =
    AsyncNotifierProvider<EquipmentNotifier, List<Equipamiento>>(EquipmentNotifier.new);

// Filtro local (el backend también acepta ?search= en GET /equipment).
final equipamientosFiltradosProvider = Provider.family<AsyncValue<List<Equipamiento>>, String>((ref, query) {
  final AsyncValue<List<Equipamiento>> asyncTodos = ref.watch(equipamientosProvider);
  return asyncTodos.whenData((List<Equipamiento> todos) {
    if (query.isEmpty) return todos;
    final String q = query.toLowerCase();
    return todos.where((Equipamiento e) => e.nombre.toLowerCase().contains(q)).toList();
  });
});

class EquipmentNotifier extends AsyncNotifier<List<Equipamiento>> {
  @override
  Future<List<Equipamiento>> build() async {
    return ref.read(equipmentApiProvider).getAll();
  }

  Future<void> agregar(Equipamiento equipamiento) async {
    await ref.read(equipmentApiProvider).create({
      'title': equipamiento.nombre,
      'description': equipamiento.descripcion,
      'price_per_day': equipamiento.precioAlquilerDiario,
      'damage_fee': equipamiento.cargoPorDanio,
      'units': equipamiento.stockTotal,
      'stock': equipamiento.stock,
      'categories': equipamiento.categorias.map((c) => c.backendValue).toList(),
      'image_url': equipamiento.imagenAsset,
      'statusId': 1, // AVAILABLE por defecto
    });
    ref.invalidateSelf();
  }

  Future<void> actualizar(Equipamiento viejo, Equipamiento nuevo) async {
    await ref.read(equipmentApiProvider).update(viejo.id, {
      'title': nuevo.nombre,
      'description': nuevo.descripcion,
      'price_per_day': nuevo.precioAlquilerDiario,
      'damage_fee': nuevo.cargoPorDanio,
      'units': nuevo.stockTotal,
      'stock': nuevo.stock,
      'categories': nuevo.categorias.map((c) => c.backendValue).toList(),
      'image_url': nuevo.imagenAsset,
    });
    ref.invalidateSelf();
  }

  Future<void> eliminar(Equipamiento equipamiento) async {
    await ref.read(equipmentApiProvider).delete(equipamiento.id);
    ref.invalidateSelf();
  }
}
