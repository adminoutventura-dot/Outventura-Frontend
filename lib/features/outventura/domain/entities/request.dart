// Estados posibles de una solicitud.
enum EstadoSolicitud {
  pendiente,
  confirmada,
  finalizada,
  cancelada;

  String get label {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return 'Pendiente';
      case EstadoSolicitud.confirmada:
        return 'Confirmada';
      case EstadoSolicitud.finalizada:
        return 'Finalizada';
      case EstadoSolicitud.cancelada:
        return 'Cancelada';
    }
  }

  // Crea un estado a partir del valor en texto que devuelve el backend.
  static EstadoSolicitud fromString(String value) {
    for (EstadoSolicitud status in EstadoSolicitud.values) {
      if (status.label.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    return EstadoSolicitud.pendiente;
  }
}

// Entidad de solicitud.
class Solicitud {
  final int id;
  final int idExcursion;
  final int numeroParticipantes;
  final EstadoSolicitud estado;
  final int? idExperto;

  const Solicitud({
    required this.id,
    required this.idExcursion,
    required this.numeroParticipantes,
    required this.estado,
    this.idExperto,
  });

  // Crea una Solicitud a partir del JSON que devuelve el backend.
  factory Solicitud.fromMap(Map<String, dynamic> map) {
    return Solicitud(
      id: map['id'] as int,
      idExcursion: map['excursionId'] as int,
      numeroParticipantes: map['participantCount'] as int,
      estado: EstadoSolicitud.fromString(map['status'] as String),
      idExperto: map['expertId'] as int?,
    );
  }

  // Crea una nueva solicitud a partir de la actual, permitiendo modificar algunos campos.
  Solicitud copyWith({
    int? idExcursion,
    int? numeroParticipantes,
    EstadoSolicitud? estado,
    int? idExperto,
  }) {
    return Solicitud(
      id: id,
      idExcursion: idExcursion ?? this.idExcursion,
      numeroParticipantes: numeroParticipantes ?? this.numeroParticipantes,
      estado: estado ?? this.estado,
      idExperto: idExperto ?? this.idExperto,
    );
  }
}
