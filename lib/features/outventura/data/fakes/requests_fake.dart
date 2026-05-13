import 'package:outventura/features/outventura/domain/entities/request.dart';

// Solicitudes de prueba referenciando actividades del catálogo.
final List<Request> requestsFake = [
  // Confirmada con reserva asociada y materiales ya ajustados manualmente.
  const Request(
    id: 1,
    activityId: 1,
    participantCount: 6,
    status: RequestStatus.confirmada,
    expertId: 1,
    userId: 3,
    reservationId: 101,
    requestedMaterials: {5: 6, 6: 10},
  ),

  // Pendiente con reserva asociada lista para editar desde la solicitud.
  const Request(
    id: 2,
    activityId: 2,
    participantCount: 4,
    status: RequestStatus.pendiente,
    expertId: 2,
    userId: 4,
    reservationId: 102,
    requestedMaterials: {3: 4, 8: 2},
  ),

  // Pendiente sin reserva aún, para probar botón "Reservar materiales".
  const Request(
    id: 3,
    activityId: 3,
    participantCount: 3,
    status: RequestStatus.pendiente,
    userId: 3,
    requestedMaterials: {7: 3, 8: 2, 6: 2},
  ),

  // Finalizada con reserva previa y materiales consumidos.
  const Request(
    id: 4,
    activityId: 4,
    participantCount: 2,
    status: RequestStatus.finalizada,
    expertId: 1,
    userId: 3,
    reservationId: 104,
    requestedMaterials: {9: 2, 2: 2, 6: 4},
  ),

  // Cancelada sin reserva.
  const Request(
    id: 5,
    activityId: 5,
    participantCount: 5,
    status: RequestStatus.cancelada,
    userId: 4,
    requestedMaterials: {},
  ),

  // En curso con reserva confirmada asociada.
  const Request(
    id: 6,
    activityId: 1,
    participantCount: 3,
    status: RequestStatus.enCurso,
    expertId: 2,
    userId: 3,
    reservationId: 106,
    requestedMaterials: {5: 3, 6: 6},
  ),
];
