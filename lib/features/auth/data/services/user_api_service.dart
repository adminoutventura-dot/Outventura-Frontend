import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

final userApiProvider = Provider<UserApiService>((ref) {
  return UserApiService(ref.watch(dioProvider));
});

class UserApiService {
  final Dio _dio;

  UserApiService(this._dio);

  // GET /users?search=
  Future<List<Usuario>> getAll({String? search}) async {
    final resp = await _dio.get('/users', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (resp.data as List<dynamic>)
        .map((e) => Usuario.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // GET /users/:id
  Future<Usuario> getOne(int id) async {
    final resp = await _dio.get('/users/$id');
    return Usuario.fromMap(resp.data as Map<String, dynamic>);
  }

  // POST /users
  Future<Usuario> create(Map<String, dynamic> data) async {
    final resp = await _dio.post('/users', data: data);
    return Usuario.fromMap(resp.data as Map<String, dynamic>);
  }

  // PATCH /users/:id
  Future<Usuario> update(int id, Map<String, dynamic> data) async {
    final resp = await _dio.patch('/users/$id', data: data);
    return Usuario.fromMap(resp.data as Map<String, dynamic>);
  }

  // DELETE /users/:id
  Future<void> delete(int id) async {
    await _dio.delete('/users/$id');
  }

  // PATCH /users/:id/status
  Future<Usuario> patchStatus(int id, {required bool status}) async {
    final resp = await _dio.patch('/users/$id/status', data: {'status': status});
    return Usuario.fromMap(resp.data as Map<String, dynamic>);
  }
}
