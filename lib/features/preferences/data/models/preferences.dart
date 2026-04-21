import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

class Preferencias {
  final String idioma;
  final bool temaOscuro;

  const Preferencias({
    required this.idioma,
    required this.temaOscuro,
  });

  // Crea una copia modificada de las preferencias.
  Preferencias copyWith({
    List<CategoriaActividad>? categoriasFavoritas,
    String? idioma,
    bool? temaOscuro,
  }) =>
      Preferencias(
        idioma: idioma ?? this.idioma,
        temaOscuro: temaOscuro ?? this.temaOscuro,
      );
}
