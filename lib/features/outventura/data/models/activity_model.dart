import 'package:outventura/features/outventura/data/models/category_model.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

/// Modelo de actividad: extiende [Activity] añadiendo la deserialización desde JSON del backend.
class ActivityModel extends Activity {
  const ActivityModel({
    super.id,
    super.description,
    required super.initDate,
    required super.endDate,
    required super.difficulty,
    required super.maxParticipants,
    required super.startPoint,
    required super.endPoint,
    required super.categories,
    super.imageAsset,
    super.status,
    super.price,
    super.materialsPerParticipant,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    final List<Category> parsedCategories = (map['categories'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromMap)
        .toList();

    return ActivityModel(
      id: map['id_activity'] as int?,
      description: map['description'] as String?,
      initDate: DateTime.parse(map['init_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      difficulty: map['difficulty'] as int? ?? 0,
      maxParticipants: map['max_participants'] as int? ?? 0,
      startPoint: map['start_point'] as String? ?? '',
      endPoint: map['end_point'] as String? ?? '',
      categories: parsedCategories,
      imageAsset: map['image_asset'] as String?,
      status: map['status'] != null
          ? ActivityStatus.fromString(map['status'] as String)
          : ActivityStatus.disponible,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      materialsPerParticipant: {
        for (final e in (map['materialRequirements'] as List<dynamic>? ?? []))
          (e['equipmentId'] as int): (e['quantity'] as int),
      },
    );
  }
}
