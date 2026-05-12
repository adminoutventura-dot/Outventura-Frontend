import 'activity_category.dart';

// Estados posibles de un material.
enum EstadoEquipamiento {
  disponible,
  agotado,
  mantenimiento,
  fueraDeServicio;

  // Devuelve el nombre legible del estado.
  String get code {
    switch (this) {
      case EstadoEquipamiento.disponible:
        return 'disponible';
      case EstadoEquipamiento.agotado:
        return 'agotado';
      case EstadoEquipamiento.mantenimiento:
        return 'mantenimiento';
      case EstadoEquipamiento.fueraDeServicio:
        return 'fueraDeServicio';
    }
  }

  // Crea un estado a partir del valor en texto que devuelve el backend.
  static EstadoEquipamiento fromString(String value) {
    for (EstadoEquipamiento status in EstadoEquipamiento.values) {
      if (status.code == value) {
        return status;
      }
    }
    return EstadoEquipamiento.disponible;
  }
}

// Entidad de material.
class Equipamiento {
  final int id;
  final String title;
  final String? description;
  final List<CategoriaActividad> categories;
  final int units;
  // TODO: `totalUnits`, `damageFee` e `imageAsset` son solo del front.
  final int totalUnits;
  final EstadoEquipamiento status;
  final double pricePerDay;
  final double damageFee;
  final String? imageAsset;

  const Equipamiento({
    required this.id,
    required this.title,
    this.description,
    required this.categories,
    required this.units,
    required this.totalUnits,
    required this.status,
    required this.pricePerDay,
    required this.damageFee,
    this.imageAsset,
  });

  // Crea un Material a partir del JSON que devuelve el backend.
  factory Equipamiento.fromMap(Map<String, dynamic> map) {
    // Guarda el valor de 'categories' sin importar su formato.
    final dynamic categoriesRaw = map['categories'];

    // Comprueba si el campo 'categories' es una lista, y si lo es, mapea cada elemento a CategoriaActividad.
    final List<CategoriaActividad> parsedCategories = (categoriesRaw is List)
        ? categoriesRaw
            .map((dynamic e) => CategoriaActividad.fromDynamic(e))
            .whereType<CategoriaActividad>()
            .toList()
        : <CategoriaActividad>[];

    // Guarda el valor de 'status' sin importar su formato.
    final dynamic statusRaw = map['status'];
    // Comprueba si el campo 'status' es un String o un Map, y si es un Map, extrae el 'code'.
    final String? statusValue = statusRaw is String
        ? statusRaw
        : (statusRaw is Map<String, dynamic> ? statusRaw['code'] as String? : null);

    // Guarda el valor de 'units' del backend.
    final int units = (map['units'] ?? 0) as int;

    return Equipamiento(
      id: (map['id_equipment'] ?? map['id']) as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      categories: parsedCategories,
      units: units,
      totalUnits: (map['stockTotal'] as int?) ?? units,
      status: EstadoEquipamiento.fromString(statusValue ?? 'disponible'),
      pricePerDay: (map['price_per_day'] as num?)?.toDouble() ?? 0,
      damageFee: (map['damageFee'] as num?)?.toDouble() ?? 0,
      imageAsset: map['imageAsset'] as String?,
    );
  }

  // Crea un nuevo material a partir del actual, permitiendo modificar algunos campos.
  Equipamiento copyWith({
    String? title,
    String? description,
    List<CategoriaActividad>? categories,
    int? units,
    int? totalUnits,
    EstadoEquipamiento? status,
    double? pricePerDay,
    double? damageFee,
    String? imageAsset,
  }) {
    return Equipamiento(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      units: units ?? this.units,
      totalUnits: totalUnits ?? this.totalUnits,
      status: status ?? this.status,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      damageFee: damageFee ?? this.damageFee,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
