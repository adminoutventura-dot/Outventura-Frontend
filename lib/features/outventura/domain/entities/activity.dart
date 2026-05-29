import 'package:outventura/features/outventura/domain/entities/category.dart';

// Entidad de actividad.
class Activity {
  final int? id;
  final String title;
  final String? description;
  final DateTime initDate;
  final DateTime endDate;
  final int difficulty;
  final int maxParticipants;
  final String? startEndPoint;
  final List<Category> categories;
  final String? imageAsset;
  final List<int> recommendedEquipmentIds;
  final int? guideId; // Lo necesitamos para saber a qué guía asignarlo

  const Activity({
    this.id,
    required this.title,
    this.description,
    required this.initDate,
    required this.endDate,
    required this.difficulty,
    required this.maxParticipants,
    this.startEndPoint,
    required this.categories,
    this.imageAsset,
    this.recommendedEquipmentIds = const [],
    this.guideId,
  });

  // Convierte la actividad a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'init_date': initDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'difficulty': difficulty,
    'max_participants': maxParticipants,
    if (startEndPoint != null) 'start_end_point': startEndPoint,
    if (imageAsset != null) 'image_asset': imageAsset,
    'categoryCodes': categories.map((Category c) => c.code).toList(),
    'recommendedEquipmentIds': recommendedEquipmentIds,
    if (guideId != null) 'guideId': guideId,
  };

  // Crea una nueva actividad a partir de la actual, permitiendo modificar algunos campos.
  Activity copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? initDate,
    DateTime? endDate,
    int? difficulty,
    int? maxParticipants,
    String? startEndPoint,
    List<Category>? categories,
    String? imageAsset,
    List<int>? recommendedEquipmentIds,
    int? guideId,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      initDate: initDate ?? this.initDate,
      endDate: endDate ?? this.endDate,
      difficulty: difficulty ?? this.difficulty,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      startEndPoint: startEndPoint ?? this.startEndPoint,
      categories: categories ?? this.categories,
      imageAsset: imageAsset ?? this.imageAsset,
      recommendedEquipmentIds: recommendedEquipmentIds ?? this.recommendedEquipmentIds,
      guideId: guideId ?? this.guideId,
    );
  }
}