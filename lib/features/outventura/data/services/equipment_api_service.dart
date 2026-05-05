import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

final equipmentApiProvider = Provider<EquipmentApiService>((ref) {
  return EquipmentApiService(ref.watch(dioProvider));
});

class EquipmentApiService {
  final Dio _dio;

  EquipmentApiService(this._dio);

  // GET /equipment?search=
  Future<List<Equipamiento>> getAll({String? search}) async {
    final resp = await _dio.get('/equipment', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (resp.data as List<dynamic>)
        .map((e) => Equipamiento.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // GET /equipment/:id
  Future<Equipamiento> getOne(int id) async {
    final resp = await _dio.get('/equipment/$id');
    return Equipamiento.fromMap(resp.data as Map<String, dynamic>);
  }

  // POST /equipment
  Future<Equipamiento> create(Map<String, dynamic> data) async {
    final resp = await _dio.post('/equipment', data: data);
    return Equipamiento.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /equipment/:id
  Future<Equipamiento> update(int id, Map<String, dynamic> data) async {
    final resp = await _dio.patch('/equipment/$id', data: data);
    return Equipamiento.fromMap(resp.data as Map<String, dynamic>);
  }

  // DELETE /equipment/:id
  Future<void> delete(int id) async {
    await _dio.delete('/equipment/$id');
  }

  // PATCH /equipment/:id/status
  Future<Equipamiento> patchStatus(int id, {required int statusId}) async {
    final resp = await _dio.patch('/equipment/$id/status', data: {'statusId': statusId});
    return Equipamiento.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /equipment/:id/stock
  Future<Equipamiento> patchStock(int id, {required int stock}) async {
    final resp = await _dio.patch('/equipment/$id/stock', data: {'stock': stock});
    return Equipamiento.fromMap(resp.data as Map<String, dynamic>);
  }
}
