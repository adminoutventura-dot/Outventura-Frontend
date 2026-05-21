import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

// Lista completa de equipamientos del catálogo. GET /equipment.
final AsyncNotifierProvider<EquipmentNotifier, List<Equipment>> equipmentProvider =
    AsyncNotifierProvider<EquipmentNotifier, List<Equipment>>(EquipmentNotifier.new);

// Filtra equipamientos en el frontend por estado, categoría y nombre.
// El filtrado es local mientras no haya query params en el backend.
final filteredEquipmentProvider = Provider.family<AsyncValue<List<Equipment>>, ({String query, EquipmentStatus? estado, Category? categoria})>((ref, params) {

  // Se re-ejecuta automáticamente cuando cambia la lista de equipamientos
  final AsyncValue<List<Equipment>> asyncTodos = ref.watch(equipmentProvider);

  return asyncTodos.whenData((List<Equipment> todos) {
    List<Equipment> base = todos;

    if (params.estado != null) {
      base = base.where((Equipment e) => e.status == params.estado).toList();
    }
    if (params.categoria != null) {
      base = base.where((Equipment e) => e.categories.contains(params.categoria)).toList();
    }
    if (params.query.isEmpty) {
      return base;
    }
    final String q = params.query.toLowerCase();
    // Busca por el nombre del equipamiento
    return base.where((Equipment e) => e.title.toLowerCase().contains(q)).toList();
  });
});

class EquipmentNotifier extends AsyncNotifier<List<Equipment>> {
  @override
  // Carga todos los equipamientos desde el backend al inicializar.
  Future<List<Equipment>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/equipment');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((e) => Equipment.fromMap(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // POST /equipment - crea el equipamiento. Devuelve el equipamiento con el ID asignado por el backend.
  Future<Equipment> agregar(Equipment equipamiento) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/equipment', data: equipamiento.toMap());
      final Equipment created = Equipment.fromMap(response.data as Map<String, dynamic>);
      ref.invalidateSelf();
      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // PATCH /equipment/:id - actualiza el equipamiento en el backend y en la lista local.
  Future<void> actualizar(Equipment viejo, Equipment nuevo) async {
    if (viejo.id == null) {
      throw StateError('Equipment has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/equipment/${viejo.id}', data: nuevo.toMap());
      final List<Equipment> listaActual = [...(state.value ?? [])];
      final int index = listaActual.indexWhere((Equipment e) => e.id == viejo.id);
      if (index != -1) {
        listaActual[index] = nuevo;
      }
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // DELETE /equipment/:id - elimina el equipamiento del backend y de la lista local.
  Future<void> eliminar(Equipment equipamiento) async {
    if (equipamiento.id == null) {
      throw StateError('Equipment has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/equipment/${equipamiento.id}');
      final List<Equipment> listaActual = [...(state.value ?? [])];
      listaActual.removeWhere((Equipment e) => e.id == equipamiento.id);
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}
