import 'package:outventura/features/outventura/domain/entities/reservation.dart';

final List<Booking> reservationsFake = [
  // Reserva creada desde solicitud #1 (cliente Laura), pendiente.
  const Booking(
    id: 101,
    userId: 3,
    lines: [
      BookingLine(equipmentId: 5, quantity: 6),
      BookingLine(equipmentId: 6, quantity: 10),
    ],
    activityId: 1,
    status: BookingStatus.pendiente,
  ),

  // Reserva confirmada (cliente Diego), editable desde solicitud #2.
  const Booking(
    id: 102,
    userId: 4,
    lines: [
      BookingLine(equipmentId: 3, quantity: 4),
      BookingLine(equipmentId: 8, quantity: 2),
    ],
    activityId: 2,
    status: BookingStatus.confirmada,
  ),

  // Reserva devuelta con daños registrados (cliente Laura).
  const Booking(
    id: 103,
    userId: 3,
    lines: [
      BookingLine(equipmentId: 4, quantity: 2),
      BookingLine(equipmentId: 2, quantity: 2),
    ],
    activityId: 2,
    status: BookingStatus.finalizada,
    damageFee: 50.0,
    damagedItems: {4: 1},
  ),

  // Reserva cancelada (cliente Laura).
  const Booking(
    id: 104,
    userId: 3,
    lines: [BookingLine(equipmentId: 2, quantity: 3)],
    activityId: 4,
    status: BookingStatus.cancelada,
  ),

  // Reserva manual de catálogo (sin solicitud asociada) para probar listados.
  const Booking(
    id: 105,
    userId: 3,
    lines: [
      BookingLine(equipmentId: 5, quantity: 4),
      BookingLine(equipmentId: 1, quantity: 2),
      BookingLine(equipmentId: 3, quantity: 1),
    ],
    activityId: 5,
    status: BookingStatus.pendiente,
  ),

  // Reserva en curso (vinculada a solicitud #6).
  const Booking(
    id: 106,
    userId: 3,
    lines: [
      BookingLine(equipmentId: 5, quantity: 3),
      BookingLine(equipmentId: 6, quantity: 6),
    ],
    activityId: 1,
    status: BookingStatus.enCurso,
  ),

  // ── Reservas de esta semana (19–25 mayo 2026) para la gráfica ──
  const Booking(
    id: 107,
    userId: 4,
    lines: [BookingLine(equipmentId: 5, quantity: 2)],
    activityId: 6,
    status: BookingStatus.confirmada,
  ),

  const Booking(
    id: 108,
    userId: 3,
    lines: [BookingLine(equipmentId: 3, quantity: 2)],
    activityId: 7,
    status: BookingStatus.confirmada,
  ),

  const Booking(
    id: 109,
    userId: 4,
    lines: [BookingLine(equipmentId: 8, quantity: 1)],
    activityId: 8,
    status: BookingStatus.enCurso,
  ),

  const Booking(
    id: 110,
    userId: 3,
    lines: [BookingLine(equipmentId: 6, quantity: 3)],
    activityId: 9,
    status: BookingStatus.confirmada,
  ),

  const Booking(
    id: 111,
    userId: 4,
    lines: [BookingLine(equipmentId: 3, quantity: 4)],
    activityId: 10,
    status: BookingStatus.confirmada,
  ),

  const Booking(
    id: 112,
    userId: 3,
    lines: [BookingLine(equipmentId: 5, quantity: 2)],
    activityId: 7,
    status: BookingStatus.confirmada,
  ),

];
