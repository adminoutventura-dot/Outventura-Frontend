import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/services/excursion_api_service.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

// Expone una lista de excursiones desde el backend.
final AsyncNotifierProvider<ExcursionsNotifier, List<Excursion>> excursionesProvider =
    AsyncNotifierProvider<ExcursionsNotifier, List<Excursion>>(ExcursionsNotifier.new);

// Filtro local — el backend también acepta ?search= en GET /excursions.
final excursionesFiltadasProvider = Provider.family<AsyncValue<List<Excursion>>, String>((ref, query) {
  final AsyncValue<List<Excursion>> asyncTodas = ref.watch(excursionesProvider);
  return asyncTodas.whenData((List<Excursion> todas) {
    if (query.isEmpty) return todas;
    final String q = query.toLowerCase();
    return todas.where((Excursion e) =>
      '${e.puntoInicio} ${e.puntoFin}'.toLowerCase().contains(q)
    ).toList();
  });
});

class ExcursionsNotifier extends AsyncNotifier<List<Excursion>> {
  @override
  Future<List<Excursion>> build() async {
    return ref.read(excursionApiProvider).getAll();
  }

  Future<void> agregar(Excursion excursion) async {
    await ref.read(excursionApiProvider).create({
      'start_point': excursion.puntoInicio,
      'end_point': excursion.puntoFin,
      'start_date': excursion.fechaInicio.toIso8601String(),
      'end_date': excursion.fechaFin.toIso8601String(),
      'categories': excursion.categorias.map((c) => c.backendValue).toList(),
      'participant_count': excursion.numeroParticipantes,
      'description': excursion.descripcion,
      'price': excursion.precio,
      'image_url': excursion.imagenAsset,
    });
    ref.invalidateSelf();
  }

  Future<void> actualizar(Excursion viejo, Excursion nuevo) async {
    await ref.read(excursionApiProvider).update(viejo.id, {
      'start_point': nuevo.puntoInicio,
      'end_point': nuevo.puntoFin,
      'start_date': nuevo.fechaInicio.toIso8601String(),
      'end_date': nuevo.fechaFin.toIso8601String(),
      'categories': nuevo.categorias.map((c) => c.backendValue).toList(),
      'participant_count': nuevo.numeroParticipantes,
      'description': nuevo.descripcion,
      'price': nuevo.precio,
      'image_url': nuevo.imagenAsset,
    });
    ref.invalidateSelf();
  }

  Future<void> eliminar(Excursion excursion) async {
    await ref.read(excursionApiProvider).delete(excursion.id);
    ref.invalidateSelf();
  }
}

