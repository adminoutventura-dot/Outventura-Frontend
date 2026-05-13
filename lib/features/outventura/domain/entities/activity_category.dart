// Categorías de actividad disponibles en Outventura.
enum ActivityCategory {
  acuatico,
  nieve,
  montana,
  camping;

  String get code {
    switch (this) {
      case ActivityCategory.acuatico:
        return 'ACUATICO';
      case ActivityCategory.nieve:
        return 'NIEVE';
      case ActivityCategory.montana:
        return 'MONTANA';
      case ActivityCategory.camping:
        return 'CAMPING';
    }
  }

  // Crea una categoría a partir del valor en texto que devuelve el backend.
  static ActivityCategory fromString(String value) {
    for (ActivityCategory category in ActivityCategory.values) {
      if (category.code == value) {
        return category;
      }
    }
    return ActivityCategory.montana;
  }

  // Devuelve una categoría a partir de un valor dinámico que puede ser un String o un Map con un campo 'code'.
  static ActivityCategory? fromDynamic(dynamic value) {
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
