import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/auth/data/fakes/guides_fake.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';

// Provider que gestiona la lista de guías. Simula llamadas al backend.
final AsyncNotifierProvider<GuidesNotifier, List<Guide>> guidesProvider =
    AsyncNotifierProvider<GuidesNotifier, List<Guide>>(GuidesNotifier.new);

class GuidesNotifier extends AsyncNotifier<List<Guide>> {
  @override
  // TEMPORAL: reemplazar cuerpo por await dio.get('/guide') y eliminar import de guides_fake.dart.
  Future<List<Guide>> build() async {
    await Future.delayed(ApiDelay.carga);
    return [...guidesFake];
  }

  // TEMPORAL: reemplazar cuerpo por await dio.post('/guide', data: guide.toMap()).
  Future<void> agregar(Guide guide) async {
    await Future.delayed(ApiDelay.accion);
    final List<Guide> lista = [...(state.value ?? [])];
    final int nuevoId = lista.isEmpty ? 1 : lista.last.id + 1;
    lista.add(guide.copyWith(id: nuevoId));
    state = AsyncData(lista);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.patch('/guide/${viejo.id}', data: nuevo.toMap()).
  Future<void> actualizar(Guide viejo, Guide nuevo) async {
    await Future.delayed(ApiDelay.accion);
    final List<Guide> lista = [...(state.value ?? [])];
    for (int i = 0; i < lista.length; i++) {
      if (lista[i].id == viejo.id) {
        lista[i] = nuevo;
        break;
      }
    }
    state = AsyncData(lista);
  }

  // TEMPORAL: reemplazar cuerpo por await dio.delete('/guide/${eliminado.id}').
  Future<void> eliminar(Guide eliminado) async {
    await Future.delayed(ApiDelay.accion);
    final List<Guide> lista = [...(state.value ?? [])];
    lista.removeWhere((Guide g) => g.id == eliminado.id);
    state = AsyncData(lista);
  }

  // Returns the Guide associated with a userId, or null if not found.
  Guide? porUsuario(int userId) {
    final List<Guide>? lista = state.value;
    if (lista == null) return null;
    try {
      return lista.firstWhere((Guide g) => g.userId == userId);
    } catch (_) {
      return null;
    }
  }
}
