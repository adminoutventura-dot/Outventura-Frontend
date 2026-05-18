// Categorías de actividad disponibles en Outventura.
enum Category {
  acuatico,
  nieve,
  montana,
  camping;

  String get code {
    switch (this) {
      case Category.acuatico:
        return 'ACUATICO';
      case Category.nieve:
        return 'NIEVE';
      case Category.montana:
        return 'MONTANA';
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

  // Devuelve una categoría a partir de un valor dinámico que puede ser un String o un Map con un campo 'code'.
  static Category? fromDynamic(dynamic value) {
    if (value is String) {
      return fromString(value);
    }
    if (value is Map<String, dynamic>) {
      final String? code = value['code'] as String?;
      if (code != null) {
        return fromString(code);
      }
    }
    return null;
  }
}
