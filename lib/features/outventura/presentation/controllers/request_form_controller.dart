import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

class RequestFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController participantesCtrl = TextEditingController();

  int? idActividad;
  int get numeroParticipantes => int.tryParse(participantesCtrl.text) ?? 1;
  WorkflowStatus estado = WorkflowStatus.pendiente;
  int? idUsuario;
  Map<int, int> materialesSolicitados = {};

  bool editando = false;
  Booking? seleccionado;

  bool validar() {
    if (formKey.currentState == null) return false;
    return formKey.currentState!.validate();
  }

  void cargarReservaUnificada(Booking reserva) {
    editando = true;
    seleccionado = reserva;
    idUsuario = reserva.userId;
    estado = reserva.status;

    final actLine = reserva.lines
        .where((l) => l.activityId != null)
        .firstOrNull;
    if (actLine != null) {
      idActividad = actLine.activityId;
      participantesCtrl.text = '${actLine.quantity}';
    }

    materialesSolicitados = {};
    for (final line in reserva.lines.where((l) => l.equipmentId != null)) {
      materialesSolicitados[line.equipmentId!] = line.quantity;
    }
  }

  void aplicarValoresIniciales({int? idActividad, int? idUsuario}) {
    this.idActividad = idActividad;
    this.idUsuario = idUsuario;
    if (participantesCtrl.text.trim().isEmpty) {
      participantesCtrl.text = '1';
    }
  }

  void establecerCantidadMaterial(int idEquipamiento, int cantidad) {
    if (cantidad <= 0) {
      materialesSolicitados.remove(idEquipamiento);
      return;
    }
    materialesSolicitados[idEquipamiento] = cantidad;
  }

  Booking? construirReservaDirecta(List<Activity> actividades) {
    if (!validar() || idUsuario == null || idActividad == null) {
      return null;
    }

    final Activity? actividad = actividades
        .where((a) => a.id == idActividad)
        .firstOrNull;
    final DateTime fechaInicio = actividad?.initDate ?? DateTime.now();
    final DateTime fechaFin =
        actividad?.endDate ?? DateTime.now().add(const Duration(hours: 4));

    final List<BookingLine> todasLasLineas = [];
    todasLasLineas.add(
      BookingLine(activityId: idActividad, quantity: numeroParticipantes),
    );

    for (final entry in materialesSolicitados.entries) {
      if (entry.value > 0) {
        todasLasLineas.add(
          BookingLine(equipmentId: entry.key, quantity: entry.value),
        );
      }
    }

    return Booking(
      id: seleccionado?.id,
      userId: idUsuario!,
      lines: todasLasLineas,
      status: estado,
      startDate: fechaInicio,
      endDate: fechaFin,
    );
  }

  Activity? buscarActividadSeleccionada(List<Activity> actividades) {
    if (idActividad == null) return null;
    return actividades.where((e) => e.id == idActividad).firstOrNull;
  }

  // Usa 'recommendedEquipmentIds' de forma nativa como List<int>
  void recalcularMateriales(List<Activity> actividades) {
    final Activity? actividad = buscarActividadSeleccionada(actividades);
    if (actividad == null) {
      materialesSolicitados = {};
      return;
    }

    final Map<int, int> recalculado = {};

    // Al ser un List<int>, iteramos los identificadores directamente
    for (final int idEquipamiento in actividad.recommendedEquipmentIds) {
      recalculado[idEquipamiento] = numeroParticipantes;
    }

    materialesSolicitados = recalculado;
  }

  double calcularPrecioTotal(
    List<Activity> actividades,
    List<Equipment> equipamientos,
  ) {
    final Activity? act = buscarActividadSeleccionada(actividades);
    if (act == null) return 0;

    double total = 0;
    final int dias = act.endDate.difference(act.initDate).inDays.clamp(1, 999);
    final Map<int, Equipment> equipPorId = {
      for (final Equipment e in equipamientos) e.id!: e,
    };

    for (final entry in materialesSolicitados.entries) {
      final Equipment? equip = equipPorId[entry.key];
      if (equip != null) {
        total += equip.pricePerDay * entry.value * dias;
      }
    }

    return total;
  }

  void dispose() {
    participantesCtrl.dispose();
  }
}
