import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/data/services/user_api_service.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que gestiona la lista de usuarios.
final AsyncNotifierProvider<UsersNotifier, List<Usuario>> usuariosProvider =
    AsyncNotifierProvider<UsersNotifier, List<Usuario>>(UsersNotifier.new);

// Filtra usuarios en el cliente mientras el search se propaga al backend.
// Con el backend conectado, el filtro real se hace en GET /users?search=
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

// Notifier con llamadas reales al backend.
class UsersNotifier extends AsyncNotifier<List<Usuario>> {
  @override
  Future<List<Usuario>> build() async {
    return ref.read(userApiProvider).getAll();
  }

  Future<void> agregar(Usuario usuario, {String? password}) async {
    // El backend asigna el ID real; recargamos la lista completa tras crear.
    await ref.read(userApiProvider).create({
      'name': usuario.nombre,
      'surname': usuario.apellidos,
      'email': usuario.email,
      'phone': usuario.telefono,
      'status': usuario.activo,
      'roleId': _rolToId(usuario.rol),
      if (password != null && password.isNotEmpty) 'password': password,
    });
    ref.invalidateSelf();
  }

  Future<void> actualizar(Usuario viejo, Usuario nuevo) async {
    await ref.read(userApiProvider).update(viejo.id, {
      'name': nuevo.nombre,
      'surname': nuevo.apellidos,
      'email': nuevo.email,
      'phone': nuevo.telefono,
      'status': nuevo.activo,
    });
    ref.invalidateSelf();
  }

  Future<void> eliminar(Usuario eliminado) async {
    await ref.read(userApiProvider).delete(eliminado.id);
    ref.invalidateSelf();
  }

  Future<void> cambiarEstado(Usuario usuario, {required bool activo}) async {
    await ref.read(userApiProvider).patchStatus(usuario.id, status: activo);
    ref.invalidateSelf();
  }

  // Helper: convierte TipoRol a roleId (provisional — depende de los roles creados en BD).
  // En producción esto vendría del backend o de un provider de roles.
  int _rolToId(TipoRol rol) {
    switch (rol) {
      case TipoRol.superadmin:
        return 1;
      case TipoRol.admin:
        return 2;
      case TipoRol.experto:
        return 3;
      case TipoRol.usuario:
        return 4;
      case TipoRol.invitado:
        return 5;
    }
  }
}


