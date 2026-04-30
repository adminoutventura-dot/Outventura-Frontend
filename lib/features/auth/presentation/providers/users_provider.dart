import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que gestiona la lista de usuarios. Simula llamadas al backend.
final AsyncNotifierProvider<UsuariosNotifier, List<Usuario>> usuariosProvider =
    AsyncNotifierProvider<UsuariosNotifier, List<Usuario>>(UsuariosNotifier.new);

// Filtra usuarios por nombre, apellidos, email o teléfono. Simula búsqueda en backend.
final usuariosFiltradosProvider = Provider.family<AsyncValue<List<Usuario>>, String>((ref, query) {
  final AsyncValue<List<Usuario>> asyncTodos = ref.watch(usuariosProvider);
  return asyncTodos.whenData((List<Usuario> todos) {
    if (query.isEmpty) return todos;
    final String q = query.toLowerCase();
    return todos.where((Usuario u) =>
      '${u.nombre} ${u.apellidos} ${u.email} ${u.telefono ?? ''}'.toLowerCase().contains(q)
    ).toList();
  });
});

// Notifier que implementa la lógica de gestión de usuarios.
class UsuariosNotifier extends AsyncNotifier<List<Usuario>> {
  @override
  Future<List<Usuario>> build() async {
    // Simula GET /api/usuarios
    await Future.delayed(ApiDelay.carga);
    return [...usuariosFake];
  }

  // Simula POST /api/usuarios
  Future<void> agregar(Usuario usuario) async {
    await Future.delayed(ApiDelay.accion);
    final List<Usuario> listaActual = state.value ?? [];

    // AsyncValue envuelve los estados loading, error y data
    // AsyncData = AsyncValue.data, AsyncError = AsyncValue.error, AsyncLoading = AsyncValue.loading
    state = AsyncData([...listaActual, usuario]);
  }

  // Simula PUT /api/usuarios/:id
  Future<void> actualizar(Usuario viejo, Usuario nuevo) async {
    await Future.delayed(ApiDelay.accion);
    final List<Usuario> listaActual = [...(state.value ?? [])];
    for (int i = 0; i < listaActual.length; i++) {
      if (listaActual[i].id == viejo.id) {
        listaActual[i] = nuevo;
        break;
      }
    }
    state = AsyncData(listaActual);
  }

  // Simula DELETE /api/usuarios/:id
  Future<void> eliminar(Usuario eliminado) async {
    await Future.delayed(ApiDelay.accion);
    final List<Usuario> listaActual = [...(state.value ?? [])];
    listaActual.removeWhere((Usuario u) => u.id == eliminado.id);
    state = AsyncData(listaActual);
  }
}
