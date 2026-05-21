// Estados posibles de una reserva.
// TODO: REVISAR EL TIPO DE DATOS QUE MANDA DEL BACK AL FRONT PARA QUE NO HAGA FALTA PARSEARLO
// TODO: El cliente no se le pasa automaticamente al crear ua solicitu siendo clietne.
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
      equipmentId: map['equipmentId'] as int,
      quantity: num.parse(map['quantity'].toString()).toInt(),
      priceAtMoment: map['price_at_moment'] != null ? num.parse(map['price_at_moment'].toString()).toDouble() : 0,
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
  final int? id;
  final int userId;
  final List<BookingLine> lines;
  final int? activityId;
  final BookingStatus status;
  final double totalPrice;
  final double damageFee;
  final Map<int, int> damagedItems;

  const Booking({
    this.id,
    required this.userId,
    required this.lines,
    this.activityId,
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

    // El backend devuelve status siempre como string (enum de PostgreSQL).
    final String statusCode = map['status'] as String? ?? '';

    // El backend devuelve siempre user: { id_user, name, email }
    final int userId = (map['user'] as Map<String, dynamic>)['id_user'] as int;

    // damaged_items llega como [{ equipmentId, quantity }] desde el backend.
    final rawDamaged = map['damaged_items'] as List<dynamic>? ?? [];
    final Map<int, int> damagedItems = {
      for (final e in rawDamaged)
        num.parse(e['equipmentId'].toString()).toInt(): num.parse(e['quantity'].toString()).toInt(),
    };

    return Booking(
      id: map['id_booking'] as int?,
      userId: userId,
      lines: lines,
      activityId: activityId,
      status: BookingStatus.fromString(statusCode),
      totalPrice: map['total_price'] != null ? num.parse(map['total_price'].toString()).toDouble() : 0,
      damageFee: map['damage_fee'] != null ? num.parse(map['damage_fee'].toString()).toDouble() : 0,
      damagedItems: damagedItems,
    );
  }

  // Convierte la reserva a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'status': status.code,
    'lines': lines.map((l) => l.toMap()).toList(),
    if (activityId != null) 'activityId': activityId,
    'damage_fee': damageFee,
    'damagedItems': damagedItems.entries
        .map((e) => {'equipmentId': e.key, 'quantity': e.value})
        .toList(),
  };

  // Crea una copia de la reserva con algunos campos modificados (inmutable).
  // INMUTABLE: en vez de modificar la instancia actual, se crea una nueva con los cambios deseados.
  Booking copyWith({
    int? userId,
    List<BookingLine>? lines,
    int? activityId,
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
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      damageFee: damageFee ?? this.damageFee,
      damagedItems: damagedItems ?? this.damagedItems,
    );
  }
}

