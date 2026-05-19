import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que almacena el usuario actualmente logueado.
final NotifierProvider<CurrentUserNotifier, User?> currentUserProvider =
    NotifierProvider<CurrentUserNotifier, User?>(CurrentUserNotifier.new);

// Provider que intenta restaurar la sesión al iniciar la app.
// Si existe un token guardado, asume que el usuario tiene una sesión activa.
final FutureProvider<void> sessionRestorerProvider = FutureProvider<void>(
  (ref) async {
    final token = await readAuthToken();
    if (token != null) {
      // Token existe: intentar restaurar la sesión.
      // TODO: cuando el back esté listo, hacer GET /auth/profile para obtener los datos del usuario.
      // De momento, restauramos con datos fake.
      await Future.delayed(const Duration(milliseconds: 500));
      final User usuario = usersFake[0]; // Simulado
      ref.read(currentUserProvider.notifier).setUsuario(usuario);
    }
  },
);

class CurrentUserNotifier extends Notifier<User?> {
  // Estado inicial: no hay usuario logueado.
  @override
  User? build() => null;

  // TODO: reemplazar por:
  //   try {
  //     final response = await dio.post('/auth/login', data: {'email': email, 'password': password});
  //     // Respuesta del back: {user: {id, name, email, role: "code"}, access_token: "..."}
  //     await saveAuthToken(response.data['access_token'] as String);
  //     state = User.fromMap(response.data['user'] as Map<String, dynamic>);
  //     return state;
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 401) throw Exception('Credenciales incorrectas');
  //     if (e.type == DioExceptionType.connectionError) throw Exception('Sin conexión al servidor');
  //     if (e.type == DioExceptionType.receiveTimeout) throw Exception('El servidor tarda demasiado');
  //     rethrow;
  //   }
  Future<User?> login(String email, [String password = '']) async {
    try {
      await Future.delayed(ApiDelay.accion);
      final User usuario = usersFake.firstWhere(
        (User u) => u.email == email,
        orElse: () => usersFake[0],
      );
      state = usuario;
      return usuario;
    } catch (e) {
      throw parseDioError(e);
    }
  }

  void setUsuario(User usuario) => state = usuario;

  // TODO: reemplazar por:
  //   await dio.post('/auth/register', data: {
  //     'name': name, 'surname': surname, 'email': email, 'password': password,
  //   });
  Future<void> register(String name, String surname, String email, String password) async {
    await Future.delayed(ApiDelay.accion);
    // Registro simulado: no modifica el estado (el usuario deberá hacer login)
  }

  // TODO: reemplazar por: await dio.post('/auth/logout');
  Future<void> cerrarSesion() async {
    await clearAuthToken();
    state = null;
  }
}
