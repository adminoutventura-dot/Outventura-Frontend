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
    switch (value.toUpperCase()) {
      case 'PENDING':
        return EstadoSolicitud.pendiente;
      case 'CONFIRMED':
        return EstadoSolicitud.confirmada;
      case 'IN_PROGRESS':
        return EstadoSolicitud.enCurso;
      case 'FINISHED':
        return EstadoSolicitud.finalizada;
      case 'CANCELLED':
        return EstadoSolicitud.cancelada;
    }
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
      id: (map['idRequest'] ?? map['id']) as int,
      // excursionId es opcional en el backend; puede ser null si la solicitud es una ruta personalizada
      idExcursion: (map['excursionId'] as int?) ?? 0,
      numeroParticipantes: (map['participantCount'] ?? 1) as int,
      estado: EstadoSolicitud.fromString(map['status'] as String? ?? 'PENDING'),
      idExperto: map['expertId'] as int?,
      idUsuario: map['userId'] as int?,
      idReserva: map['reservationId'] as int?,
      materialesSolicitados: const {},
      precioTotal: 0,
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
