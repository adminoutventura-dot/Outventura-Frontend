import 'package:outventura/features/outventura/domain/entities/reservation.dart';

final List<Booking> reservationsFake = [
  // Reserva creada desde solicitud #1 (cliente Laura), pendiente.
  Booking(
    id: 101,
    userId: 3,
    lines: [
      const BookingLine(equipmentId: 5, quantity: 6),
      const BookingLine(equipmentId: 6, quantity: 10),
    ],
    activityId: 1,
    startDate: DateTime(2026, 5, 1, 9, 0),
    endDate: DateTime(2026, 5, 1, 12, 0),
    status: BookingStatus.pendiente,
  ),

  // Reserva confirmada (cliente Diego), editable desde solicitud #2.
  Booking(
    id: 102,
    userId: 4,
    lines: [
      const BookingLine(equipmentId: 3, quantity: 4),
      const BookingLine(equipmentId: 8, quantity: 2),
    ],
    activityId: 2,
    startDate: DateTime(2026, 6, 10, 10, 0),
    endDate: DateTime(2026, 6, 10, 14, 0),
    status: BookingStatus.confirmada,
  ),

  // Reserva devuelta con daños registrados (cliente Laura).
  Booking(
    id: 103,
    userId: 3,
    lines: [
      const BookingLine(equipmentId: 4, quantity: 2),
      const BookingLine(equipmentId: 2, quantity: 2),
    ],
    activityId: 2,
    startDate: DateTime(2026, 4, 1, 10, 0),
    endDate: DateTime(2026, 4, 1, 14, 0),
    status: BookingStatus.finalizada,
    damageFee: 50.0,
    damagedItems: {4: 1},
  ),

  // Reserva cancelada (cliente Laura).
  Booking(
    id: 104,
    userId: 3,
    lines: [const BookingLine(equipmentId: 2, quantity: 3)],
    activityId: 4,
    startDate: DateTime(2026, 12, 20, 9, 0),
    endDate: DateTime(2026, 12, 20, 15, 0),
    status: BookingStatus.cancelada,
  ),

  // Reserva manual de catálogo (sin solicitud asociada) para probar listados.
  Booking(
    id: 105,
    userId: 3,
    lines: [
      const BookingLine(equipmentId: 5, quantity: 4),
      const BookingLine(equipmentId: 1, quantity: 2),
      const BookingLine(equipmentId: 3, quantity: 1),
    ],
    activityId: 5,
    startDate: DateTime(2026, 8, 5, 18, 0),
    endDate: DateTime(2026, 8, 5, 20, 0),
    status: BookingStatus.pendiente,
  ),

  // Reserva en curso (vinculada a solicitud #6).
  Booking(
    id: 106,
    userId: 3,
    lines: [
      const BookingLine(equipmentId: 5, quantity: 3),
      const BookingLine(equipmentId: 6, quantity: 6),
    ],
    activityId: 1,
    startDate: DateTime(2026, 5, 1, 9, 0),
    endDate: DateTime(2026, 5, 1, 12, 0),
    status: BookingStatus.enCurso,
  ),

  // ── Reservas de esta semana (19–25 mayo 2026) para la gráfica ──
  Booking(
    id: 107,
    userId: 4,
    lines: [const BookingLine(equipmentId: 5, quantity: 2)],
    activityId: 6,
    startDate: DateTime(2026, 5, 19, 9, 0),
    endDate: DateTime(2026, 5, 19, 14, 0),
    status: BookingStatus.confirmada,
  ),

  Booking(
    id: 108,
    userId: 3,
    lines: [const BookingLine(equipmentId: 3, quantity: 2)],
    activityId: 7,
    startDate: DateTime(2026, 5, 20, 10, 0),
    endDate: DateTime(2026, 5, 20, 13, 0),
    status: BookingStatus.confirmada,
  ),

  Booking(
    id: 109,
    userId: 4,
    lines: [const BookingLine(equipmentId: 8, quantity: 1)],
    activityId: 8,
    startDate: DateTime(2026, 5, 21, 8, 0),
    endDate: DateTime(2026, 5, 21, 16, 0),
    status: BookingStatus.enCurso,
  ),

  Booking(
    id: 110,
    userId: 3,
    lines: [const BookingLine(equipmentId: 6, quantity: 3)],
    activityId: 9,
    startDate: DateTime(2026, 5, 22, 9, 0),
    endDate: DateTime(2026, 5, 22, 15, 0),
    status: BookingStatus.confirmada,
  ),

  Booking(
    id: 111,
    userId: 4,
    lines: [const BookingLine(equipmentId: 3, quantity: 4)],
    activityId: 10,
    startDate: DateTime(2026, 5, 23, 9, 0),
    endDate: DateTime(2026, 5, 23, 13, 0),
    status: BookingStatus.confirmada,
  ),

  Booking(
    id: 112,
    userId: 3,
    lines: [const BookingLine(equipmentId: 5, quantity: 2)],
    activityId: 7,
    startDate: DateTime(2026, 5, 24, 10, 0),
    endDate: DateTime(2026, 5, 24, 13, 0),
    status: BookingStatus.confirmada,
  ),

];
