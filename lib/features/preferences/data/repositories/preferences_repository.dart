import 'package:outventura/features/preferences/data/models/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  // Clave para almacenar idioma.
  static const String _keyIdioma = 'idioma';
  // Clave para almacenar tema oscuro.
  static const String _keyTemaOscuro = 'temaOscuro';

  // Devuelve las preferencias actuales desde SharedPreferences.
  Future<Preferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final idioma = prefs.getString(_keyIdioma) ?? 'es';
    final temaOscuro = prefs.getBool(_keyTemaOscuro) ?? false;
    return Preferences(idioma: idioma, temaOscuro: temaOscuro);
  }

  // Guarda todas las preferencias en SharedPreferences.
  Future<void> setPreferences(Preferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdioma, preferences.idioma);
    await prefs.setBool(_keyTemaOscuro, preferences.temaOscuro);
  }
}
