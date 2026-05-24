import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Estados posibles de una actividad.
enum ActivityStatus {
  disponible,
  noDisponible;

  String get code {
    switch (this) {
      case ActivityStatus.disponible:
        return 'AVAILABLE';
      case ActivityStatus.noDisponible:
        return 'NOT_AVAILABLE';
    }
  }

  static ActivityStatus fromString(String value) {
    for (ActivityStatus status in ActivityStatus.values) {
      if (status.code == value) {
        return status;
      }
    }
    return ActivityStatus.disponible;
  }
}

// Entidad de actividad.
class Activity {
  final int? id;
  final String? description;
  final DateTime initDate;
  final DateTime endDate;
  final int difficulty;
  final int maxParticipants;
  final String startPoint;
  final String endPoint;
  final List<Category> categories;
  final String? imageAsset;
  final ActivityStatus status;
  final double price;
  final Map<int, int> materialsPerParticipant;

  const Activity({
    this.id,
    this.description,
    required this.initDate,
    required this.endDate,
    required this.difficulty,
    required this.maxParticipants,
    required this.startPoint,
    required this.endPoint,
    required this.categories,
    this.imageAsset,
    this.status = ActivityStatus.disponible,
    this.price = 0,
    this.materialsPerParticipant = const {},
  });

  // Convierte la actividad a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'description': description,
    'init_date': initDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'difficulty': difficulty,
    'max_participants': maxParticipants,
    'start_point': startPoint,
    'end_point': endPoint,
    if (imageAsset != null) 'image_asset': imageAsset,
    'status': status.code,
    'price': price,
    'categoryCodes': categories.map((Category c) => c.code).toList(),
    'materialRequirements': materialsPerParticipant.entries
        .map((e) => {'equipmentId': e.key, 'quantity': e.value})
        .toList(),
  };

  // Crea una nueva actividad a partir de la actual, permitiendo modificar algunos campos.
  Activity copyWith({
    String? description,
    DateTime? initDate,
    DateTime? endDate,
    int? difficulty,
    int? maxParticipants,
    String? startPoint,
    String? endPoint,
    List<Category>? categories,
    String? imageAsset,
    ActivityStatus? status,
    double? price,
    Map<int, int>? materialsPerParticipant,
  }) {
    return Activity(
      id: id,
      description: description ?? this.description,
      initDate: initDate ?? this.initDate,
      endDate: endDate ?? this.endDate,
      difficulty: difficulty ?? this.difficulty,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      categories: categories ?? this.categories,
      imageAsset: imageAsset ?? this.imageAsset,
      status: status ?? this.status,
      price: price ?? this.price,
      materialsPerParticipant: materialsPerParticipant ?? this.materialsPerParticipant,
    );
  }
}