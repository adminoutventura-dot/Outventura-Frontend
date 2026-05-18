import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _tokenKey = 'auth_token';
const _storage = FlutterSecureStorage();

// Guarda el JWT recibido tras el login.
Future<void> saveAuthToken(String token) =>
    _storage.write(key: _tokenKey, value: token);

// Borra el JWT almacenado (llamar al cerrar sesión).
Future<void> clearAuthToken() => _storage.delete(key: _tokenKey);

// Lee el JWT almacenado (para restaurar la sesión al arrancar la app).
Future<String?> readAuthToken() => _storage.read(key: _tokenKey);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Añade el JWT a cada petición si hay uno guardado.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Token expirado o inválido: borrarlo para que la UI redirija al login.
        if (error.response?.statusCode == 401) {
          await clearAuthToken();
        }
        handler.next(error);
      },
    ),
  );

  ref.onDispose(dio.close);

  return dio;
});

// Convierte cualquier error de red en una excepción legible.
Exception parseDioError(Object error) {
  if (error is! DioException) return Exception(error.toString());
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.unknown) {
    return Exception('Sin conexión al servidor');
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return Exception('El servidor tarda demasiado en responder');
  }
  switch (error.response?.statusCode) {
    case 400:
      return Exception('Petición incorrecta');
    case 403:
      return Exception('Sin permisos para realizar esta acción');
    case 404:
      return Exception('Recurso no encontrado');
    case 409:
      return Exception('El recurso ya existe');
    case 500:
      return Exception('Error interno del servidor');
    default:
      // Intenta extraer el mensaje del servidor - fallback al código solo.
      final String? msg = error.response?.data is Map
          ? error.response?.data['message'] as String?
          : null;
      final String detail = msg != null
          ? '${error.response?.statusCode}: $msg'
          : '${error.response?.statusCode ?? 'sin respuesta'}';
      return Exception('Error inesperado ($detail)');
  }
}
