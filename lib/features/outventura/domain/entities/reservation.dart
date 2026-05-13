// Estados posibles de una reserva.
enum ReservationStatus {
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada;

  String get label {
    switch (this) {
      case ReservationStatus.pendiente:
        return 'Pendiente';
      case ReservationStatus.confirmada:
        return 'Confirmada';
      case ReservationStatus.enCurso:
        return 'En curso';
      case ReservationStatus.finalizada:
        return 'Finalizada';
      case ReservationStatus.cancelada:
        return 'Cancelada';
    }
  }

  static ReservationStatus fromString(String value) {
    for (ReservationStatus status in ReservationStatus.values) {
      if (status.label.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    return ReservationStatus.pendiente;
  }
}

// Una línea de reserva (un material y su cantidad).
class ReservationLine {
  final int equipmentId;
  final int quantity;

  const ReservationLine({required this.equipmentId, required this.quantity});

  ReservationLine copyWith({int? equipmentId, int? quantity}) {
    return ReservationLine(
      equipmentId: equipmentId ?? this.equipmentId,
      quantity: quantity ?? this.quantity,
    );
  }
}

// TODO: El backend no tiene modelo de Reserva; alinear campos cuando exista.
// Entidad de reserva.
class Reservation {
  final int id;
  final int userId;
  final List<ReservationLine> lines;
  final int? activityId;
  final DateTime startDate;
  final DateTime endDate;
  final ReservationStatus status;
  final double damageFee;
  // Cantidades dañadas por idEquipamiento: {idEquipamiento: cantidad}.
  final Map<int, int> damagedItems;

  const Reservation({
    required this.id,
    required this.userId,
    required this.lines,
    this.activityId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.damageFee = 0,
    // equipmentId - damaged quantity.
    this.damagedItems = const {},
  });

  Reservation copyWith({
    int? userId,
    List<ReservationLine>? lines,
    int? activityId,
    DateTime? startDate,
    DateTime? endDate,
    ReservationStatus? status,
    double? damageFee,
    Map<int, int>? damagedItems,
  }) {
    return Reservation(
      id: id,
      userId: userId ?? this.userId,
      lines: lines ?? this.lines,
      activityId: activityId ?? this.activityId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      damageFee: damageFee ?? this.damageFee,
      damagedItems: damagedItems ?? this.damagedItems,
    );
  }
}

