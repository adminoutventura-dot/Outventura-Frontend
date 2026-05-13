
class Preferencias {
  final String idioma;
  final bool temaOscuro;

  const Preferencias({
    required this.idioma,
    required this.temaOscuro,
  });

  // Crea una copia modificada de las preferencias.
  Preferencias copyWith({
    String? idioma,
    bool? temaOscuro,
  }) =>
      Preferencias(
        idioma: idioma ?? this.idioma,
        temaOscuro: temaOscuro ?? this.temaOscuro,
      );
}
