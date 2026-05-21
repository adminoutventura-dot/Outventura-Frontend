import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';

// Lista completa de guías. GET /guide.
final AsyncNotifierProvider<GuidesNotifier, List<Guide>> guidesProvider =
    AsyncNotifierProvider<GuidesNotifier, List<Guide>>(GuidesNotifier.new);

class GuidesNotifier extends AsyncNotifier<List<Guide>> {
  @override
  Future<List<Guide>> build() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/guide');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((e) => Guide.fromMap(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // POST /guide - crea el guía y recarga la lista para obtener el ID generado.
  Future<void> agregar(Guide guide) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/guide', data: guide.toMap());
      ref.invalidateSelf();
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // PATCH /guide/:id - actualiza el guía en el backend y en la lista local.
  Future<void> actualizar(Guide viejo, Guide nuevo) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/guide/${viejo.id}', data: nuevo.toMap());
      final List<Guide> listaActual = [...(state.value ?? [])];
      final int index = listaActual.indexWhere((Guide g) => g.id == viejo.id);
      if (index != -1) {
        listaActual[index] = nuevo;
      }
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // DELETE /guide/:id - elimina el guía del backend y de la lista local.
  Future<void> eliminar(Guide eliminado) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/guide/${eliminado.id}');
      final List<Guide> listaActual = [...(state.value ?? [])];
      listaActual.removeWhere((Guide g) => g.id == eliminado.id);
      state = AsyncData(listaActual);
    } on DioException catch (e) {
      throw parseDioError(e);
    }
  }

  // Devuelve el guía asociado a un userId, o null si no existe en la lista cargada.
  Guide? porUsuario(int userId) {
    return state.value?.where((Guide g) => g.userId == userId).firstOrNull;
  }
}
