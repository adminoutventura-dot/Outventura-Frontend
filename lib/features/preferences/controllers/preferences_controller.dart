import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/preferences/data/models/preferences.dart';
import 'package:outventura/features/preferences/data/repositories/preferences_repository.dart';

final preferencesProvider =
    AsyncNotifierProvider<PreferencesNotifier, Preferences>(() {
  return PreferencesNotifier();
});

// Gestiona las preferencias de la aplicación.
class PreferencesNotifier extends AsyncNotifier<Preferences> {
  late final PreferencesRepository _repo;

  @override
  Future<Preferences> build() async {
    _repo = PreferencesRepository();
    return await _repo.getPreferences();
  }

  // Actualiza todas las preferencias de una vez.
  Future<void> updatePreferences(Preferences newPreferences) async {
    await _repo.setPreferences(newPreferences);
    state = AsyncValue.data(newPreferences);
  }
}
