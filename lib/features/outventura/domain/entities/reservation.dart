// Estados posibles de una reserva.
enum BookingStatus {
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada;

  String get label {
    switch (this) {
      case BookingStatus.pendiente:
        return 'Pendiente';
      case BookingStatus.confirmada:
        return 'Confirmada';
      case BookingStatus.enCurso:
        return 'En curso';
      case BookingStatus.finalizada:
        return 'Finalizada';
      case BookingStatus.cancelada:
        return 'Cancelada';
    }
  }

  static BookingStatus fromString(String value) {
    for (BookingStatus status in BookingStatus.values) {
      if (status.label.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    return BookingStatus.pendiente;
  }
}

// Una línea de reserva (un material y su cantidad).
class BookingLine {
  final int equipmentId;
  final int quantity;

  const BookingLine({required this.equipmentId, required this.quantity});

  BookingLine copyWith({int? equipmentId, int? quantity}) {
    return BookingLine(
      equipmentId: equipmentId ?? this.equipmentId,
      quantity: quantity ?? this.quantity,
    );
  }
}

// TODO: El backend no tiene modelo de Reserva; alinear campos cuando exista.
// Entidad de reserva.
class Booking {
  final int id;
  final int userId;
  final List<BookingLine> lines;
  final int? activityId;
  final DateTime startDate;
  final DateTime endDate;
  final BookingStatus status;
  final double damageFee;
  // Cantidades dañadas por idEquipamiento: {idEquipamiento: cantidad}.
  final Map<int, int> damagedItems;

  const Booking({
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

  Booking copyWith({
    int? userId,
    List<BookingLine>? lines,
    int? activityId,
    DateTime? startDate,
    DateTime? endDate,
    BookingStatus? status,
    double? damageFee,
    Map<int, int>? damagedItems,
  }) {
    return Booking(
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

