import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

// Una línea de reserva (ahora puede ser un material o una actividad).
class BookingLine {
  final int? id;
  final int? equipmentId;
  final int? activityId;
  final int quantity;
  final double priceAtMoment;

  const BookingLine({
    this.id,
    this.equipmentId,
    this.activityId,
    required this.quantity,
    this.priceAtMoment = 0,
  });

  // Convierte la línea a un mapa para enviar al backend.
  Map<String, dynamic> toMap() => {
    if (equipmentId != null) 'equipmentId': equipmentId,
    if (activityId != null) 'activityId': activityId,
    'quantity': quantity,
    'price_at_moment': priceAtMoment,
  };

  BookingLine copyWith({
    int? id,
    int? equipmentId,
    int? activityId,
    int? quantity,
    double? priceAtMoment,
  }) {
    return BookingLine(
      id: id ?? this.id,
      equipmentId: equipmentId ?? this.equipmentId,
      activityId: activityId ?? this.activityId,
      quantity: quantity ?? this.quantity,
      priceAtMoment: priceAtMoment ?? this.priceAtMoment,
    );
  }
}

// Entidad de reserva (La "cesta").
class Booking {
  final int? id;
  final int userId;
  final String? userName; // Nombre del cliente (viene embebido en la respuesta del backend)
  final String? userEmail; // Email del cliente (viene embebido en la respuesta del backend)
  final List<BookingLine> lines;
  final WorkflowStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  const Booking({
    this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.lines,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.totalPrice = 0,
  });

  // Convierte la reserva a un mapa para enviar al backend.
  Map<String, dynamic> toMap() {
    int getStatusId() {
      switch (status.code) {
        case 'PENDING':
          return 1;
        case 'ACCEPTED':
          return 2;
        case 'IN_PROGRESS':
          return 3;
        case 'FINISHED':
          return 4;
        case 'CANCELLED':
          return 5;
        default:
          return 1;
      }
    }

    return {
      'userId': userId,
      'statusId': getStatusId(), // Envia statusId numérico
      'init_date': startDate
          .toIso8601String(), // init_date en vez de start_date
      'end_date': endDate.toIso8601String(),
      // 'total_price': Lo calcula y asigna el backend.
      'lines': lines.map((l) => l.toMap()).toList(),
    };
  }

  Booking copyWith({
    int? userId,
    String? userName,
    String? userEmail,
    List<BookingLine>? lines,
    WorkflowStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
  }) {
    return Booking(
      id: id ?? id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      lines: lines ?? this.lines,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
