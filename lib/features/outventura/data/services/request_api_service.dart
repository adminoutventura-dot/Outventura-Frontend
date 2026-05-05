import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

final requestApiProvider = Provider<RequestApiService>((ref) {
  return RequestApiService(ref.watch(dioProvider));
});

class RequestApiService {
  final Dio _dio;

  RequestApiService(this._dio);

  // GET /requests?search=&userId=
  Future<List<Solicitud>> getAll({String? search, int? userId}) async {
    final resp = await _dio.get('/requests', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (userId != null) 'userId': userId,
    });
    return (resp.data as List<dynamic>)
        .map((e) => Solicitud.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // GET /requests/:id
  Future<Solicitud> getOne(int id) async {
    final resp = await _dio.get('/requests/$id');
    return Solicitud.fromMap(resp.data as Map<String, dynamic>);
  }

  // POST /requests
  Future<Solicitud> create(Map<String, dynamic> data) async {
    final resp = await _dio.post('/requests', data: data);
    return Solicitud.fromMap(resp.data as Map<String, dynamic>);
  }

  // PUT /requests/:id
  Future<Solicitud> update(int id, Map<String, dynamic> data) async {
    final resp = await _dio.put('/requests/$id', data: data);
    return Solicitud.fromMap(resp.data as Map<String, dynamic>);
  }

  // DELETE /requests/:id
  Future<void> delete(int id) async {
    await _dio.delete('/requests/$id');
  }

  // PATCH /requests/:id/accept
  Future<Solicitud> accept(int id, {int? expertId}) async {
    final resp = await _dio.patch('/requests/$id/accept', data: {
      if (expertId != null) 'expertId': expertId,
    });
    return Solicitud.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /requests/:id/reject
  Future<Solicitud> reject(int id) async {
    final resp = await _dio.patch('/requests/$id/reject');
    return Solicitud.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /requests/:id/cancel
  Future<Solicitud> cancel(int id) async {
    final resp = await _dio.patch('/requests/$id/cancel');
    return Solicitud.fromMap(resp.data as Map<String, dynamic>);
  }
}
