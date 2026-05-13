import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Provider que gestiona la lista de usuarios. Simula llamadas al backend.
final AsyncNotifierProvider<UsersNotifier, List<User>> usuariosProvider =
    AsyncNotifierProvider<UsersNotifier, List<User>>(UsersNotifier.new);

// TEMPORAL: el filtro se moverá al backend → GET /api/usuarios?q=... Eliminar este provider y llamar directamente al endpoint filtrado.
// Filtra usuarios por nombre, apellidos, email, teléfono, rol y activo. Simula búsqueda en backend.
final usuariosFiltradosProvider = Provider.family<AsyncValue<List<User>>, ({String query, UserRole? rol, bool? activo})>((ref, params) {

  // Observa el estado asíncrono de todos los usuarios (notifica si cambia y recalcula la lista)
  final AsyncValue<List<User>> asyncTodos = ref.watch(usuariosProvider);
  
  // Aplica el filtro solo cuando los datos están disponibles
  return asyncTodos.whenData((List<User> todos) {
    List<User> base = todos;

    if (params.rol != null) {
      base = base.where((User u) => u.role == params.rol).toList();
    }
    if (params.activo != null) {
      base = base.where((User u) => u.active == params.activo).toList();
    }
    if (params.query.isEmpty) {
      return base;
    }
    final String q = params.query.toLowerCase();
    
    // Filtra por nombre, apellidos, email o teléfono
    return base.where((User u) =>
      '${u.name} ${u.surname} ${u.email} ${u.phone ?? ''}'.toLowerCase().contains(q)
    ).toList();
  });
});

// Notifier que implementa la lógica de gestión de usuarios.
class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/usuarios') y eliminar import de users_fake.dart.
  Future<List<User>> build() async {
    // Simula GET /api/usuarios
    await Future.delayed(ApiDelay.carga);
    return [...usersFake];
  }

  // TEMPORAL: reemplazar cuerpo por await dio.post('/usuarios', data: usuario.toJson()).
  // Simula POST /api/usuarios
  Future<void> agregar(User usuario) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<User> listaActual = [...(state.value ?? [])];
    // Agrega el nuevo usuario a la lista
    listaActual.add(usuario);
    // Actualiza el estado con la nueva lista
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.put('/usuarios/${viejo.id}', data: nuevo.toJson()).
  // Simula PUT /api/usuarios/:id
  Future<void> actualizar(User viejo, User nuevo) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<User> listaActual = [...(state.value ?? [])];
    // Busca y reemplaza el usuario con el ID coincidente
    for (int i = 0; i < listaActual.length; i++) {
      if (listaActual[i].id == viejo.id) {
        listaActual[i] = nuevo;
        break;
      }
    }
    // Actualiza el estado con la lista modificada
    state = AsyncData(listaActual);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.delete('/usuarios/${eliminado.id}').
  // Simula DELETE /api/usuarios/:id
  Future<void> eliminar(User eliminado) async {
    await Future.delayed(ApiDelay.accion);
    // Saca la lista actual o una vacía si es nula
    final List<User> listaActual = [...(state.value ?? [])];
    // Elimina el usuario con el ID coincidente
    listaActual.removeWhere((User u) => u.id == eliminado.id);
    // Actualiza el estado con la lista sin el usuario eliminado
    state = AsyncData(listaActual);
  }
}
