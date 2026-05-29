import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_dialog.dart';
import 'package:outventura/features/outventura/services/pricing_service.dart';

class ReservationFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? idUsuario;
  int? idActividad; // Mantiene la referencia temporal en el formulario de la UI
  DateTime fechaDesde = DateTime.now();
  DateTime fechaHasta = DateTime.now();
  TimeOfDay horaInicio = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 17, minute: 0);
  WorkflowStatus estado = WorkflowStatus.pendiente;

  // Líneas de la reserva (materiales o actividades).
  List<BookingLine> lineas = [];

  bool editando = false;
  Booking? seleccionado;

  // Calcula el total del alquiler de equipamientos.
  double totalAlquiler(List<Equipment> equipamientos) {
    return calcularPrecioReserva(
      lineas: lineas,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      equipamientos: equipamientos,
    );
  }

  bool validar() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  void cargarReserva(Booking reserva) {
    editando = true;
    seleccionado = reserva;
    idUsuario = reserva.userId;
    lineas = List.from(reserva.lines);
    estado = reserva.status;
    fechaDesde = reserva.startDate;
    fechaHasta = reserva.endDate;
    horaInicio = TimeOfDay(
      hour: reserva.startDate.hour,
      minute: reserva.startDate.minute,
    );
    horaFin = TimeOfDay(
      hour: reserva.endDate.hour,
      minute: reserva.endDate.minute,
    );

    // Recupera el id de actividad buscando en las líneas para la UI del formulario
    final lineAct = reserva.lines
        .where((l) => l.activityId != null)
        .firstOrNull;
    idActividad = lineAct?.activityId;
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
        BookingLine(
          equipmentId: idEquipamiento,
          quantity: cantidadEquipamiento,
        ),
      );
    }

    // Si viene de una actividad, inserta la línea correspondiente
    if (idActividad != null && lineas.isEmpty) {
      lineas.add(
        BookingLine(
          activityId: idActividad,
          quantity: 1, // Por defecto una plaza
        ),
      );
    }
  }

  void agregarLinea(BookingLine linea) {
    lineas.add(linea);
  }

  void actualizarLinea(int index, BookingLine linea) {
    lineas[index] = linea;
  }

  void eliminarLinea(int index) {
    lineas.removeAt(index);
  }

  // Abre un diálogo para añadir o editar una línea de reserva de material.
  Future<void> mostrarDialogoLinea({
    required BuildContext context,
    required List<Equipment> equipamientos,
    required void Function(VoidCallback) setState,
    int? index,
  }) async {
    final BookingLine? linea = index != null ? lineas[index] : null;

    final BookingLine? result = await mostrarDialogoLineaReserva(
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
        actualizarLinea(index, result);
      }
    });
  }

  Booking? crearEditarReserva(List<Equipment> equipamientos) {
    if (!validar() || idUsuario == null || lineas.isEmpty) {
      return null;
    }

    // Fusiona fechaDesde con horaInicio
    final DateTime fechaInicioReal = DateTime(
      fechaDesde.year,
      fechaDesde.month,
      fechaDesde.day,
      horaInicio.hour,
      horaInicio.minute,
    );

    // Fusiona fechaHasta con horaFin
    final DateTime fechaFinReal = DateTime(
      fechaHasta.year,
      fechaHasta.month,
      fechaHasta.day,
      horaFin.hour,
      horaFin.minute,
    );

    return Booking(
      id: seleccionado?.id,
      userId: idUsuario!,
      lines: List.unmodifiable(lineas),
      status: estado,
      startDate: fechaInicioReal,
      endDate: fechaFinReal,
    );
  }

  void dispose() {}
}
