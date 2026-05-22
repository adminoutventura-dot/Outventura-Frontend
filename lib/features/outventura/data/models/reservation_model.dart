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
    super.totalPrice,
    super.damageFee,
    super.damagedItems,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final linesRaw = map['lines'] as List? ?? [];
    final lines = linesRaw
        .map((e) => BookingLineModel.fromMap(e as Map<String, dynamic>))
        .toList();

    final int? activityId = map['activityId'] as int? ??
        (linesRaw.isNotEmpty
            ? (linesRaw.first as Map<String, dynamic>)['activityId'] as int?
            : null);

    final String statusCode = map['status'] as String? ?? '';

    final userMap = map['user'] as Map<String, dynamic>?;
    final int userId = userMap?['id_user'] as int? ?? 0;

    final rawDamaged = map['damaged_items'] as List<dynamic>? ?? [];
    final Map<int, int> damagedItems = {
      for (final e in rawDamaged)
        e['equipmentId'] as int: e['quantity'] as int,
    };

    return BookingModel(
      id: map['id_booking'] as int?,
      userId: userId,
      lines: lines,
      activityId: activityId,
      status: WorkflowStatus.fromCode(statusCode),
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
      damageFee: (map['damage_fee'] as num?)?.toDouble() ?? 0,
      damagedItems: damagedItems,
    );
  }
}
