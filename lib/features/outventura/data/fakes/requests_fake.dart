import 'package:outventura/features/outventura/domain/entities/request.dart';

// Solicitudes de prueba referenciando excursiones del catálogo.
final List<Solicitud> solicitudesFake = [
  // Confirmada con reserva asociada y materiales ya ajustados manualmente.
  const Solicitud(
    id: 1,
    idExcursion: 1,
    numeroParticipantes: 6,
    estado: EstadoSolicitud.confirmada,
    idExperto: 1,
    idUsuario: 3,
    idReserva: 101,
    materialesSolicitados: {5: 6, 6: 10},
  ),

  // Pendiente con reserva asociada lista para editar desde la solicitud.
  const Solicitud(
    id: 2,
    idExcursion: 2,
    numeroParticipantes: 4,
    estado: EstadoSolicitud.pendiente,
    idExperto: 2,
    idUsuario: 4,
    idReserva: 102,
    materialesSolicitados: {3: 4, 8: 2},
  ),

  // Pendiente sin reserva aún, para probar botón "Reservar materiales".
  const Solicitud(
    id: 3,
    idExcursion: 3,
    numeroParticipantes: 3,
    estado: EstadoSolicitud.pendiente,
    idUsuario: 3,
    materialesSolicitados: {7: 3, 8: 2, 6: 2},
  ),

  // Finalizada con reserva previa y materiales consumidos.
  const Solicitud(
    id: 4,
    idExcursion: 4,
    numeroParticipantes: 2,
    estado: EstadoSolicitud.finalizada,
    idExperto: 1,
    idUsuario: 3,
    idReserva: 104,
    materialesSolicitados: {9: 2, 2: 2, 6: 4},
  ),

  // Cancelada sin reserva.
  const Solicitud(
    id: 5,
    idExcursion: 5,
    numeroParticipantes: 5,
    estado: EstadoSolicitud.cancelada,
    idUsuario: 4,
    materialesSolicitados: {},
  ),
];
