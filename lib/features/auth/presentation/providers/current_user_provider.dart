import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/data/services/auth_api_service.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que almacena el usuario actualmente logueado.
final NotifierProvider<CurrentUserNotifier, Usuario?> currentUserProvider =
    NotifierProvider<CurrentUserNotifier, Usuario?>(CurrentUserNotifier.new);

class CurrentUserNotifier extends Notifier<Usuario?> {
  @override
  Usuario? build() => null;

  // POST /auth/login — llama al backend con email y password.
  Future<Usuario?> login(String email, String password) async {
    final usuario = await ref.read(authApiProvider).login(email, password);
    state = usuario;
    return usuario;
  }

  void setUsuario(Usuario usuario) => state = usuario;

  // POST /auth/logout — invalida el refresh token y borra el almacenamiento local.
  Future<void> cerrarSesion() async {
    await ref.read(authApiProvider).logout();
    state = null;
  }
}
