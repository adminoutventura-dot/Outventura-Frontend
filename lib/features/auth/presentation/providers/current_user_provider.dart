import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/data/models/user_model.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Almacena el usuario actualmente logueado (null si no hay sesión).
// Expuesto como Notifier para poder mutarlo desde login/logout.
final NotifierProvider<CurrentUserNotifier, User?> currentUserProvider =
    NotifierProvider<CurrentUserNotifier, User?>(CurrentUserNotifier.new);

// Se ejecuta una sola vez al arrancar la app.
// Lee el token guardado en SecureStorage y, si existe, consulta GET /auth/profile
// para recuperar los datos del usuario sin obligarle a volver a loguearse.
final FutureProvider<void> sessionRestorerProvider = FutureProvider<void>((
  ref,
) async {
  final token = await readAuthToken();

  if (token != null) {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/auth/profile');
      final User usuario = UserModel.fromMap(
        response.data as Map<String, dynamic>,
      );

      ref.read(currentUserProvider.notifier).setUsuario(usuario);
    } catch (e) {
      await clearAuthToken();
    }
  }
});

class CurrentUserNotifier extends Notifier<User?> {
  @override
  // Estado inicial: sin usuario logueado
  User? build() => null;

  // POST /auth/login - guarda el JWT en SecureStorage y actualiza el estado.
  // Lanza excepciones tipadas para que la UI pueda mostrar el mensaje correcto.
  Future<User?> login(String email, [String password = '']) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      await saveAuthToken(data['access_token'] as String);
      state = UserModel.fromMap(data['user'] as Map<String, dynamic>);
      return state;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401)
        throw Exception('Credenciales incorrectas');
      if (e.type == DioExceptionType.connectionError)
        throw Exception('Sin conexión al servidor');
      if (e.type == DioExceptionType.receiveTimeout)
        throw Exception('El servidor tarda demasiado');
      throw parseDioError(e);
    }
  }

  // Actualiza el estado con un usuario ya construido (usado por sessionRestorerProvider).
  void setUsuario(User usuario) => state = usuario;

  // POST /auth/register - crea la cuenta. No loguea automáticamente.
  Future<void> register(
    String name,
    String surname,
    String email,
    String password,
  ) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(
        '/auth/register',
        data: {
          'name': name,
          'surname': surname,
          'email': email,
          'password': password,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409)
        throw Exception('El email ya está registrado');
      throw parseDioError(e);
    }
  }

  // PATCH /user/:id - actualiza el perfil del usuario. Si se cambia la foto, se actualizará al instante en el Drawer.
  Future<void> actualizarPerfil(
    User usuarioEditado, {
    String? nuevaPassword,
  }) async {
    if (state == null || state!.id == null) return;

    try {
      final dio = ref.read(dioProvider);

      // Prepara los datos
      final Map<String, dynamic> datosAEnviar = usuarioEditado.toMap();
      if (nuevaPassword != null && nuevaPassword.isNotEmpty) {
        datosAEnviar['password'] = nuevaPassword;
      }

      // Envia el parche a NestJS
      final response = await dio.patch(
        '/user/${state!.id}',
        data: datosAEnviar,
      );

      // Actualiza el estado actual con la respuesta de NestJS
      // Así el Drawer cambiará la foto.
      state = UserModel.fromMap(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // Borra el token y pone el estado a null - redirige al login.
  Future<void> cerrarSesion() async {
    await clearAuthToken();
    state = null;
  }
}
