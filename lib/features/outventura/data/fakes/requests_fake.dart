import 'package:outventura/features/outventura/domain/entities/request.dart';

// Solicitudes de prueba referenciando excursiones del catálogo.
final List<Solicitud> solicitudesFake = [
  const Solicitud(id: 1, idExcursion: 1, numeroParticipantes: 12, estado: EstadoSolicitud.confirmada, idExperto: 1),
  const Solicitud(id: 2, idExcursion: 2, numeroParticipantes: 8,  estado: EstadoSolicitud.pendiente,   idExperto: 2),
  const Solicitud(id: 3, idExcursion: 3, numeroParticipantes: 6,  estado: EstadoSolicitud.pendiente,   idExperto: 3),
  const Solicitud(id: 4, idExcursion: 4, numeroParticipantes: 10, estado: EstadoSolicitud.finalizada,  idExperto: 1),
];

