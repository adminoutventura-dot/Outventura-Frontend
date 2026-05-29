import 'category.dart';

// Clase para manejar el estado del material que viene de la nueva tabla EquipmentStatus
class EquipmentStatus {
  final int id;
  final String code;
  final String? description;

  const EquipmentStatus({
    required this.id,
    required this.code,
    this.description,
  });

  // Parsea el objeto status que vendrá anidado desde el backend
  factory EquipmentStatus.fromMap(Map<String, dynamic> map) {
    return EquipmentStatus(
      id: map['id_status'] as int? ?? 1,
      code: map['code'] as String? ?? 'AVAILABLE',
      description: map['description'] as String?,
    );
  }
}

// Entidad de material.
class Equipment {
  final int? id;
  final String title;
  final String? description;
  final List<Category> categories;
  final int totalUnits;
  final int availableUnits; // El backend nos calculará esto en tiempo real
  final EquipmentStatus? status; // Objeto de estado devuelto por el backend
  final int? statusId; // ID para cuando enviamos un alta/edición al backend
  final double pricePerDay;
  final double damageFee;
  final String? imageAsset;

  const Equipment({
    this.id,
    required this.title,
    this.description,
    required this.categories,
    required this.totalUnits,
    this.availableUnits = 0,
    this.status,
    this.statusId,
    required this.pricePerDay,
    required this.damageFee,
    this.imageAsset,
  });

  // Convierte el material a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'image_asset': imageAsset,
    'total_units': totalUnits,
    'price_per_day': pricePerDay,
    'damage_fee': damageFee,
    'statusId': statusId ?? status?.id ?? 1, // Enviamos el ID
    'categoryCodes': categories.map((Category c) => c.code).toList(),
  };

  // Crea un nuevo material a partir del actual, permitiendo modificar algunos campos.
  Equipment copyWith({
    int? id,
    String? title,
    String? description,
    List<Category>? categories,
    int? totalUnits,
    int? availableUnits,
    EquipmentStatus? status,
    int? statusId,
    double? pricePerDay,
    double? damageFee,
    String? imageAsset,
  }) {
    return Equipment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      totalUnits: totalUnits ?? this.totalUnits,
      availableUnits: availableUnits ?? this.availableUnits,
      status: status ?? this.status,
      statusId: statusId ?? this.statusId,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      damageFee: damageFee ?? this.damageFee,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}