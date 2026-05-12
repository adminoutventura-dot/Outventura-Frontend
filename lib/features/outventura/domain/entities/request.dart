// Estados posibles de una solicitud.
enum EstadoSolicitud {
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada;

  String get label {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return 'Pendiente';
      case EstadoSolicitud.confirmada:
        return 'Confirmada';
      case EstadoSolicitud.enCurso:
        return 'En curso';
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

// TODO: El backend no tiene modelo de Solicitud; alinear campos cuando exista.
// Entidad de solicitud.
class Solicitud {
  final int id;
  final int idExcursion;
  final int numeroParticipantes;
  final EstadoSolicitud estado;
  final int? idExperto;
  final int? idUsuario;
  final int? idReserva;
  // Materiales solicitados finales: {idEquipamiento: cantidad}.
  final Map<int, int> materialesSolicitados;
  // Precio total calculado (excursión + materiales).
  final double precioTotal;

  const Solicitud({
    required this.id,
    required this.idExcursion,
    required this.numeroParticipantes,
    required this.estado,
    this.idExperto,
    this.idUsuario,
    this.idReserva,
    this.materialesSolicitados = const {},
    this.precioTotal = 0,
  });

  // Crea una Solicitud a partir del JSON que devuelve el backend.
  factory Solicitud.fromMap(Map<String, dynamic> map) {
    return Solicitud(
      id: map['id'] as int,
      idExcursion: map['excursionId'] as int,
      numeroParticipantes: map['participantCount'] as int,
      estado: EstadoSolicitud.fromString(map['status'] as String),
      idExperto: map['expertId'] as int?,
      idUsuario: map['userId'] as int?,
      idReserva: map['reservationId'] as int?,
      materialesSolicitados:
          // El backend devuelve los materiales solicitados como un mapa de strings a números, por ejemplo: {"1": 2, "3": 5}.
          (map['requestedMaterials'] as Map<String, dynamic>?)?.map(
            (String key, dynamic value) =>
                MapEntry(int.parse(key), (value as num).toInt()),
          ) ??
          const {},
      precioTotal: (map['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  // Crea una nueva solicitud a partir de la actual, permitiendo modificar algunos campos.
  Solicitud copyWith({
    int? idExcursion,
    int? numeroParticipantes,
    EstadoSolicitud? estado,
    int? idExperto,
    int? idUsuario,
    int? idReserva,
    Map<int, int>? materialesSolicitados,
    double? precioTotal,
  }) {
    return Solicitud(
      id: id,
      idExcursion: idExcursion ?? this.idExcursion,
      numeroParticipantes: numeroParticipantes ?? this.numeroParticipantes,
      estado: estado ?? this.estado,
      idExperto: idExperto ?? this.idExperto,
      idUsuario: idUsuario ?? this.idUsuario,
      idReserva: idReserva ?? this.idReserva,
      materialesSolicitados:
          materialesSolicitados ?? this.materialesSolicitados,
      precioTotal: precioTotal ?? this.precioTotal,
    );
  }
}
