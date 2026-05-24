import 'package:outventura/features/outventura/data/models/category_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

/// Modelo de equipamiento: extiende [Equipment] añadiendo la deserialización desde JSON del backend.
class EquipmentModel extends Equipment {
  const EquipmentModel({
    super.id,
    required super.title,
    super.description,
    required super.categories,
    required super.units,
    required super.totalUnits,
    required super.status,
    required super.pricePerDay,
    required super.damageFee,
    super.imageAsset,
  });

  factory EquipmentModel.fromMap(Map<String, dynamic> map) {
    final List<Category> parsedCategories = (map['categories'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromMap)
        .toList();

    final String? statusValue = map['status'] as String?;
    final int units = num.parse((map['units'] ?? 0).toString()).toInt();

    return EquipmentModel(
      id: map['id_equipment'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      categories: parsedCategories,
      units: units,
      totalUnits: num.parse((map['total_units'] ?? map['units'] ?? 0).toString()).toInt(),
      status: EquipmentStatus.fromString(statusValue ?? 'AVAILABLE'),
      pricePerDay: map['price_per_day'] != null
          ? num.parse(map['price_per_day'].toString()).toDouble()
          : 0,
      damageFee: map['damage_fee'] != null
          ? num.parse(map['damage_fee'].toString()).toDouble()
          : 0,
      imageAsset: map['imageAsset'] as String?,
    );
  }
}
