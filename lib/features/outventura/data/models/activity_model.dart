import 'package:outventura/features/outventura/data/models/category_model.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

/// Modelo de actividad: extiende [Activity] añadiendo la deserialización desde JSON del backend.
class ActivityModel extends Activity {
  const ActivityModel({
    super.id,
    required super.title,
    super.description,
    required super.initDate,
    required super.endDate,
    required super.difficulty,
    required super.maxParticipants,
    super.startEndPoint,
    required super.categories,
    super.imageAsset,
    super.recommendedEquipmentIds,
    super.guideId,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    final List<Category> parsedCategories = (map['categories'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromMap)
        .toList();

    // Extrae de forma segura los IDs de los materiales recomendados
    // Dependiendo de si el backend manda los objetos enteros o solo los IDs.
    final List<int> parsedEquipmentIds = (map['recomendedEquipments'] as List<dynamic>? ?? [])
        .map((e) => e is int ? e : (e['id_equipment'] as int))
        .toList();

    return ActivityModel(
      id: map['id_activity'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      initDate: DateTime.parse(map['init_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      difficulty: map['difficulty'] as int? ?? 0,
      maxParticipants: map['max_participants'] as int? ?? 0,
      startEndPoint: map['start_end_point'] as String?,
      categories: parsedCategories,
      imageAsset: map['image_asset'] as String?,
      recommendedEquipmentIds: parsedEquipmentIds,
      guideId: map['guideId'] as int?,
    );
  }
}