import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

/// Modelo de línea de reserva: extiende [BookingLine] añadiendo la deserialización desde JSON.
class BookingLineModel extends BookingLine {
  const BookingLineModel({
    super.id,
    super.equipmentId,
    super.activityId,
    required super.quantity,
    super.priceAtMoment,
  });

  factory BookingLineModel.fromMap(Map<String, dynamic> map) {
    final dynamic equipment = map['equipment'];
    final dynamic activity = map['activity'];
    final int? equipmentId = equipment is int
        ? equipment
        : map['equipmentId'] as int? ??
            map['equipment_id'] as int? ??
            map['id_equipment'] as int? ??
            (equipment is Map
                ? equipment['id_equipment'] as int? ?? equipment['id'] as int?
                : null);
    final int? activityId = activity is int
        ? activity
        : map['activityId'] as int? ??
            map['activity_id'] as int? ??
            map['id_activity'] as int? ??
            (activity is Map
                ? activity['id_activity'] as int? ?? activity['id'] as int?
                : null);

    return BookingLineModel(
      id: map['id_line'] as int? ?? map['idLine'] as int? ?? map['id'] as int?,
      equipmentId: equipmentId,
      activityId: activityId,
      quantity: int.tryParse(map['quantity'].toString()) ?? 0,
      priceAtMoment: double.tryParse(
            (map['price_at_moment'] ?? map['priceAtMoment'] ?? 0).toString(),
          ) ??
          0,
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
    final dynamic linesField = map['lines'] ??
        map['bookingLines'] ??
        map['booking_lines'] ??
        map['line'] ??
        map['Line'];
    final linesRaw = linesField is List ? linesField : const [];
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
      totalPrice: double.tryParse(map['total_price'].toString()) ?? 0,
    );
  }
}
