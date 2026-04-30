import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que almacena el usuario actualmente logueado.
final NotifierProvider<CurrentUserNotifier, Usuario?> currentUserProvider =
    NotifierProvider<CurrentUserNotifier, Usuario?>(CurrentUserNotifier.new);

class CurrentUserNotifier extends Notifier<Usuario?> {
  @override
  Usuario? build() => null;

  // Simula POST /api/auth/login — busca por email en los datos fake.
  Future<Usuario?> login(String email) async {
    await Future.delayed(ApiDelay.accion);
    final Usuario usuario = usuariosFake.firstWhere(
      (Usuario u) => u.email == email,
      orElse: () => usuariosFake[0],
    );
    state = usuario;
    return usuario;
  }

  void setUsuario(Usuario usuario) => state = usuario;

  // Simula POST /api/auth/logout
  Future<void> cerrarSesion() async {
    await Future.delayed(ApiDelay.accion);
    state = null;
  }
}
