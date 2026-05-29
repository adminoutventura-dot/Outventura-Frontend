import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

/// Modelo de línea de reserva: extiende [BookingLine] añadiendo la deserialización desde JSON.
class BookingLineModel extends BookingLine {
  const BookingLineModel({
    super.equipmentId,
    super.activityId,
    required super.quantity,
    super.priceAtMoment,
  });

  factory BookingLineModel.fromMap(Map<String, dynamic> map) {
    return BookingLineModel(
      equipmentId: map['equipmentId'] as int?,
      activityId: map['activityId'] as int?,
      quantity: map['quantity'] as int? ?? 0,
      priceAtMoment: (map['price_at_moment'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Modelo de reserva: extiende [Booking] añadiendo la deserialización desde JSON del backend.
class BookingModel extends Booking {
  const BookingModel({
    super.id,
    required super.userId,
    required super.lines,
    required super.status,
    required super.startDate,
    required super.endDate,
    super.totalPrice,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final linesRaw = map['lines'] as List? ?? [];
    final lines = linesRaw
        .map((e) => BookingLineModel.fromMap(e as Map<String, dynamic>))
        .toList();

    // El estado viene como un objeto anidado en el nuevo backend
    String statusCode = 'PENDING';
    if (map['status'] != null) {
      if (map['status'] is Map) {
        statusCode = map['status']['code'] as String? ?? 'PENDING';
      } else if (map['status'] is String) {
        statusCode = map['status'] as String;
      }
    }

    // Extrae el userId (puede venir directo o anidado en el objeto user dependiendo del include de Prisma)
    final int userId =
        map['userId'] as int? ?? (map['user']?['id_user'] as int? ?? 0);

    // Extrae las fechas (usando los nuevos nombres de Prisma)
    final String? startDateRaw = map['init_date'] as String?;
    final String? endDateRaw = map['end_date'] as String?;

    final DateTime parsedStartDate = startDateRaw != null
        ? DateTime.parse(startDateRaw)
        : DateTime.now();
    final DateTime parsedEndDate = endDateRaw != null
        ? DateTime.parse(endDateRaw)
        : DateTime.now();

    return BookingModel(
      id: map['id_booking'] as int?,
      userId: userId,
      lines: lines,
      status: WorkflowStatus.fromCode(statusCode),
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
    );
  }
}
