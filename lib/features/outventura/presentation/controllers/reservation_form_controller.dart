import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

class ReservationFormController {
  final formKey = GlobalKey<FormState>();

  int? idUsuario;
  int? idExcursion;
  DateTime? fechaDesde;
  DateTime? fechaHasta;
  EstadoReserva estado = EstadoReserva.pendiente;
  bool editando = false;

  // Líneas de la reserva (material + cantidad).
  List<LineaReserva> lineas = [];

  // Daños por línea: idEquipamiento - cantidad dañada.
  Map<int, int> cantidadesDaniadas = {};

  Reserva? _original;

  // Total de cargos por daños calculado a partir del mapa.
  double get totalCargoDanios {
    double total = 0;
    for (final entry in cantidadesDaniadas.entries) {
      // Busca el equipamiento en la lista fake.
      final coincidencias = equipamientosFake.where((e) => e.id == entry.key);
      // Si hay equipamiento con ese id, suma su cargo por daño multiplicado por la cantidad dañada.
      if (coincidencias.isNotEmpty) {
        final eq = coincidencias.first;
        total += eq.cargoPorDanio * entry.value;
      }
    }
    return total;
  }

  void cargarReserva(Reserva r) {
    editando = true;
    _original = r;
    idUsuario = r.idUsuario;
    lineas = List.from(r.lineas);
    idExcursion = r.idExcursion;
    fechaDesde = r.fechaInicio;
    fechaHasta = r.fechaFin;
    cantidadesDaniadas = Map.from(r.itemsDaniados);
    estado = r.estado;
  }

  void agregarLinea(LineaReserva linea) {
    lineas.add(linea);
  }

  void actualizarLinea(int index, LineaReserva linea) {
    lineas[index] = linea;
  }

  void eliminarLinea(int index) {
    lineas.removeAt(index);
  }

  int cantidadDaniada(int idEquipamiento) {
    return cantidadesDaniadas[idEquipamiento] ?? 0;
  }

  void establecerCantidadDaniada(int idEquipamiento, int cantidad) {
    cantidadesDaniadas[idEquipamiento] = cantidad;
  }

  Reserva? crearReserva() {
    if (!validar()) {
      
      return null;
    }
    if (idUsuario == null || fechaDesde == null || fechaHasta == null || lineas.isEmpty) {
      return null;
    }
    return Reserva(
      id: _original?.id ?? 0,
      idUsuario: idUsuario!,
      lineas: List.unmodifiable(lineas),
      idExcursion: idExcursion,
      fechaInicio: fechaDesde!,
      fechaFin: fechaHasta!,
      estado: estado,
      cargoDanios: totalCargoDanios,
      itemsDaniados: Map.from(cantidadesDaniadas),
    );
  }

  bool validar() {
    return formKey.currentState?.validate() ?? false;
  }

  void dispose() {}
}

