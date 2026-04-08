import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

class Preferences {
  final String idioma;
  final bool temaOscuro;

  const Preferences({
    required this.idioma,
    required this.temaOscuro,
  });

  // Crea una copia modificada de las preferencias.
  Preferences copyWith({
    List<CategoriaActividad>? categoriasFavoritas,
    String? idioma,
    bool? temaOscuro,
  }) =>
      Preferences(
        idioma: idioma ?? this.idioma,
        temaOscuro: temaOscuro ?? this.temaOscuro,
      );
}
