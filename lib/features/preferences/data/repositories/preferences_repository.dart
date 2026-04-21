import 'package:outventura/features/preferences/data/models/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasRepositorio {
  // Clave para almacenar idioma.
  static const String _keyIdioma = 'idioma';
  // Clave para almacenar tema oscuro.
  static const String _keyTemaOscuro = 'temaOscuro';

  // Devuelve las preferencias actuales desde SharedPreferences.
  Future<Preferencias> obtenerPreferencias() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idioma = prefs.getString(_keyIdioma) ?? 'es';
    final bool temaOscuro = prefs.getBool(_keyTemaOscuro) ?? false;
    return Preferencias(idioma: idioma, temaOscuro: temaOscuro);
  }

  // Guarda todas las preferencias en SharedPreferences.
  Future<void> guardarPreferencias(Preferencias preferences) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIdioma, preferences.idioma);
    await prefs.setBool(_keyTemaOscuro, preferences.temaOscuro);
  }
}
