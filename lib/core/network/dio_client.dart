import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/auth_storage.dart';

// Change to your backend's address:
// - Android emulator: 10.0.2.2:3000
// - iOS simulator / desktop / Flutter web: localhost:3000
// - Physical device: your machine's LAN IP, e.g. 192.168.1.50:3000
// const String _baseUrl = 'http://10.0.2.2:3000';
const String _baseUrl = 'http://localhost:3000';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(authStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor(dio, storage));

  ref.onDispose(() => dio.close());
  return dio;
});

// Interceptor that injects the Bearer token and handles 401 with token refresh.
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final AuthStorage _storage;

  _AuthInterceptor(this._dio, this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt token refresh
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );
          final data = response.data as Map<String, dynamic>;
          await _storage.saveTokens(
            data['accessToken'] as String,
            data['refreshToken'] as String,
          );
          // Retry the original request with new token
          final newToken = data['accessToken'] as String;
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retried = await _dio.fetch(err.requestOptions);
          return handler.resolve(retried);
        } catch (_) {
          await _storage.clear();
        }
      }
    }
    handler.next(err);
  }
}
