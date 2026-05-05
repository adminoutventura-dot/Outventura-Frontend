// Estados posibles de una reserva.
enum EstadoReserva {
  pendiente,
  confirmada,
  enCurso,
  finalizada,
  cancelada;

  String get label {
    switch (this) {
      case EstadoReserva.pendiente:
        return 'Pendiente';
      case EstadoReserva.confirmada:
        return 'Confirmada';
      case EstadoReserva.enCurso:
        return 'En curso';
      case EstadoReserva.finalizada:
        return 'Finalizada';
      case EstadoReserva.cancelada:
        return 'Cancelada';
    }
  }

  static EstadoReserva fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return EstadoReserva.pendiente;
      case 'CONFIRMED':
        return EstadoReserva.confirmada;
      case 'IN_PROGRESS':
        return EstadoReserva.enCurso;
      case 'FINISHED':
      case 'RETURNED':
        return EstadoReserva.finalizada;
      case 'CANCELLED':
        return EstadoReserva.cancelada;
    }
    for (EstadoReserva status in EstadoReserva.values) {
      if (status.label.toLowerCase() == value.toLowerCase()) {
        return status;
      }
    }
    return EstadoReserva.pendiente;
  }
}

// Una línea de reserva (un material y su cantidad).
class LineaReserva {
  final int idEquipamiento;
  final int cantidad;

  const LineaReserva({required this.idEquipamiento, required this.cantidad});

  LineaReserva copyWith({int? idEquipamiento, int? cantidad}) {
    return LineaReserva(
      idEquipamiento: idEquipamiento ?? this.idEquipamiento,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}

// Entidad de reserva.
class Reserva {
  final int id;
  final int idUsuario;
  final List<LineaReserva> lineas;
  final int? idExcursion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final EstadoReserva estado;
  final double cargoDanios;
  // Cantidades dañadas por idEquipamiento: {idEquipamiento: cantidad}.
  final Map<int, int> itemsDaniados;

  const Reserva({
    required this.id,
    required this.idUsuario,
    required this.lineas,
    this.idExcursion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    this.cargoDanios = 0,
    // idEquipamiento - cantidad dañada.
    this.itemsDaniados = const {},
  });

  Reserva copyWith({
    int? idUsuario,
    List<LineaReserva>? lineas,
    int? idExcursion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    EstadoReserva? estado,
    double? cargoDanios,
    Map<int, int>? itemsDaniados,
  }) {
    return Reserva(
      id: id,
      idUsuario: idUsuario ?? this.idUsuario,
      lineas: lineas ?? this.lineas,
      idExcursion: idExcursion ?? this.idExcursion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      cargoDanios: cargoDanios ?? this.cargoDanios,
      itemsDaniados: itemsDaniados ?? this.itemsDaniados,
    );
  }

  // Crea una Reserva a partir del JSON que devuelve el backend.
  factory Reserva.fromMap(Map<String, dynamic> map) {
    // lines es una lista de objetos {equipmentId, quantity, ...}
    final List<LineaReserva> lineas = (map['lines'] as List<dynamic>? ?? [])
        .map((dynamic e) {
          final m = e as Map<String, dynamic>;
          return LineaReserva(
            idEquipamiento: (m['equipmentId'] ?? m['idEquipment'] ?? 0) as int,
            cantidad: (m['quantity'] ?? 0) as int,
          );
        })
        .toList();

    // damagedItems viene como {equipmentId: count} tras la conversión camelCase
    final Map<int, int> daniados =
        (map['damagedItems'] as Map<String, dynamic>? ?? {})
            .map((String k, dynamic v) =>
                MapEntry(int.tryParse(k) ?? 0, (v as num).toInt()));

    return Reserva(
      id: (map['idReservation'] ?? map['id']) as int,
      idUsuario: (map['userId'] ?? 0) as int,
      lineas: lineas,
      idExcursion: map['excursionId'] as int?,
      fechaInicio: DateTime.parse(map['startDate'] as String),
      fechaFin: DateTime.parse(map['endDate'] as String),
      estado: EstadoReserva.fromString(map['status'] as String? ?? 'PENDING'),
      cargoDanios: (map['damageFee'] as num?)?.toDouble() ?? 0,
      itemsDaniados: daniados,
    );
  }
}

