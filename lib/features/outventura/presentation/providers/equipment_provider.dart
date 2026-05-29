import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/data/models/equipment_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

// 🌟 Añadido para listar los estados reales del backend
final equipmentStatusesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/equipment-status');
  return response.data as List<dynamic>;
});

final equipmentProvider =
    AsyncNotifierProvider<EquipmentNotifier, List<Equipment>>(
      EquipmentNotifier.new,
    );

// 🌟 ARREGLO: Filtra usando el identificador numérico de estado int?
final filteredEquipmentProvider =
    Provider.family<
      AsyncValue<List<Equipment>>,
      ({String query, int? estado, Category? categoria})
    >((ref, params) {
      final AsyncValue<List<Equipment>> asyncTodos = ref.watch(
        equipmentProvider,
      );

      return asyncTodos.whenData((List<Equipment> todos) {
        List<Equipment> base = todos;

        if (params.estado != null) {
          base = base
              .where((Equipment e) => e.statusId == params.estado)
              .toList();
        }
        if (params.categoria != null) {
          base = base
              .where((Equipment e) => e.categories.contains(params.categoria))
              .toList();
        }
        if (params.query.isEmpty) {
          return base;
        }
        final String q = params.query.toLowerCase();
        return base
            .where((Equipment e) => e.title.toLowerCase().contains(q))
            .toList();
      });
    });

class EquipmentNotifier extends AsyncNotifier<List<Equipment>> {
  @override
  Future<List<Equipment>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/equipment');
      final List<dynamic> data =
          response.data['data']
              as List<
                dynamic
              >; // Se lee de la propiedad 'data' paginada del Back
      return data
          .map((e) => EquipmentModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<Equipment> agregar(Equipment equipamiento) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/equipment', data: equipamiento.toMap());
      final Equipment created = EquipmentModel.fromMap(
        response.data as Map<String, dynamic>,
      );
      ref.invalidateSelf();
      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> actualizar(Equipment viejo, Equipment nuevo) async {
    if (viejo.id == null) {
      throw StateError('Equipment has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/equipment/${viejo.id}', data: nuevo.toMap());
      ref.invalidateSelf(); // Invalida para refrescar datos limpios en la UI
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  Future<void> eliminar(Equipment equipamiento) async {
    if (equipamiento.id == null) {
      throw StateError('Equipment has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/equipment/${equipamiento.id}');
      ref.invalidateSelf();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}
