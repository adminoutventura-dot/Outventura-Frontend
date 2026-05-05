import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/auth_storage.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

final authApiProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(dioProvider), ref.watch(authStorageProvider));
});

class AuthApiService {
  final Dio _dio;
  final AuthStorage _storage;

  AuthApiService(this._dio, this._storage);

  // POST /auth/login — Returns access + refresh tokens and the logged user.
  Future<Usuario> login(String email, String password) async {
    final resp = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = resp.data as Map<String, dynamic>;
    await _storage.saveTokens(
      data['accessToken'] as String,
      data['refreshToken'] as String,
    );
    return Usuario.fromMap(data['user'] as Map<String, dynamic>);
  }

  // POST /auth/logout — Invalidates the refresh token on the backend.
  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    }
    await _storage.clear();
  }

  // GET /auth/me — Returns the currently authenticated user.
  Future<Usuario> getMe() async {
    final resp = await _dio.get('/auth/me');
    return Usuario.fromMap(resp.data as Map<String, dynamic>);
  }
}
