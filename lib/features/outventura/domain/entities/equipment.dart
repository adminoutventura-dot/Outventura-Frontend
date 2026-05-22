import 'activity_category.dart';

// Estados posibles de un material.
enum EquipmentStatus {
  disponible,
  agotado,
  mantenimiento,
  fueraDeServicio;

  // Devuelve el nombre legible del estado.
  String get code {
    switch (this) {
      case EquipmentStatus.disponible:
        return 'AVAILABLE';
      case EquipmentStatus.agotado:
        return 'OUT_OF_STOCK';
      case EquipmentStatus.mantenimiento:
        return 'MAINTENANCE';
      case EquipmentStatus.fueraDeServicio:
        return 'OUT_OF_SERVICE';
    }
  }

  // Crea un estado a partir del valor en texto que devuelve el backend.
  static EquipmentStatus fromString(String value) {
    for (EquipmentStatus status in EquipmentStatus.values) {
      if (status.code == value) {
        return status;
      }
    }
    return EquipmentStatus.disponible;
  }
}

// Entidad de material.
class Equipment {
  final int? id;
  final String title;
  final String? description;
  final List<Category> categories;
  final int units;
  final int totalUnits;
  final EquipmentStatus status;
  final double pricePerDay;
  final double damageFee;
  final String? imageAsset;

  const Equipment({
    this.id,
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
  factory Equipment.fromMap(Map<String, dynamic> map) {
    // El backend devuelve categories como array de objetos: [{ id_category, code, description }].
    final List<Category> parsedCategories = (map['categories'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(Category.fromMap)
        .toList();

    // El backend envía el estado como string del enum (ej. 'AVAILABLE').
    final String? statusValue = map['status'] as String?;

    // El número de unidades totales coincide con el campo `units` del backend.
    final int units = num.parse((map['units'] ?? 0).toString()).toInt();

    return Equipment(
      id: map['id_equipment'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      categories: parsedCategories,
      units: units,
      totalUnits: num.parse((map['total_units'] ?? map['units'] ?? 0).toString()).toInt(),
      status: EquipmentStatus.fromString(statusValue ?? 'AVAILABLE'),
      pricePerDay: map['price_per_day'] != null ? num.parse(map['price_per_day'].toString()).toDouble() : 0,
      damageFee: map['damage_fee'] != null ? num.parse(map['damage_fee'].toString()).toDouble() : 0,
      imageAsset: map['imageAsset'] as String?,
    );
  }

  // Convierte el material a un mapa para enviar al backend.
  // Los campos solo del front (totalUnits, imageAsset) se omiten.
  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'units': units,
    'total_units': totalUnits,
    'price_per_day': pricePerDay,
    'damage_fee': damageFee,
    'status': status.code,
    'categoryCodes': categories.map((Category c) => c.code).toList(),
  };

  // Crea un nuevo material a partir del actual, permitiendo modificar algunos campos.
  Equipment copyWith({
    String? title,
    String? description,
    List<Category>? categories,
    int? units,
    int? totalUnits,
    EquipmentStatus? status,
    double? pricePerDay,
    double? damageFee,
    String? imageAsset,
  }) {
    return Equipment(
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
