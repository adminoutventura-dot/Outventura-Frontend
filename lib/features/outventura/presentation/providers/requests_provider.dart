import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/services/request_api_service.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

// Expone una lista de solicitudes desde el backend.
final AsyncNotifierProvider<RequestsNotifier, List<Solicitud>> solicitudesProvider =
    AsyncNotifierProvider<RequestsNotifier, List<Solicitud>>(RequestsNotifier.new);

// Filtro local — el backend también acepta ?search= y ?userId= en GET /requests.
final solicitudesFiltadasProvider = Provider.family<AsyncValue<List<Solicitud>>, ({String query, int? idUsuario})>((ref, params) {
  final AsyncValue<List<Solicitud>> asyncTodas = ref.watch(solicitudesProvider);
  return asyncTodas.whenData((List<Solicitud> todas) {
    List<Solicitud> base = params.idUsuario != null
        ? todas.where((s) => s.idUsuario == params.idUsuario).toList()
        : todas;
    if (params.query.isEmpty) return base;
    final String q = params.query.toLowerCase();
    return base.where((Solicitud s) => s.idExcursion == int.tryParse(q) || s.id.toString().contains(q)).toList();
  });
});

class RequestsNotifier extends AsyncNotifier<List<Solicitud>> {
  @override
  Future<List<Solicitud>> build() async {
    return ref.read(requestApiProvider).getAll();
  }

  Future<void> agregar(Solicitud solicitud) async {
    await ref.read(requestApiProvider).create({
      'start_point': solicitud.idExcursion.toString(), // placeholder; form should pass real values
      'end_point': '',
      'start_date': DateTime.now().toIso8601String(),
      'end_date': DateTime.now().add(const Duration(hours: 8)).toIso8601String(),
      'categories': [],
      'participant_count': solicitud.numeroParticipantes,
      'description': null,
      'userId': solicitud.idUsuario,
      'excursionId': solicitud.idExcursion != 0 ? solicitud.idExcursion : null,
    });
    ref.invalidateSelf();
  }

  Future<void> actualizar(Solicitud viejo, Solicitud nuevo) async {
    await ref.read(requestApiProvider).update(viejo.id, {
      'participant_count': nuevo.numeroParticipantes,
      'expertId': nuevo.idExperto,
      'excursionId': nuevo.idExcursion != 0 ? nuevo.idExcursion : null,
    });
    ref.invalidateSelf();
  }

  Future<void> eliminar(Solicitud solicitud) async {
    await ref.read(requestApiProvider).delete(solicitud.id);
    ref.invalidateSelf();
  }

  Future<void> aceptar(Solicitud solicitud) async {
    await ref.read(requestApiProvider).accept(solicitud.id, expertId: solicitud.idExperto);
    ref.invalidateSelf();
  }

  Future<void> rechazar(Solicitud solicitud) async {
    await ref.read(requestApiProvider).reject(solicitud.id);
    ref.invalidateSelf();
  }
}
