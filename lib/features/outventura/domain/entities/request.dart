import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Estados posibles de una solicitud.
enum EstadoSolicitud {
  pendiente,
  confirmada,
  finalizada;

  String get nombre {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return 'Pendiente';
      case EstadoSolicitud.confirmada:
        return 'Confirmada';
      case EstadoSolicitud.finalizada:
        return 'Finalizada';
    }
  }

  static EstadoSolicitud fromString(String value) {
    for (var estado in EstadoSolicitud.values) {
      if (estado.nombre.toLowerCase() == value.toLowerCase()) {
        return estado;
      }
    }
    return EstadoSolicitud.pendiente;
  }
}

// Entidad que representa una solicitud gestionada por Outventura.
class Solicitud {
  final int id;
  final String puntoInicio;
  final String puntoFin;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<CategoriaActividad> categorias;
  final int numeroParticipantes;
  final String? descripcion;
  final EstadoSolicitud estado;
  final int? idExperto;

  const Solicitud({
    required this.id,
    required this.puntoInicio,
    required this.puntoFin,
    required this.fechaInicio,
    required this.fechaFin,
    required this.categorias,
    required this.numeroParticipantes,
    this.descripcion,
    required this.estado,
    this.idExperto,
  });

  // Crea una Solicitud a partir del JSON que devuelve el backend.
  factory Solicitud.fromMap(Map<String, dynamic> map) {
    return Solicitud(
      id: map['id'] as int,
      puntoInicio: map['puntoInicio'] as String,
      puntoFin: map['puntoFin'] as String,
      fechaInicio: DateTime.parse(map['fechaInicio'] as String),
      fechaFin: DateTime.parse(map['fechaFin'] as String),
      categorias: (map['categorias'] as List<dynamic>)
          .map((e) => CategoriaActividad.fromString(e as String))
          .toList(),
      numeroParticipantes: map['numeroParticipantes'] as int,
      descripcion: map['descripcion'] as String?,
      estado: EstadoSolicitud.fromString(map['estado'] as String),
      idExperto: map['idExperto'] as int?,
    );
  }

  // Crea una nueva solicitud a partir de la actual, permitiendo modificar algunos campos.
  Solicitud copyWith({
    String? puntoInicio,
    String? puntoFin,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<CategoriaActividad>? categorias,
    int? numeroParticipantes,
    String? descripcion,
    EstadoSolicitud? estado,
    int? idExperto,
  }) {
    return Solicitud(
      id: id,
      puntoInicio: puntoInicio ?? this.puntoInicio,
      puntoFin: puntoFin ?? this.puntoFin,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      categorias: categorias ?? this.categorias,
      numeroParticipantes: numeroParticipantes ?? this.numeroParticipantes,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      idExperto: idExperto ?? this.idExperto,
    );
  }
}
