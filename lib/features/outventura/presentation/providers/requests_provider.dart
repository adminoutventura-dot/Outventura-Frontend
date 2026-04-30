import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/api_delay.dart';
import 'package:outventura/features/outventura/data/fakes/requests_fake.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';

// Expone una lista de solicitudes. Simula llamadas al backend.
final AsyncNotifierProvider<SolicitudesNotifier, List<Solicitud>> solicitudesProvider =
    AsyncNotifierProvider<SolicitudesNotifier, List<Solicitud>>(SolicitudesNotifier.new);

// Filtra solicitudes por ruta de excursión. Simula búsqueda en backend.
typedef SolicitudesFiltroParams = ({String query, int? idUsuario});

final solicitudesFiltadasProvider = Provider.family<AsyncValue<List<Solicitud>>, SolicitudesFiltroParams>((ref, params) {
  final AsyncValue<List<Solicitud>> asyncTodas = ref.watch(solicitudesProvider);
  final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];

  return asyncTodas.whenData((List<Solicitud> todas) {
    final List<Solicitud> base = params.idUsuario != null
        ? todas.where((Solicitud s) => s.idUsuario == params.idUsuario).toList()
        : todas;

    if (params.query.isEmpty) return base;
    final String q = params.query.toLowerCase();
    return base.where((Solicitud s) {
      final Excursion? exc = excursiones.cast<Excursion?>().firstWhere(
        (Excursion? e) => e?.id == s.idExcursion,
        orElse: () => null,
      );
      final String ruta = exc != null ? '${exc.puntoInicio} ${exc.puntoFin}'.toLowerCase() : '';
      return ruta.contains(q);
    }).toList();
  });
});

class SolicitudesNotifier extends AsyncNotifier<List<Solicitud>> {
  @override
  Future<List<Solicitud>> build() async {
    // Simula GET /api/solicitudes
    await Future.delayed(ApiDelay.carga);
    return [...solicitudesFake];
  }

  // Simula POST /api/solicitudes
  Future<void> agregar(Solicitud solicitud) async {
    await Future.delayed(ApiDelay.accion);
    final List<Solicitud> listaActual = [...(state.value ?? [])];
    listaActual.add(solicitud);
    state = AsyncData(listaActual);
  }

  // Simula PUT /api/solicitudes/:id
  Future<void> actualizar(Solicitud viejo, Solicitud nuevo) async {
    await Future.delayed(ApiDelay.accion);
    final List<Solicitud> listaActual = [...(state.value ?? [])];
    final int index = listaActual.indexWhere((Solicitud s) => s.id == viejo.id);
    if (index != -1) {
      listaActual[index] = nuevo;
    }
    state = AsyncData(listaActual);
  }

  // Simula DELETE /api/solicitudes/:id
  Future<void> eliminar(Solicitud solicitud) async {
    await Future.delayed(ApiDelay.accion);
    final List<Solicitud> listaActual = [...(state.value ?? [])];
    listaActual.removeWhere((Solicitud s) => s.id == solicitud.id);
    state = AsyncData(listaActual);
  }

  // Simula PATCH /api/solicitudes/:id/aceptar
  Future<void> aceptar(Solicitud solicitud) async {
    await Future.delayed(ApiDelay.accion);
    final Solicitud aceptada = solicitud.copyWith(estado: EstadoSolicitud.confirmada);
    await actualizar(solicitud, aceptada);
  }

  // Simula PATCH /api/solicitudes/:id/rechazar
  Future<void> rechazar(Solicitud solicitud) async {
    await Future.delayed(ApiDelay.accion);
    final Solicitud rechazada = solicitud.copyWith(estado: EstadoSolicitud.cancelada);
    await actualizar(solicitud, rechazada);
  }
}
