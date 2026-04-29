// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final dioProvider = Provider<Dio>((ref) {
//   final dio = Dio(
//     BaseOptions(
//       // TODO: Configurar URL real del backend.
//       baseUrl: 'https://api.outventura.com',
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {'Content-Type': 'application/json'},
//     ),
//   );

//   // TODO: Añadir interceptor de autenticación con flutter_secure_storage.

//   ref.onDispose(() => dio.close());

//   return dio;
// });
