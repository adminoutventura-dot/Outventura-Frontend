import 'package:outventura/features/outventura/domain/entities/reservation.dart';

final List<Reserva> reservasFake = [
  // Reserva creada desde solicitud #1 (cliente Laura), pendiente.
  Reserva(
    id: 101,
    idUsuario: 3,
    lineas: [
      const LineaReserva(idEquipamiento: 5, cantidad: 6),
      const LineaReserva(idEquipamiento: 6, cantidad: 10),
    ],
    idExcursion: 1,
    fechaInicio: DateTime(2026, 5, 1, 9, 0),
    fechaFin: DateTime(2026, 5, 1, 12, 0),
    estado: EstadoReserva.pendiente,
  ),

  // Reserva confirmada (cliente Diego), editable desde solicitud #2.
  Reserva(
    id: 102,
    idUsuario: 4,
    lineas: [
      const LineaReserva(idEquipamiento: 3, cantidad: 4),
      const LineaReserva(idEquipamiento: 8, cantidad: 2),
    ],
    idExcursion: 2,
    fechaInicio: DateTime(2026, 6, 10, 10, 0),
    fechaFin: DateTime(2026, 6, 10, 14, 0),
    estado: EstadoReserva.confirmada,
  ),

  // Reserva devuelta con daños registrados (cliente Laura).
  Reserva(
    id: 103,
    idUsuario: 3,
    lineas: [
      const LineaReserva(idEquipamiento: 4, cantidad: 2),
      const LineaReserva(idEquipamiento: 2, cantidad: 2),
    ],
    idExcursion: 2,
    fechaInicio: DateTime(2026, 4, 1, 10, 0),
    fechaFin: DateTime(2026, 4, 1, 14, 0),
    estado: EstadoReserva.finalizada,
    cargoDanios: 50.0,
    itemsDaniados: {4: 1},
  ),

  // Reserva cancelada (cliente Laura).
  Reserva(
    id: 104,
    idUsuario: 3,
    lineas: [const LineaReserva(idEquipamiento: 2, cantidad: 3)],
    idExcursion: 4,
    fechaInicio: DateTime(2026, 12, 20, 9, 0),
    fechaFin: DateTime(2026, 12, 20, 15, 0),
    estado: EstadoReserva.cancelada,
  ),

  // Reserva manual de catálogo (sin solicitud asociada) para probar listados.
  Reserva(
    id: 105,
    idUsuario: 3,
    lineas: [
      const LineaReserva(idEquipamiento: 5, cantidad: 4),
      const LineaReserva(idEquipamiento: 1, cantidad: 2),
      const LineaReserva(idEquipamiento: 3, cantidad: 1),
    ],
    idExcursion: 5,
    fechaInicio: DateTime(2026, 8, 5, 18, 0),
    fechaFin: DateTime(2026, 8, 5, 20, 0),
    estado: EstadoReserva.pendiente,
  ),

  // Reserva en curso (vinculada a solicitud #6).
  Reserva(
    id: 106,
    idUsuario: 3,
    lineas: [
      const LineaReserva(idEquipamiento: 5, cantidad: 3),
      const LineaReserva(idEquipamiento: 6, cantidad: 6),
    ],
    idExcursion: 1,
    fechaInicio: DateTime(2026, 5, 1, 9, 0),
    fechaFin: DateTime(2026, 5, 1, 12, 0),
    estado: EstadoReserva.enCurso,
  ),
];
