import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

final List<Booking> reservationsFake = [
  Booking(
    id: 101,
    userId: 3,
    lines: const [
      BookingLine(equipmentId: 5, quantity: 6, priceAtMoment: 7.0),
      BookingLine(equipmentId: 6, quantity: 10, priceAtMoment: 3.0),
    ],
    activityId: 1,
    status: WorkflowStatus.pendiente,
    startDate: DateTime(2026, 5, 24, 9, 0),
    endDate: DateTime(2026, 5, 24, 14, 0),
  ),

  Booking(
    id: 102,
    userId: 4,
    lines: const [
      BookingLine(equipmentId: 3, quantity: 4, priceAtMoment: 25.0),
      BookingLine(equipmentId: 8, quantity: 2, priceAtMoment: 4.0),
    ],
    activityId: 2,
    status: WorkflowStatus.confirmada,
    startDate: DateTime(2026, 5, 25, 10, 0),
    endDate: DateTime(2026, 5, 25, 16, 0),
  ),

  Booking(
    id: 103,
    userId: 3,
    lines: const [
      BookingLine(equipmentId: 4, quantity: 2, priceAtMoment: 20.0),
      BookingLine(equipmentId: 2, quantity: 2, priceAtMoment: 10.0),
    ],
    activityId: 2,
    status: WorkflowStatus.finalizada,
    damageFee: 50.0,
    damagedItems: const {4: 1},
    startDate: DateTime(2026, 5, 20, 9, 0),
    endDate: DateTime(2026, 5, 20, 13, 0),
  ),

  Booking(
    id: 104,
    userId: 3,
    lines: const [BookingLine(equipmentId: 2, quantity: 3, priceAtMoment: 10.0)],
    activityId: 4,
    status: WorkflowStatus.cancelada,
    startDate: DateTime(2026, 5, 21, 9, 0),
    endDate: DateTime(2026, 5, 21, 14, 0),
  ),

  Booking(
    id: 105,
    userId: 3,
    lines: const [
      BookingLine(equipmentId: 5, quantity: 4, priceAtMoment: 7.0),
      BookingLine(equipmentId: 1, quantity: 2, priceAtMoment: 12.5),
      BookingLine(equipmentId: 3, quantity: 1, priceAtMoment: 25.0),
    ],
    activityId: 5,
    status: WorkflowStatus.pendiente,
    startDate: DateTime(2026, 5, 26, 11, 0),
    endDate: DateTime(2026, 5, 26, 18, 0),
  ),

  Booking(
    id: 106,
    userId: 3,
    lines: const [
      BookingLine(equipmentId: 5, quantity: 3, priceAtMoment: 7.0),
      BookingLine(equipmentId: 6, quantity: 6, priceAtMoment: 3.0),
    ],
    activityId: 1,
    status: WorkflowStatus.enCurso,
    startDate: DateTime(2026, 5, 23, 9, 0), // Hoy
    endDate: DateTime(2026, 5, 23, 17, 0),
  ),

  Booking(
    id: 107,
    userId: 4,
    lines: const [BookingLine(equipmentId: 5, quantity: 2, priceAtMoment: 7.0)],
    activityId: 6,
    status: WorkflowStatus.confirmada,
    startDate: DateTime(2026, 5, 19, 9, 0),
    endDate: DateTime(2026, 5, 19, 13, 0),
  ),

  Booking(
    id: 108,
    userId: 3,
    lines: const [BookingLine(equipmentId: 3, quantity: 2, priceAtMoment: 25.0)],
    activityId: 7,
    status: WorkflowStatus.confirmada,
    startDate: DateTime(2026, 5, 20, 10, 0),
    endDate: DateTime(2026, 5, 20, 14, 0),
  ),

  Booking(
    id: 109,
    userId: 4,
    lines: const [BookingLine(equipmentId: 8, quantity: 1, priceAtMoment: 4.0)],
    activityId: 8,
    status: WorkflowStatus.enCurso,
    startDate: DateTime(2026, 5, 23, 8, 0), // Hoy
    endDate: DateTime(2026, 5, 23, 12, 0),
  ),

  Booking(
    id: 110,
    userId: 3,
    lines: const [BookingLine(equipmentId: 6, quantity: 3, priceAtMoment: 3.0)],
    activityId: 9,
    status: WorkflowStatus.confirmada,
    startDate: DateTime(2026, 5, 22, 9, 0),
    endDate: DateTime(2026, 5, 22, 14, 0),
  ),

  Booking(
    id: 111,
    userId: 4,
    lines: const [BookingLine(equipmentId: 3, quantity: 4, priceAtMoment: 25.0)],
    activityId: 10,
    status: WorkflowStatus.confirmada,
    startDate: DateTime(2026, 5, 24, 9, 0),
    endDate: DateTime(2026, 5, 24, 15, 0),
  ),

  Booking(
    id: 112,
    userId: 3,
    lines: const [BookingLine(equipmentId: 5, quantity: 2, priceAtMoment: 7.0)],
    activityId: 7,
    status: WorkflowStatus.confirmada,
    startDate: DateTime(2026, 5, 25, 9, 0),
    endDate: DateTime(2026, 5, 25, 13, 0),
  ),
];