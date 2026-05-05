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
  // Acepta tanto el nombre de enum del backend (AQUATIC, SNOW...) como el label en español.
  static CategoriaActividad fromString(String value) {
    switch (value.toUpperCase()) {
      case 'AQUATIC':
        return CategoriaActividad.acuatico;
      case 'SNOW':
        return CategoriaActividad.nieve;
      case 'MOUNTAIN':
        return CategoriaActividad.montana;
      case 'CAMPING':
        return CategoriaActividad.camping;
    }
    // Fallback: compara con el label legible (compatibilidad con datos antiguos)
    for (CategoriaActividad category in CategoriaActividad.values) {
      if (category.label.toLowerCase() == value.toLowerCase()) {
        return category;
      }
    }
    return CategoriaActividad.montana;
  }

  // Convierte al valor de enum que espera el backend.
  String get backendValue {
    switch (this) {
      case CategoriaActividad.acuatico:
        return 'AQUATIC';
      case CategoriaActividad.nieve:
        return 'SNOW';
      case CategoriaActividad.montana:
        return 'MOUNTAIN';
      case CategoriaActividad.camping:
        return 'CAMPING';
    }
  }
}
