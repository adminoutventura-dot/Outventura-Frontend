// Estados posibles de una reserva.
enum EstadoReserva {
  pendiente,
  confirmada,
  devuelta,
  cancelada;

  String get label {
    switch (this) {
      case EstadoReserva.pendiente:
        return 'Pendiente';
      case EstadoReserva.confirmada:
        return 'Confirmada';
      case EstadoReserva.devuelta:
        return 'Devuelta';
      case EstadoReserva.cancelada:
        return 'Cancelada';
    }
  }

  static EstadoReserva fromString(String value) {
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
    // idEquipamiento → cantidad dañada.
    this.itemsDaniados = const <int, int>{},
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
}

