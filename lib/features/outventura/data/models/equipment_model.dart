import 'package:outventura/features/outventura/data/models/category_model.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

class EquipmentModel extends Equipment {
  const EquipmentModel({
    super.id,
    required super.title,
    super.description,
    required super.categories,
    required super.totalUnits,
    super.availableUnits = 0,
    super.status,
    super.statusId,
    required super.pricePerDay,
    required super.damageFee,
    super.imageAsset,
  });

  factory EquipmentModel.fromMap(Map<String, dynamic> map) {
    final List<Category> parsedCategories = (map['categories'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromMap)
        .toList();

    final int total = num.parse((map['total_units'] ?? 0).toString()).toInt();
    
    // Lee las available_units calculadas por el backend. Si no vienen, usael total.
    final int available = map['available_units'] != null 
        ? num.parse(map['available_units'].toString()).toInt() 
        : total;

    EquipmentStatus? parsedStatus;
    if (map['status'] != null) {
      parsedStatus = EquipmentStatus.fromMap(map['status'] as Map<String, dynamic>);
    }

    return EquipmentModel(
      id: map['id_equipment'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      categories: parsedCategories,
      totalUnits: total,
      availableUnits: available,
      status: parsedStatus,
      statusId: map['statusId'] as int? ?? parsedStatus?.id,
      pricePerDay: map['price_per_day'] != null
          ? num.parse(map['price_per_day'].toString()).toDouble()
          : 0,
      damageFee: map['damage_fee'] != null
          ? num.parse(map['damage_fee'].toString()).toDouble()
          : 0,
      imageAsset: map['image_asset'] as String?,
    );
  }
}