import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_dialog.dart';
import 'package:outventura/features/outventura/services/pricing_service.dart';

class ReservationFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? idUsuario;
  int? idActividad;
  DateTime fechaDesde = DateTime.now();
  DateTime fechaHasta = DateTime.now();
  TimeOfDay horaInicio = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 17, minute: 0);
  BookingStatus estado = BookingStatus.pendiente;

  // Líneas de la reserva (material + cantidad).
  List<BookingLine> lineas = [];

  // Daños por línea: idEquipamiento - cantidad dañada.
  Map<int, int> cantidadesDaniadas = {};

  bool editando = false;
  Booking? seleccionado;

  // Total de cargos por daños calculado usando el servicio de pricing.
  double totalCargoDanios(List<Equipment> equipamientos) {
    return calcularCargoDanios(
      cantidadesDaniadas: cantidadesDaniadas,
      equipamientos: equipamientos,
    );
  }

  // Total de alquiler de equipamientos: precioAlquilerDiario × cantidad × días.
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

  int cantidadDaniada(int idEquipamiento) {
    return cantidadesDaniadas[idEquipamiento] ?? 0;
  }

  void cargarReserva(Booking reserva, {DateTime? activityStart, DateTime? activityEnd}) {
    editando = true;
    seleccionado = reserva;
    idUsuario = reserva.userId;
    lineas = List.from(reserva.lines);
    idActividad = reserva.activityId;
    // Las fechas vienen de la Activity asociada
    fechaDesde = activityStart ?? DateTime.now();
    fechaHasta = activityEnd ?? DateTime.now();
    horaInicio = activityStart != null 
        ? TimeOfDay(hour: activityStart.hour, minute: activityStart.minute)
        : const TimeOfDay(hour: 9, minute: 0);
    horaFin = activityEnd != null
        ? TimeOfDay(hour: activityEnd.hour, minute: activityEnd.minute)
        : const TimeOfDay(hour: 17, minute: 0);
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
        BookingLine(
          equipmentId: idEquipamiento,
          quantity: cantidadEquipamiento,
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
    final BookingLine linea = lineas[index];
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
    final BookingLine? linea;
    if (index != null) {
      linea = lineas[index];
    } else {
      linea = null;
    }

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
        // Si el equipamiento cambió, limpia los daños del id anterior.
        if (linea != null && linea.equipmentId != result.equipmentId) {
          cantidadesDaniadas.remove(linea.equipmentId);
        }
        actualizarLinea(index, result);
      }
    });
  }

  Booking? crearEditarReserva(List<Equipment> equipamientos) {
    if (!validar()) {
      return null;
    }
    if (idUsuario == null || lineas.isEmpty) {
      return null;
    }

    return Booking(
      id: seleccionado?.id,
      userId: idUsuario!,
      lines: List.unmodifiable(lineas),
      activityId: idActividad,
      status: estado,
      damageFee: totalCargoDanios(equipamientos),
      damagedItems: Map.from(cantidadesDaniadas),
    );
  }

  void dispose() {}
}
