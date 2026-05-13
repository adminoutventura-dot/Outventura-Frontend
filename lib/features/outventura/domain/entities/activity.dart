import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// TODO: El backend no define el estado de actividad; alinear cuando exista.
// Estados posibles de una actividad.
enum ActivityStatus {
  disponible,
  noDisponible;

  // Devuelve el nombre legible del estado.
  String get code {
    switch (this) {
      case ActivityStatus.disponible:
        return 'disponible';
      case ActivityStatus.noDisponible:
        return 'noDisponible';
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
  final int id;
  final String title;
  final String? description;
  final DateTime initDate;
  final DateTime endDate;
  final int difficulty;
  final int maxParticipants;
  final String? startEndPoint;
  final List<ActivityCategory> categories;
  // TODO: Campos solo en front: imageAsset, status, price, materialsPerParticipant.
  final String? imageAsset;
  final ActivityStatus status;
  final double price;
  final Map<int, int> materialsPerParticipant;

  const Activity({
    required this.id,
    required this.title,
    this.description,
    required this.initDate,
    required this.endDate,
    required this.difficulty,
    required this.maxParticipants,
    this.startEndPoint,
    required this.categories,
    this.imageAsset,
    this.status = ActivityStatus.disponible,
    this.price = 0,
    this.materialsPerParticipant = const {},
  });

  String get startPoint => _splitStartEnd()[0];
  String get endPoint => _splitStartEnd()[1];

  // Crea una Activity a partir del JSON que devuelve el backend.
  factory Activity.fromMap(Map<String, dynamic> map) {
    final dynamic categoriesRaw = map['categories'];
    final List<ActivityCategory> parsedCategories = (categoriesRaw is List)
        ? categoriesRaw
            .map((dynamic e) => ActivityCategory.fromDynamic(e))
            .whereType<ActivityCategory>()
            .toList()
        : <ActivityCategory>[];

    return Activity(
      id: (map['id_activity'] ?? map['id']) as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      initDate: DateTime.parse(map['init_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      difficulty: (map['difficulty'] as num).toInt(),
      maxParticipants: (map['max_participants'] as num).toInt(),
      startEndPoint: map['start_end_point'] as String?,
      categories: parsedCategories,
      imageAsset: map['imageAsset'] as String?,
      status: map['status'] != null
          ? ActivityStatus.fromString(map['status'] as String)
          : ActivityStatus.disponible,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      materialsPerParticipant:
          (map['materialsPerParticipant'] as Map<String, dynamic>?)?.map(
            (String key, dynamic value) =>
                MapEntry(int.parse(key), (value as num).toInt()),
          ) ??
          const {},
    );
  }

  // Crea una nueva actividad a partir de la actual, permitiendo modificar algunos campos.
  Activity copyWith({
    String? title,
    String? description,
    DateTime? initDate,
    DateTime? endDate,
    int? difficulty,
    int? maxParticipants,
    String? startEndPoint,
    List<ActivityCategory>? categories,
    String? imageAsset,
    ActivityStatus? status,
    double? price,
    Map<int, int>? materialsPerParticipant,
  }) {
    return Activity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      initDate: initDate ?? this.initDate,
      endDate: endDate ?? this.endDate,
      difficulty: difficulty ?? this.difficulty,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      startEndPoint: startEndPoint ?? this.startEndPoint,
      categories: categories ?? this.categories,
      imageAsset: imageAsset ?? this.imageAsset,
      status: status ?? this.status,
      price: price ?? this.price,
      materialsPerParticipant: materialsPerParticipant ?? this.materialsPerParticipant,
    );
  }

  // TODO: El backend debería devolver startPoint y endPoint por separado, pero de mientras extraerlos de startEndPoint con varios formatos posibles.
  // Divide el campo `startEndPoint` en punto de inicio y punto de fin, intentando varios formatos.
  List<String> _splitStartEnd() {
    final String? raw = startEndPoint;
    if (raw == null || raw.trim().isEmpty) {
      return <String>[title, ''];
    }
    final List<String> arrowSplit = raw.split('→');
    if (arrowSplit.length == 2) {
      return <String>[arrowSplit[0].trim(), arrowSplit[1].trim()];
    }
    final List<String> dashSplit = raw.split(' - ');
    if (dashSplit.length == 2) {
      return <String>[dashSplit[0].trim(), dashSplit[1].trim()];
    }
    return <String>[raw.trim(), ''];
  }
}
