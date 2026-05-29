import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _tokenKey = 'auth_token';
const _storage = FlutterSecureStorage(
  webOptions: WebOptions(
    dbName: 'outventura_storage',
    publicKey: 'outventura_key',
  ),
);

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

  // Extrae el mensaje real que NestJS manda en el JSON
  String? extraerMensajeNestJS() {
    if (error.response?.data is Map &&
        error.response?.data['message'] != null) {
      final mensaje = error.response?.data['message'];
      // NestJS a veces devuelve los errores de validación como una lista de strings
      if (mensaje is List) {
        return mensaje.join(' | ');
      }
      return mensaje.toString();
    }
    return null;
  }

  // Extrae el mensaje real (si lo hay)
  final String? mensajeReal = extraerMensajeNestJS();

  switch (error.response?.statusCode) {
    case 400:
      // Si NestJS saca error, lo muestra. Si no, usa el genérico.
      return Exception(mensajeReal ?? 'Petición incorrecta');
    case 403:
      return Exception(mensajeReal ?? 'Sin permisos para realizar esta acción');
    case 404:
      return Exception(mensajeReal ?? 'Recurso no encontrado');
    case 409:
      return Exception(mensajeReal ?? 'El recurso ya existe');
    case 500:
      return Exception('Error interno del servidor');
    default:
      final String detail = mensajeReal != null
          ? '${error.response?.statusCode}: $mensajeReal'
          : '${error.response?.statusCode ?? 'sin respuesta'}';
      return Exception('Error inesperado ($detail)');
  }
}
