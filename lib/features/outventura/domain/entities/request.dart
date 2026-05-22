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

  // Crea una Solicitud a partir del JSON que devuelve el backend.
  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id_request'] as int?,
      activityId: map['activityId'] as int? ?? 0,
      participantCount: map['participant_count'] as int? ?? 0,
      status: WorkflowStatus.fromCode(map['status'] as String? ?? ''),
      guideId: map['guideId'] as int?,
      userId: map['userId'] as int?,
      bookingId: map['bookingId'] as int?,
      // requested_materials llega como [{ equipmentId, quantity }] desde el backend.
      requestedMaterials: {
        for (final e in (map['requested_materials'] as List<dynamic>? ?? []))
          e['equipmentId'] as int: e['quantity'] as int,
      },
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'activityId': activityId,
    'participant_count': participantCount,
    'status': status.code,
    if (guideId != null) 'guideId': guideId,
    'userId': userId,
    if (bookingId != null) 'bookingId': bookingId,
    'requested_materials': requestedMaterials.entries
        .map((e) => {'equipmentId': e.key, 'quantity': e.value})
        .toList(),
    'total_price': totalPrice,
  };

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
