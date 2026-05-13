import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que almacena el usuario actualmente logueado.
final NotifierProvider<CurrentUserNotifier, User?> currentUserProvider =
    NotifierProvider<CurrentUserNotifier, User?>(CurrentUserNotifier.new);

class CurrentUserNotifier extends Notifier<User?> {
  @override
  // Estado inicial: no hay usuario logueado.
  User? build() => null;

  // TEMPORAL: reemplazar por llamada HTTP real con email+password y recibir JWT. Eliminar import de users_fake.dart.
  // Simula POST /api/auth/login — busca por email en los datos fake.
  Future<User?> login(String email) async {
    await Future.delayed(ApiDelay.accion);
    final User usuario = usersFake.firstWhere(
      (User u) => u.email == email,
      orElse: () => usersFake[0],
    );
    state = usuario;
    return usuario;
  }

  void setUsuario(User usuario) => state = usuario;

  // TEMPORAL: reemplazar por llamada HTTP real y borrar el JWT del almacenamiento seguro.
  // Simula POST /api/auth/logout
  Future<void> cerrarSesion() async {
    await Future.delayed(ApiDelay.accion);
    state = null;
  }
}
