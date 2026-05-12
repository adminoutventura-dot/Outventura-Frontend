// Categorías de actividad disponibles en Outventura.
enum CategoriaActividad {
  acuatico,
  nieve,
  montana,
  camping;

  String get code {
    switch (this) {
      case CategoriaActividad.acuatico:
        return 'ACUATICO';
      case CategoriaActividad.nieve:
        return 'NIEVE';
      case CategoriaActividad.montana:
        return 'MONTANA';
      case CategoriaActividad.camping:
        return 'CAMPING';
    }
  }

  // Crea una categoría a partir del valor en texto que devuelve el backend.
  static CategoriaActividad fromString(String value) {
    for (CategoriaActividad category in CategoriaActividad.values) {
      if (category.code == value) {
        return category;
      }
    }
    return CategoriaActividad.montana;
  }

  // Devuelve una categoría a partir de un valor dinámico que puede ser un String o un Map con un campo 'code'.
  static CategoriaActividad? fromDynamic(dynamic value) {
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
