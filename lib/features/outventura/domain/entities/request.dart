import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

// Entidad de solicitud.
class Request {
  final int? id;
  final int activityId;
  final int participantCount;
  final WorkflowStatus status;
  final int? guideId;
  final int? userId;
  final int? bookingId;
  final Map<int, int> requestedMaterials;
  final double totalPrice;

  const Request({
    this.id,
    required this.activityId,
    required this.participantCount,
    required this.status,
    this.guideId,
    this.userId,
    this.bookingId,
    this.requestedMaterials = const {},
    this.totalPrice = 0,
  });

  Map<String, dynamic> toMap() {
    // Convierte el mapa de materiales a la lista que espera NestJS
    final listaMateriales = requestedMaterials.entries
        .map((e) => {'equipmentId': e.key, 'quantity': e.value})
        .toList();

    return {
      'activityId': activityId,
      'participant_count': participantCount,
      'status': status.code,
      if (guideId != null) 'guideId': guideId,
      if (userId != null) 'userId': userId,
      if (bookingId != null) 'bookingId': bookingId,
      // NestJS lo aceptará tanto al Crear como al Editar
      'requestedMaterials': listaMateriales,
      'total_price': totalPrice,
    };
  }

  Request copyWith({
    int? activityId,
    int? participantCount,
    WorkflowStatus? status,
    int? guideId,
    int? userId,
    int? bookingId,
    Map<int, int>? requestedMaterials,
    double? totalPrice,
  }) {
    return Request(
      id: id,
      activityId: activityId ?? this.activityId,
      participantCount: participantCount ?? this.participantCount,
      status: status ?? this.status,
      guideId: guideId ?? this.guideId,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      requestedMaterials: requestedMaterials ?? this.requestedMaterials,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}