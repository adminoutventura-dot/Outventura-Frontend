// Categorías de actividad disponibles en Outventura.
enum Category {
  acuatico,
  nieve,
  montana,
  camping;

  String get code {
    switch (this) {
      case Category.acuatico:
        return 'AQUATIC';
      case Category.nieve:
        return 'SNOW';
      case Category.montana:
        return 'MOUNTAIN';
      case Category.camping:
        return 'CAMPING';
    }
  }

  // Crea una categoría a partir del valor en texto que devuelve el backend.
  static Category fromString(String value) {
    for (Category category in Category.values) {
      if (category.code == value) {
        return category;
      }
    }
    return Category.montana;
  }

  // Crea una categoría a partir del objeto que devuelve el backend: { id_category, code, description }.
  static Category? fromDynamic(dynamic value) {
    // Extrae el campo 'code' del objeto y lo convierte a String.
    final String? code = (value as Map<String, dynamic>)['code'] as String?;
    if (code != null) {
      return fromString(code);
    } else {
      return null;
    }
  }
}
