import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

/// Modelo de solicitud: extiende [Request] añadiendo la deserialización desde JSON del backend.
class RequestModel extends Request {
  const RequestModel({
    super.id,
    required super.activityId,
    required super.participantCount,
    required super.status,
    super.guideId,
    super.userId,
    super.bookingId,
    super.requestedMaterials,
    super.totalPrice,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id_request'] as int?,
      activityId: map['activityId'] as int? ?? 0,
      participantCount: map['participant_count'] as int? ?? 0,
      status: WorkflowStatus.fromCode(map['status'] as String? ?? ''),
      guideId: map['guideId'] as int?,
      userId: map['userId'] as int?,
      bookingId: map['bookingId'] as int?,
      requestedMaterials: {
        for (final e in (map['requested_materials'] as List<dynamic>? ?? []))
          e['equipmentId'] as int: e['quantity'] as int,
      },
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
    );
  }
}
