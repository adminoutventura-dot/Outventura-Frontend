import 'package:flutter/material.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_dialog.dart';
import 'package:outventura/features/outventura/services/pricing_service.dart';

// Combina una fecha y una hora en un DateTime.
DateTime _combinar(DateTime fecha, TimeOfDay hora) =>
    DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);

class ReservationFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? idUsuario;
  int? idActividad;
  DateTime fechaDesde = DateTime.now();
  DateTime fechaHasta = DateTime.now();
  TimeOfDay horaInicio = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 17, minute: 0);
  ReservationStatus estado = ReservationStatus.pendiente;

  // Líneas de la reserva (material + cantidad).
  List<ReservationLine> lineas = [];

  // Daños por línea: idEquipamiento - cantidad dañada.
  Map<int, int> cantidadesDaniadas = {};

  bool editando = false;
  Reservation? seleccionado;

  // Total de cargos por daños calculado usando el servicio de pricing.
  double totalCargoDanios(List<Equipment> equipamientos) {
    return calcularCargoDanios(
      cantidadesDaniadas: cantidadesDaniadas,
      equipamientos: equipamientos,
    );
  }

  bool validar() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  int cantidadDaniada(int idEquipamiento) {
    return cantidadesDaniadas[idEquipamiento] ?? 0;
  }

  void cargarReserva(Reservation reserva) {
    editando = true;
    seleccionado = reserva;
    idUsuario = reserva.userId;
    lineas = List.from(reserva.lines);
    idActividad = reserva.activityId;
    fechaDesde = reserva.startDate;
    fechaHasta = reserva.endDate;
    horaInicio = TimeOfDay(hour: reserva.startDate.hour, minute: reserva.startDate.minute);
    horaFin = TimeOfDay(hour: reserva.endDate.hour, minute: reserva.endDate.minute);
    cantidadesDaniadas = Map.from(reserva.damagedItems);
    estado = reserva.status;
  }

  void aplicarValoresIniciales({
    int? idUsuario,
    int? idActividad,
    int? idEquipamiento,
    int cantidadEquipamiento = 1,
  }) {
    this.idUsuario = idUsuario;
    this.idActividad = idActividad;

    if (idEquipamiento != null && lineas.isEmpty) {
      lineas.add(
        ReservationLine(
          equipmentId: idEquipamiento,
          quantity: cantidadEquipamiento,
        ),
      );
    }
  }

  void agregarLinea(ReservationLine linea) {
    lineas.add(linea);
  }

  void actualizarLinea(int index, ReservationLine linea) {
    lineas[index] = linea;
  }

  void eliminarLinea(int index) {
    final ReservationLine linea = lineas[index];
    cantidadesDaniadas.remove(linea.equipmentId);
    lineas.removeAt(index);
  }

  void establecerCantidadDaniada(int idEquipamiento, int cantidad) {
    cantidadesDaniadas[idEquipamiento] = cantidad;
  }

  // Abre un diálogo para añadir o editar una línea de reserva.
  Future<void> mostrarDialogoLinea({
    required BuildContext context,
    required List<Equipment> equipamientos,
    required void Function(VoidCallback) setState,
    int? index,
  }) async {
    final ReservationLine? linea;
    if (index != null) {
      linea = lineas[index];
    } else {
      linea = null;
    }

    final ReservationLine? result = await mostrarDialogoLineaReserva(
      context: context,
      equipamientos: equipamientos,
      initialLinea: linea,
    );
    if (result == null) {
      return;
    }

    setState(() {
      if (index == null) {
        agregarLinea(result);
      } else {
        // Si el equipamiento cambió, limpia los daños del id anterior.
        if (linea != null && linea.equipmentId != result.equipmentId) {
          cantidadesDaniadas.remove(linea.equipmentId);
        }
        actualizarLinea(index, result);
      }
    });
  }

  Reservation? crearReserva(List<Equipment> equipamientos) {
    if (!validar()) {
      return null;
    }
    if (idUsuario == null || lineas.isEmpty) {
      return null;
    }

    final int id = seleccionado?.id ?? GeneradorId.idEntero();

    return Reservation(
      id: id,
      userId: idUsuario!,
      lines: List.unmodifiable(lineas),
      activityId: idActividad,
      startDate: _combinar(fechaDesde, horaInicio),
      endDate: _combinar(fechaHasta, horaFin),
      status: estado,
      damageFee: totalCargoDanios(equipamientos),
      damagedItems: Map.from(cantidadesDaniadas),
    );
  }

  void dispose() {}
}
