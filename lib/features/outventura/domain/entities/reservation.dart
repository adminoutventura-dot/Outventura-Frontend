import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

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
  final WorkflowStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double damageFee;
  final Map<int, int> damagedItems;

  const Booking({
    this.id,
    required this.userId,
    required this.lines,
    this.activityId,
    required this.status,
    required this.startDate, 
    required this.endDate,
    this.totalPrice = 0,
    this.damageFee = 0,
    this.damagedItems = const {},
  });

  // Convierte la reserva a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'status': status.code,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    // 'total_price': Lo calcula en el backend.
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
    WorkflowStatus? status,
    DateTime? startDate, 
    DateTime? endDate,
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
      startDate: startDate ?? this.startDate, 
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      damageFee: damageFee ?? this.damageFee,
      damagedItems: damagedItems ?? this.damagedItems,
    );
  }
}

