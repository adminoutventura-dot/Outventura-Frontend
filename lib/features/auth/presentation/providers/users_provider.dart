import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que gestiona la lista de usuarios.
final NotifierProvider<UsuariosNotifier, List<Usuario>> usuariosProvider = NotifierProvider<UsuariosNotifier, List<Usuario>>(
  UsuariosNotifier.new,
);

// Notifier que implementa la lógica de gestión de usuarios.
class UsuariosNotifier extends Notifier<List<Usuario>> {
  @override
  List<Usuario> build() => <Usuario>[...usuariosFake];

  // Método para agregar usuarios.
  void agregar(Usuario usuario) {
    // State es una variable de riverpod.
    final List<Usuario> listaActual = state;
    final List<Usuario> listaNueva = <Usuario>[...listaActual, usuario];
    state = listaNueva;
  }

  // Método para actualizar un usuario existente.
  void actualizar(Usuario viejo, Usuario nuevo) {
    final List<Usuario> listaActual = state;

    for (int i = 0; i < listaActual.length; i++) {
      if (listaActual[i].id == viejo.id) {
        listaActual[i] = nuevo;
        break;
      }
    }
    state = listaActual;
  }

  // Método para eliminar un usuario.
  void eliminar(Usuario eliminado) {
    final List<Usuario> listaNueva = <Usuario>[...state];
    listaNueva.removeWhere((Usuario usuario) => usuario.id == eliminado.id);
    state = listaNueva;
  }
}
