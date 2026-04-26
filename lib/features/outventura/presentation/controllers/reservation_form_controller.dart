import 'package:flutter/material.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_dialog.dart';

class ReservationFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? idUsuario;
  int? idExcursion;
  DateTime fechaDesde = DateTime.now();
  DateTime fechaHasta = DateTime.now();
  EstadoReserva estado = EstadoReserva.pendiente;

  // Líneas de la reserva (material + cantidad).
  List<LineaReserva> lineas = [];

  // Daños por línea: idEquipamiento - cantidad dañada.
  Map<int, int> cantidadesDaniadas = {};

  bool editando = false;
  Reserva? seleccionado;

  // Total de cargos por daños calculado a partir del mapa.
  double get totalCargoDanios {
    double total = 0;

    for (final MapEntry<int, int> entry in cantidadesDaniadas.entries) {
      // Busca el equipamiento en la lista fake.
      final Iterable<Equipamiento> coincidencias = equipamientosFake.where(
        (Equipamiento e) => e.id == entry.key,
      );

      // Si hay equipamiento con ese id, suma su cargo por daño multiplicado por la cantidad dañada.
      if (coincidencias.isNotEmpty) {
        final Equipamiento eq = coincidencias.first;
        total += eq.cargoPorDanio * entry.value;
      }
    }
    return total;
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

  Reserva? crearReserva() {
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
      fechaInicio: fechaDesde,
      fechaFin: fechaHasta,
      estado: estado,
      cargoDanios: totalCargoDanios,
      itemsDaniados: Map.from(cantidadesDaniadas),
    );
  }

  void dispose() {}
}
