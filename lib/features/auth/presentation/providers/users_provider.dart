import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/data/models/user_model.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

// Lista completa de usuarios del sistema. GET /user.
// Usado por el panel de administración para gestionar cuentas.
final AsyncNotifierProvider<UsersNotifier, List<User>> usuariosProvider =
    AsyncNotifierProvider<UsersNotifier, List<User>>(UsersNotifier.new);

// Filtra usuarios en el frontend por rol, estado activo y texto libre
// (nombre, apellidos, email, teléfono).
// El filtrado es local mientras no haya soporte de query params en el backend.
final usuariosFiltradosProvider = Provider.family<AsyncValue<List<User>>, ({String query, UserRole? rol, bool? activo})>((ref, params) {
  final AsyncValue<List<User>> asyncTodos = ref.watch(usuariosProvider);
  
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
    // Busca en nombre, apellidos, email y teléfono a la vez
    return base.where((User u) =>
      '${u.name} ${u.surname} ${u.email} ${u.phone ?? ''}'.toLowerCase().contains(q)
    ).toList();
  });
});

class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  // Carga la lista completa de usuarios desde el backend al inicializar.
  Future<List<User>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/user');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // POST /user - crea un nuevo usuario. Devuelve el usuario con el ID asignado por el backend.
  Future<User> agregar(User usuario, {String? password}) async {
    try {
      final dio = ref.read(dioProvider);
      final Map<String, dynamic> data = usuario.toMap();
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      final response = await dio.post('/user', data: data);
      final User created = UserModel.fromMap(response.data as Map<String, dynamic>);
      ref.invalidateSelf();
      return created;
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // PATCH /user/:id - actualiza un usuario. Actualiza el item en local sin recargar la lista.
  Future<void> actualizar(User viejo, User nuevo, {String? password}) async { 
    if (viejo.id == null) {
      throw StateError('User has no id');
    }
    try {
      final dio = ref.read(dioProvider);

      // Prepara los datos con la contraseña si existe
      final Map<String, dynamic> datosAEnviar = nuevo.toMap();
      if (password != null && password.isNotEmpty) {
        datosAEnviar['password'] = password;
      }

      // Envia el paquete modificado
      await dio.patch('/user/${viejo.id}', data: datosAEnviar);
      
      final List<User> listaActual = [...(state.value ?? [])];
      for (int i = 0; i < listaActual.length; i++) {
        if (listaActual[i].id == viejo.id) {
          listaActual[i] = nuevo;
          break;
        }
      }
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // DELETE /user/:id - elimina un usuario. Lo quita de la lista local inmediatamente.
  Future<void> eliminar(User eliminado) async {
    if (eliminado.id == null) {
      throw StateError('User has no id');
    }
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/user/${eliminado.id}');
      final List<User> listaActual = [...(state.value ?? [])];
      listaActual.removeWhere((User u) => u.id == eliminado.id);
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}

// Lista de usuarios clientes (rol USER). GET /user/clients.
final AsyncNotifierProvider<ClientsNotifier, List<User>> clientesProvider =
    AsyncNotifierProvider<ClientsNotifier, List<User>>(ClientsNotifier.new);

class ClientsNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/user/clients');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((e) => UserModel.fromMap(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }
}
