import 'package:outventura/features/outventura/domain/entities/reservation.dart';

final List<Reservation> reservationsFake = [
  // Reserva creada desde solicitud #1 (cliente Laura), pendiente.
  Reservation(
    id: 101,
    userId: 3,
    lines: [
      const ReservationLine(equipmentId: 5, quantity: 6),
      const ReservationLine(equipmentId: 6, quantity: 10),
    ],
    activityId: 1,
    startDate: DateTime(2026, 5, 1, 9, 0),
    endDate: DateTime(2026, 5, 1, 12, 0),
    status: ReservationStatus.pendiente,
  ),

  // Reserva confirmada (cliente Diego), editable desde solicitud #2.
  Reservation(
    id: 102,
    userId: 4,
    lines: [
      const ReservationLine(equipmentId: 3, quantity: 4),
      const ReservationLine(equipmentId: 8, quantity: 2),
    ],
    activityId: 2,
    startDate: DateTime(2026, 6, 10, 10, 0),
    endDate: DateTime(2026, 6, 10, 14, 0),
    status: ReservationStatus.confirmada,
  ),

  // Reserva devuelta con daños registrados (cliente Laura).
  Reservation(
    id: 103,
    userId: 3,
    lines: [
      const ReservationLine(equipmentId: 4, quantity: 2),
      const ReservationLine(equipmentId: 2, quantity: 2),
    ],
    activityId: 2,
    startDate: DateTime(2026, 4, 1, 10, 0),
    endDate: DateTime(2026, 4, 1, 14, 0),
    status: ReservationStatus.finalizada,
    damageFee: 50.0,
    damagedItems: {4: 1},
  ),

  // Reserva cancelada (cliente Laura).
  Reservation(
    id: 104,
    userId: 3,
    lines: [const ReservationLine(equipmentId: 2, quantity: 3)],
    activityId: 4,
    startDate: DateTime(2026, 12, 20, 9, 0),
    endDate: DateTime(2026, 12, 20, 15, 0),
    status: ReservationStatus.cancelada,
  ),

  // Reserva manual de catálogo (sin solicitud asociada) para probar listados.
  Reservation(
    id: 105,
    userId: 3,
    lines: [
      const ReservationLine(equipmentId: 5, quantity: 4),
      const ReservationLine(equipmentId: 1, quantity: 2),
      const ReservationLine(equipmentId: 3, quantity: 1),
    ],
    activityId: 5,
    startDate: DateTime(2026, 8, 5, 18, 0),
    endDate: DateTime(2026, 8, 5, 20, 0),
    status: ReservationStatus.pendiente,
  ),

  // Reserva en curso (vinculada a solicitud #6).
  Reservation(
    id: 106,
    userId: 3,
    lines: [
      const ReservationLine(equipmentId: 5, quantity: 3),
      const ReservationLine(equipmentId: 6, quantity: 6),
    ],
    activityId: 1,
    startDate: DateTime(2026, 5, 1, 9, 0),
    endDate: DateTime(2026, 5, 1, 12, 0),
    status: ReservationStatus.enCurso,
  ),
];
