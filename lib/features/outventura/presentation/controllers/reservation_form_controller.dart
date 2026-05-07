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
  int? idExcursion;
  DateTime fechaDesde = DateTime.now();
  DateTime fechaHasta = DateTime.now();
  TimeOfDay horaInicio = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 17, minute: 0);
  EstadoReserva estado = EstadoReserva.pendiente;

  // Líneas de la reserva (material + cantidad).
  List<LineaReserva> lineas = [];

  // Daños por línea: idEquipamiento - cantidad dañada.
  Map<int, int> cantidadesDaniadas = {};

  bool editando = false;
  Reserva? seleccionado;

  // Total de cargos por daños calculado usando el servicio de pricing.
  double totalCargoDanios(List<Equipamiento> equipamientos) {
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

  void cargarReserva(Reserva reserva) {
    editando = true;
    seleccionado = reserva;
    idUsuario = reserva.idUsuario;
    lineas = List.from(reserva.lineas);
    idExcursion = reserva.idExcursion;
    fechaDesde = reserva.fechaInicio;
    fechaHasta = reserva.fechaFin;
    horaInicio = TimeOfDay(hour: reserva.fechaInicio.hour, minute: reserva.fechaInicio.minute);
    horaFin = TimeOfDay(hour: reserva.fechaFin.hour, minute: reserva.fechaFin.minute);
    cantidadesDaniadas = Map.from(reserva.itemsDaniados);
    estado = reserva.estado;
  }

  void aplicarValoresIniciales({
    int? idUsuario,
    int? idExcursion,
    int? idEquipamiento,
    int cantidadEquipamiento = 1,
  }) {
    this.idUsuario = idUsuario;
    this.idExcursion = idExcursion;

    if (idEquipamiento != null && lineas.isEmpty) {
      lineas.add(
        LineaReserva(
          idEquipamiento: idEquipamiento,
          cantidad: cantidadEquipamiento,
        ),
      );
    }
  }

  void agregarLinea(LineaReserva linea) {
    lineas.add(linea);
  }

  void actualizarLinea(int index, LineaReserva linea) {
    lineas[index] = linea;
  }

  void eliminarLinea(int index) {
    final LineaReserva linea = lineas[index];
    cantidadesDaniadas.remove(linea.idEquipamiento);
    lineas.removeAt(index);
  }

  void establecerCantidadDaniada(int idEquipamiento, int cantidad) {
    cantidadesDaniadas[idEquipamiento] = cantidad;
  }

  // Abre un diálogo para añadir o editar una línea de reserva.
  Future<void> mostrarDialogoLinea({
    required BuildContext context,
    required List<Equipamiento> equipamientos,
    required void Function(VoidCallback) setState,
    int? index,
  }) async {
    final LineaReserva? linea;
    if (index != null) {
      linea = lineas[index];
    } else {
      linea = null;
    }

    final LineaReserva? result = await mostrarDialogoLineaReserva(
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
        if (linea != null && linea.idEquipamiento != result.idEquipamiento) {
          cantidadesDaniadas.remove(linea.idEquipamiento);
        }
        actualizarLinea(index, result);
      }
    });
  }

  Reserva? crearReserva(List<Equipamiento> equipamientos) {
    if (!validar()) {
      return null;
    }
    if (idUsuario == null || lineas.isEmpty) {
      return null;
    }

    final int id = seleccionado?.id ?? GeneradorId.idEntero();

    return Reserva(
      id: id,
      idUsuario: idUsuario!,
      lineas: List.unmodifiable(lineas),
      idExcursion: idExcursion,
      fechaInicio: _combinar(fechaDesde, horaInicio),
      fechaFin: _combinar(fechaHasta, horaFin),
      estado: estado,
      cargoDanios: totalCargoDanios(equipamientos),
      itemsDaniados: Map.from(cantidadesDaniadas),
    );
  }

  void dispose() {}
}
