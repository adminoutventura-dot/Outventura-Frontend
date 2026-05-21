// Estados posibles de una reserva.
enum BookingStatus {
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada;

  String get code {
    switch (this) {
      case BookingStatus.pendiente:
        return 'PENDING';
      case BookingStatus.confirmada:
        return 'CONFIRMED';
      case BookingStatus.enCurso:
        return 'IN_PROGRESS';
      case BookingStatus.finalizada:
        return 'FINISHED';
      case BookingStatus.cancelada:
        return 'CANCELLED';
    }
  }

  static BookingStatus fromString(String value) {
    for (BookingStatus status in BookingStatus.values) {
      if (status.code == value) {
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
  final double priceAtMoment;

  const BookingLine({
    required this.equipmentId,
    required this.quantity,
    this.priceAtMoment = 0,
  });

  // Crea una línea de reserva a partir de un mapa (del backend al frontend).
  factory BookingLine.fromMap(Map<String, dynamic> map) {
    return BookingLine(
      equipmentId: (map['equipmentId'] ?? map['id_equipment']) as int,
      quantity: (map['quantity'] as num).toInt(),
      priceAtMoment: (map['price_at_moment'] as num?)?.toDouble() ?? 0,
    );
  }

  // Convierte la línea a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'equipmentId': equipmentId,
    'quantity': quantity,
    'price_at_moment': priceAtMoment,
  };

  BookingLine copyWith({int? equipmentId, int? quantity, double? priceAtMoment}) {
    return BookingLine(
      equipmentId: equipmentId ?? this.equipmentId,
      quantity: quantity ?? this.quantity,
      priceAtMoment: priceAtMoment ?? this.priceAtMoment,
    );
  }
}

// Entidad de reserva.
class Booking {
  final int id;
  final int userId;
  final List<BookingLine> lines;
  final int? activityId;
  final DateTime startDate;
  final DateTime endDate;
  final BookingStatus status;
  final double totalPrice;
  final double damageFee;
  final Map<int, int> damagedItems;

  const Booking({
    required this.id,
    required this.userId,
    required this.lines,
    this.activityId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.totalPrice = 0,
    this.damageFee = 0,
    this.damagedItems = const {},
  });

  // Convierte un JSON (mapa) del backend en una instancia de Booking
  factory Booking.fromMap(Map<String, dynamic> map) {
    final linesRaw = map['lines'] as List? ?? [];
    final lines = linesRaw
        .map((e) => BookingLine.fromMap(e as Map<String, dynamic>))
        .toList();

    // El activityId puede venir directamente o de la primera línea que lo tenga.
    final int? activityId = map['activityId'] as int? ??
        (linesRaw.isNotEmpty
            ? (linesRaw.first as Map<String, dynamic>)['activityId'] as int?
            : null);

    // Las fechas vienen de la actividad vinculada; si no existen, se usa created_at como fallback.
    final DateTime fallback = map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : DateTime.now();
    final DateTime startDate = map['startDate'] != null
        ? DateTime.parse(map['startDate'] as String)
        : fallback;
    final DateTime endDate = map['endDate'] != null
        ? DateTime.parse(map['endDate'] as String)
        : fallback;

    final dynamic statusRaw = map['status'];
    final String statusCode = statusRaw is String
        ? statusRaw
        : (statusRaw is Map<String, dynamic> ? statusRaw['code'] as String? ?? '' : '');

    return Booking(
      id: (map['id_booking'] ?? map['id']) as int,
      userId: (map['userId'] ?? map['id_user']) as int,
      lines: lines,
      activityId: activityId,
      startDate: startDate,
      endDate: endDate,
      status: BookingStatus.fromString(statusCode),
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      damageFee: (map['damage_fee'] as num?)?.toDouble() ?? 0,
      damagedItems: (map['damaged_items'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), (v as num).toInt()),
          ) ??
          {},
    );
  }

  // Convierte la reserva a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'status': status.code,
    'lines': lines.map((l) => l.toMap()).toList(),
    'damage_fee': damageFee,
    'damaged_items': damagedItems.map((k, v) => MapEntry(k.toString(), v)),
  };

  // Crea una copia de la reserva con algunos campos modificados (inmutable).
  // INMUTABLE: en vez de modificar la instancia actual, se crea una nueva con los cambios deseados.
  Booking copyWith({
    int? userId,
    List<BookingLine>? lines,
    int? activityId,
    DateTime? startDate,
    DateTime? endDate,
    BookingStatus? status,
    double? totalPrice,
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
      totalPrice: totalPrice ?? this.totalPrice,
      damageFee: damageFee ?? this.damageFee,
      damagedItems: damagedItems ?? this.damagedItems,
    );
  }
}

