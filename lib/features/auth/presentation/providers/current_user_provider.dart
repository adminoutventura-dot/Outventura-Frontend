import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que almacena el usuario actualmente logueado.
final NotifierProvider<CurrentUserNotifier, Usuario?> currentUserProvider =
    NotifierProvider<CurrentUserNotifier, Usuario?>(CurrentUserNotifier.new);

class CurrentUserNotifier extends Notifier<Usuario?> {
  @override
  Usuario? build() => null;

  void setUsuario(Usuario usuario) => state = usuario;

  void cerrarSesion() => state = null;
}
