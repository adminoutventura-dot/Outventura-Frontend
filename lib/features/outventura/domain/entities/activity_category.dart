// Categorías de actividad disponibles en Outventura.
enum CategoriaActividad {
  acuatico,
  nieve,
  montana,
  camping;

  // Devuelve el nombre legible de la categoría.
  String get label {
    switch (this) {
      case CategoriaActividad.acuatico:
        return 'Acuático';
      case CategoriaActividad.nieve:
        return 'Nieve';
      case CategoriaActividad.montana:
        return 'Montaña';
      case CategoriaActividad.camping:
        return 'Camping';
    }
  }

  // Crea una categoría a partir del valor en texto que devuelve el backend.
  static CategoriaActividad fromString(String value) {
    for (CategoriaActividad category in CategoriaActividad.values) {
      if (category.label.toLowerCase() == value.toLowerCase()) {
        return category;
      }
    }
    return CategoriaActividad.montana;
  }
}
