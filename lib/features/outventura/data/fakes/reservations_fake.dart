import 'package:outventura/features/outventura/domain/entities/reservation.dart';

final List<Reserva> reservasFake = <Reserva>[
  Reserva(
    id: 1,
    idUsuario: 3,
    lineas: <LineaReserva>[
      const LineaReserva(idEquipamiento: 1, cantidad: 2),
      const LineaReserva(idEquipamiento: 3, cantidad: 1),
    ],
    idExcursion: 1,
    fechaInicio: DateTime(2026, 5, 1),
    fechaFin: DateTime(2026, 5, 3),
    estado: EstadoReserva.pendiente,
  ),

  Reserva(
    id: 2,
    idUsuario: 3,
    lineas: <LineaReserva>[
      const LineaReserva(idEquipamiento: 3, cantidad: 1),
    ],
    fechaInicio: DateTime(2026, 5, 10),
    fechaFin: DateTime(2026, 5, 12),
    estado: EstadoReserva.confirmada,
  ),

  Reserva(
    id: 3,
    idUsuario: 3,
    lineas: <LineaReserva>[
      const LineaReserva(idEquipamiento: 4, cantidad: 1),
      const LineaReserva(idEquipamiento: 2, cantidad: 3),
    ],
    idExcursion: 2,
    fechaInicio: DateTime(2026, 4, 1),
    fechaFin: DateTime(2026, 4, 3),
    estado: EstadoReserva.devuelta,
    cargoDanios: 50.0,
  ),

  Reserva(
    id: 4,
    idUsuario: 3,
    lineas: <LineaReserva>[
      const LineaReserva(idEquipamiento: 2, cantidad: 3),
    ],
    fechaInicio: DateTime(2026, 6, 5),
    fechaFin: DateTime(2026, 6, 7),
    estado: EstadoReserva.cancelada,
  ),

  Reserva(
    id: 5,
    idUsuario: 3,
    lineas: <LineaReserva>[
      const LineaReserva(idEquipamiento: 5, cantidad: 4),
      const LineaReserva(idEquipamiento: 1, cantidad: 2),
      const LineaReserva(idEquipamiento: 3, cantidad: 1),
    ],
    idExcursion: 3,
    fechaInicio: DateTime(2026, 7, 15),
    fechaFin: DateTime(2026, 7, 17),
    estado: EstadoReserva.pendiente,
  ),
];

