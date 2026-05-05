import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

final excursionApiProvider = Provider<ExcursionApiService>((ref) {
  return ExcursionApiService(ref.watch(dioProvider));
});

class ExcursionApiService {
  final Dio _dio;

  ExcursionApiService(this._dio);

  // GET /excursions?search=&category=
  Future<List<Excursion>> getAll({String? search, String? category}) async {
    final resp = await _dio.get('/excursions', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null) 'category': category,
    });
    return (resp.data as List<dynamic>)
        .map((e) => Excursion.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // GET /excursions/:id
  Future<Excursion> getOne(int id) async {
    final resp = await _dio.get('/excursions/$id');
    return Excursion.fromMap(resp.data as Map<String, dynamic>);
  }

  // POST /excursions
  Future<Excursion> create(Map<String, dynamic> data) async {
    final resp = await _dio.post('/excursions', data: data);
    return Excursion.fromMap(resp.data as Map<String, dynamic>);
  }

  // PUT /excursions/:id
  Future<Excursion> update(int id, Map<String, dynamic> data) async {
    final resp = await _dio.put('/excursions/$id', data: data);
    return Excursion.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /excursions/:id/status
  Future<Excursion> patchStatus(int id, {required String status}) async {
    final resp = await _dio.patch('/excursions/$id/status', data: {'status': status});
    return Excursion.fromMap(resp.data as Map<String, dynamic>);
  }

  // DELETE /excursions/:id
  Future<void> delete(int id) async {
    await _dio.delete('/excursions/$id');
  }
}
