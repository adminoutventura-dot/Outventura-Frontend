import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Estados posibles de una excursión.
enum EstadoExcursion {
  disponible,
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada;

  String get label {
    switch (this) {
      case EstadoExcursion.disponible:
        return 'Disponible';
      case EstadoExcursion.pendiente:
        return 'Pendiente';
      case EstadoExcursion.confirmada:
        return 'Confirmada';
      case EstadoExcursion.enCurso:
        return 'En curso';
      case EstadoExcursion.finalizada:
        return 'Finalizada';
      case EstadoExcursion.cancelada:
        return 'Cancelada';
    }
  }

  static EstadoExcursion fromString(String value) {
    for (EstadoExcursion status in EstadoExcursion.values) {
      if (status.label.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    return EstadoExcursion.disponible;
  }
}

// Entidad de excursión.
class Excursion {
  final int id;
  final String puntoInicio;
  final String puntoFin;
  final String? imagenAsset;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<CategoriaActividad> categorias;
  final int numeroParticipantes;
  final String? descripcion;
  final EstadoExcursion estado;
  // Precio base por participante.
  final double precio;
  // Material recomendado por participante: {idEquipamiento: cantidadPorPersona}.
  final Map<int, int> materialesPorParticipante;

  const Excursion({
    required this.id,
    required this.puntoInicio,
    required this.puntoFin,
    this.imagenAsset,
    required this.fechaInicio,
    required this.fechaFin,
    required this.categorias,
    required this.numeroParticipantes,
    this.descripcion,
    required this.estado,
    this.precio = 0,
    this.materialesPorParticipante = const {},
  });

  // Crea una Excursion a partir del JSON que devuelve el backend.
  factory Excursion.fromMap(Map<String, dynamic> map) {
    return Excursion(
      id: map['id'] as int,
      puntoInicio: map['startPoint'] as String,
      puntoFin: map['endPoint'] as String,
      imagenAsset: (map['imageAsset']) as String?,
      fechaInicio: DateTime.parse(map['startDate'] as String),
      fechaFin: DateTime.parse(map['endDate'] as String),
      categorias: (map['categories'] as List<dynamic>)
          .map((dynamic e) => CategoriaActividad.fromString(e as String))
          .toList(),
      numeroParticipantes: map['participantCount'] as int,
      descripcion: map['description'] as String?,
      estado: EstadoExcursion.fromString(map['status'] as String),
      precio: (map['price'] as num?)?.toDouble() ?? 0,
      materialesPorParticipante:
          (map['materialsPerParticipant'] as Map<String, dynamic>?)?.map(
            (String key, dynamic value) =>
                MapEntry(int.parse(key), (value as num).toInt()),
          ) ??
          const {},
    );
  }

  // Crea una nueva excursión a partir de la actual, permitiendo modificar algunos campos.
  Excursion copyWith({
    String? puntoInicio,
    String? puntoFin,
    String? imagenAsset,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<CategoriaActividad>? categorias,
    int? numeroParticipantes,
    String? descripcion,
    EstadoExcursion? estado,
    double? precio,
    Map<int, int>? materialesPorParticipante,
  }) {
    return Excursion(
      id: id,
      puntoInicio: puntoInicio ?? this.puntoInicio,
      puntoFin: puntoFin ?? this.puntoFin,
      imagenAsset: imagenAsset ?? this.imagenAsset,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      categorias: categorias ?? this.categorias,
      numeroParticipantes: numeroParticipantes ?? this.numeroParticipantes,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      precio: precio ?? this.precio,
      materialesPorParticipante: materialesPorParticipante ?? this.materialesPorParticipante,
    );
  }
}
