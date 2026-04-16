import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Estados posibles de una excursión.
enum EstadoExcursion {
  disponible,
  pendiente,
  confirmada,
  finalizada,
  cancelada;

  String get nombre {
    switch (this) {
      case EstadoExcursion.disponible:
        return 'Disponible';
      case EstadoExcursion.pendiente:
        return 'Pendiente';
      case EstadoExcursion.confirmada:
        return 'Confirmada';
      case EstadoExcursion.finalizada:
        return 'Finalizada';
      case EstadoExcursion.cancelada:
        return 'Cancelada';
    }
  }

  static EstadoExcursion fromString(String value) {
    for (var estado in EstadoExcursion.values) {
      if (estado.nombre.toLowerCase() == value.toLowerCase()) {
        return estado;
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
  final String? imageAsset;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<CategoriaActividad> categorias;
  final int numeroParticipantes;
  final String? descripcion;
  final EstadoExcursion estado;

  const Excursion({
    required this.id,
    required this.puntoInicio,
    required this.puntoFin,
    this.imageAsset,
    required this.fechaInicio,
    required this.fechaFin,
    required this.categorias,
    required this.numeroParticipantes,
    this.descripcion,
    required this.estado,
  });

  // Crea una Excursion a partir del JSON que devuelve el backend.
  factory Excursion.fromMap(Map<String, dynamic> map) {
    return Excursion(
      id: map['id'] as int,
      puntoInicio: map['puntoInicio'] as String,
      puntoFin: map['puntoFin'] as String,
      imageAsset: (map['imageAsset']) as String?,
      fechaInicio: DateTime.parse(map['fechaInicio'] as String),
      fechaFin: DateTime.parse(map['fechaFin'] as String),
      categorias: (map['categorias'] as List<dynamic>)
          .map((e) => CategoriaActividad.fromString(e as String))
          .toList(),
      numeroParticipantes: map['numeroParticipantes'] as int,
      descripcion: map['descripcion'] as String?,
      estado: EstadoExcursion.fromString(map['estado'] as String),
    );
  }

  // Crea una nueva excursión a partir de la actual, permitiendo modificar algunos campos.
  Excursion copyWith({
    String? puntoInicio,
    String? puntoFin,
    String? imageAsset,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<CategoriaActividad>? categorias,
    int? numeroParticipantes,
    String? descripcion,
    EstadoExcursion? estado,
  }) {
    return Excursion(
      id: id,
      puntoInicio: puntoInicio ?? this.puntoInicio,
      puntoFin: puntoFin ?? this.puntoFin,
      imageAsset: imageAsset ?? this.imageAsset,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      categorias: categorias ?? this.categorias,
      numeroParticipantes: numeroParticipantes ?? this.numeroParticipantes,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
    );
  }
}
