// Estados posibles de una solicitud.
enum RequestStatus {
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada;

  String get label {
    switch (this) {
      case RequestStatus.pendiente:
        return 'Pendiente';
      case RequestStatus.confirmada:
        return 'Confirmada';
      case RequestStatus.enCurso:
        return 'En curso';
      case RequestStatus.finalizada:
        return 'Finalizada';
      case RequestStatus.cancelada:
        return 'Cancelada';
    }
  }

  // Crea un estado a partir del valor en texto que devuelve el backend.
  static RequestStatus fromString(String value) {
    for (RequestStatus status in RequestStatus.values) {
      if (status.label.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    return RequestStatus.pendiente;
  }
}

// TODO: El backend no tiene modelo de Solicitud; alinear campos cuando exista.
// Entidad de solicitud.
class Request {
  final int id;
  final int activityId;
  final int participantCount;
  final RequestStatus status;
  final int? expertId;
  final int? userId;
  final int? reservationId;
  // Materiales solicitados finales: {idEquipamiento: cantidad}.
  final Map<int, int> requestedMaterials;
  // Precio total calculado (excursión + materiales).
  final double totalPrice;

  const Request({
    required this.id,
    required this.activityId,
    required this.participantCount,
    required this.status,
    this.expertId,
    this.userId,
    this.reservationId,
    this.requestedMaterials = const {},
    this.totalPrice = 0,
  });

  // Crea una Solicitud a partir del JSON que devuelve el backend.
  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] as int,
      activityId: map['activityId'] as int,
      participantCount: map['participantCount'] as int,
      status: RequestStatus.fromString(map['status'] as String),
      expertId: map['expertId'] as int?,
      userId: map['userId'] as int?,
      reservationId: map['reservationId'] as int?,
      requestedMaterials:
          // El backend devuelve los materiales solicitados como un mapa de strings a números, por ejemplo: {"1": 2, "3": 5}.
          (map['requestedMaterials'] as Map<String, dynamic>?)?.map(
            (String key, dynamic value) =>
                MapEntry(int.parse(key), (value as num).toInt()),
          ) ??
          const {},
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  // Crea una nueva solicitud a partir de la actual, permitiendo modificar algunos campos.
  Request copyWith({
    int? activityId,
    int? participantCount,
    RequestStatus? status,
    int? expertId,
    int? userId,
    int? reservationId,
    Map<int, int>? requestedMaterials,
    double? totalPrice,
  }) {
    return Request(
      id: id,
      activityId: activityId ?? this.activityId,
      participantCount: participantCount ?? this.participantCount,
      status: status ?? this.status,
      expertId: expertId ?? this.expertId,
      userId: userId ?? this.userId,
      reservationId: reservationId ?? this.reservationId,
      requestedMaterials: requestedMaterials ?? this.requestedMaterials,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
