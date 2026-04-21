import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/preferences/data/models/preferences.dart';
import 'package:outventura/features/preferences/data/repositories/preferences_repository.dart';

final AsyncNotifierProvider<PreferenciasNotifier, Preferencias> preferenciasProvider =
    AsyncNotifierProvider<PreferenciasNotifier, Preferencias>(() {
  return PreferenciasNotifier();
});

// Gestiona las preferencias de la aplicación.
class PreferenciasNotifier extends AsyncNotifier<Preferencias> {
  late final PreferenciasRepositorio _repo;

  @override
  Future<Preferencias> build() async {
    _repo = PreferenciasRepositorio();
    return await _repo.obtenerPreferencias();
  }

  // Actualiza todas las preferencias de una vez.
  Future<void> actualizarPreferencias(Preferencias newPreferences) async {
    await _repo.guardarPreferencias(newPreferences);
    state = AsyncValue<Preferencias>.data(newPreferences);
  }
}
