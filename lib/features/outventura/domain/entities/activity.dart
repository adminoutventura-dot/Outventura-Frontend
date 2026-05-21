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
  final int? guideId;
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
    this.guideId,
    this.imageAsset,
    this.status = ActivityStatus.disponible,
    this.price = 0,
    this.materialsPerParticipant = const {},
  });

  // Crea una Activity a partir del JSON que devuelve el backend.
  factory Activity.fromMap(Map<String, dynamic> map) {
    // El backend devuelve categories como array de objetos completos.
    final List<Category> parsedCategories = (map['categories'] as List<dynamic>)
        // mapea cada elemento a Category usando fromDynamic, que maneja tanto String como Map.
        .map((e) => Category.fromDynamic(e))
        .whereType<Category>()
        .toList();

    return Activity(
      id: map['id_activity'] as int?,
      description: map['description'] as String?,
      initDate: DateTime.parse(map['init_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      difficulty: (map['difficulty'] as num).toInt(),
      maxParticipants: (map['max_participants'] as num).toInt(),
      startPoint: map['start_point'] as String? ?? '',
      endPoint: map['end_point'] as String? ?? '',
      categories: parsedCategories,
      guideId: map['guideId'] as int?,
      imageAsset: map['image_asset'] as String?,
      status: map['status'] != null
          ? ActivityStatus.fromString(map['status'] as String)
          : ActivityStatus.disponible,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      // El backend devuelve [{ equipmentId, quantity }], lo convierte a Map<equipmentId, quantity>.
      materialsPerParticipant: {
        for (final e in (map['materialRequirements'] as List<dynamic>? ?? []))
          (e['equipmentId'] as int): (e['quantity'] as int),
      },
    );
  }

  // Convierte la actividad a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'description': description,
    'init_date': initDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'difficulty': difficulty,
    'max_participants': maxParticipants,
    'start_point': startPoint,
    'end_point': endPoint,
    'image_asset': imageAsset,
    'guideId': guideId,
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
    int? guideId,
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
      guideId: guideId ?? this.guideId,
      imageAsset: imageAsset ?? this.imageAsset,
      status: status ?? this.status,
      price: price ?? this.price,
      materialsPerParticipant: materialsPerParticipant ?? this.materialsPerParticipant,
    );
  }

}
