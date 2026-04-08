// Categorías de actividad disponibles en Outventura.
enum CategoriaActividad {
  acuatica,
  nieve,
  montania,
  acampada;

  // Devuelve el nombre legible de la categoría.
  String get nombre {
    switch (this) {
      case CategoriaActividad.acuatica:
        return 'Acuática';
      case CategoriaActividad.nieve:
        return 'Nieve';
      case CategoriaActividad.montania:
        return 'Montaña';
      case CategoriaActividad.acampada:
        return 'Acampada';
    }
  }

  // Crea una categoría a partir del valor en texto que devuelve el backend.
  static CategoriaActividad fromString(String value) {
    for (var categoria in CategoriaActividad.values) {
      if (categoria.name == value.toLowerCase()) {
        return categoria;
      }
    }
    return CategoriaActividad.montania;
  }
}
