import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

/// Modelo de línea de reserva: extiende [BookingLine] añadiendo la deserialización desde JSON.
class BookingLineModel extends BookingLine {
  const BookingLineModel({
    required super.equipmentId,
    required super.quantity,
    super.priceAtMoment,
  });

  factory BookingLineModel.fromMap(Map<String, dynamic> map) {
    return BookingLineModel(
      equipmentId: map['equipmentId'] as int? ?? 0,
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
    super.activityId,
    required super.status,
    required super.startDate,
    required super.endDate,
    super.totalPrice,
    super.damageFee,
    super.damagedItems,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final linesRaw = map['lines'] as List? ?? [];
    final lines = linesRaw
        .map((e) => BookingLineModel.fromMap(e as Map<String, dynamic>))
        .toList();

    // En el nuevo backend, la actividad cuelga de la reserva directamente (activityId)
    // Ya no es necesario buscarla dentro de la primera línea.
    final int? activityId = map['activityId'] as int?;

    // 🌟 CAMBIO: El estado viene como un objeto anidado en el nuevo backend
    String statusCode = 'PENDING';
    if (map['status'] != null) {
      if (map['status'] is Map) {
        statusCode = map['status']['code'] as String? ?? 'PENDING';
      } else if (map['status'] is String) {
        statusCode = map['status'] as String;
      }
    }

    final userMap = map['user'] as Map<String, dynamic>?;
    final int userId = userMap?['id_user'] as int? ?? 0;

    final rawDamaged = map['damaged_items'] as List<dynamic>? ?? [];
    final Map<int, int> damagedItems = {
      for (final e in rawDamaged)
        e['equipmentId'] as int: e['quantity'] as int,
    };

    // 🌟 CAMBIO: Buscamos init_date en vez de start_date
    final String? startDateRaw = map['init_date'] as String? ?? map['start_date'] as String?;
    final String? endDateRaw = map['end_date'] as String?;
    
    final DateTime parsedStartDate = startDateRaw != null ? DateTime.parse(startDateRaw) : DateTime.now();
    final DateTime parsedEndDate = endDateRaw != null ? DateTime.parse(endDateRaw) : DateTime.now();

    return BookingModel(
      id: map['id_booking'] as int?,
      userId: userId,
      lines: lines,
      activityId: activityId,
      status: WorkflowStatus.fromCode(statusCode),
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      damageFee: (map['damage_fee'] as num?)?.toDouble() ?? 0,
      damagedItems: damagedItems,
    );
  }
}