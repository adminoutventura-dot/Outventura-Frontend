import 'package:flutter/material.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

class SolicitudFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController participantesCtrl = TextEditingController();

  int? idExcursion;
  int get numeroParticipantes => int.tryParse(participantesCtrl.text) ?? 1;
  EstadoSolicitud estado = EstadoSolicitud.pendiente;
  int? idExperto;
  int? idUsuario;
  int? idReserva;
  Map<int, int> materialesSolicitados = {};

  bool editando = false;
  Solicitud? seleccionado;

  bool validar() {
    if (formKey.currentState == null) return false;
    return formKey.currentState!.validate();
  }

  void cargarSolicitud(Solicitud solicitud) {
    editando = true;
    seleccionado = solicitud;
    idExcursion = solicitud.idExcursion;
    participantesCtrl.text = '${solicitud.numeroParticipantes}';
    estado = solicitud.estado;
    idExperto = solicitud.idExperto;
    idUsuario = solicitud.idUsuario;
    idReserva = solicitud.idReserva;
    materialesSolicitados = Map<int, int>.from(solicitud.materialesSolicitados);
  }

  void aplicarValoresIniciales({int? idExcursion, int? idUsuario}) {
    this.idExcursion = idExcursion;
    this.idUsuario = idUsuario;
    if (participantesCtrl.text.trim().isEmpty) {
      participantesCtrl.text = '1';
    }
  }

  void recalcularMaterialesDesdePlantilla(Map<int, int> porParticipante) {
    final int participantes = numeroParticipantes;
    final Map<int, int> recalculado = {};

    porParticipante.forEach((int idEquipamiento, int cantidadPorPersona) {
      final int cantidad = cantidadPorPersona * participantes;
      if (cantidad > 0) {
        recalculado[idEquipamiento] = cantidad;
      }
    });

    materialesSolicitados = recalculado;
  }

  // Calcula el total de materiales solicitados sumando las cantidades de cada equipamiento.
  void establecerCantidadMaterial(int idEquipamiento, int cantidad) {
    if (cantidad <= 0) {
      materialesSolicitados.remove(idEquipamiento);
      return;
    }
    materialesSolicitados[idEquipamiento] = cantidad;
  }

  Solicitud? crearSolicitud() {
    if (!validar()) {
      return null;
    }

    final int id = seleccionado?.id ?? GeneradorId.idEntero();

    return Solicitud(
      id: id,
      idExcursion: idExcursion!,
      numeroParticipantes: numeroParticipantes,
      estado: estado,
      idExperto: idExperto,
      idUsuario: idUsuario,
      idReserva: idReserva,
      materialesSolicitados: Map<int, int>.from(materialesSolicitados),
    );
  }

  void limpiar() {
    editando = false;
    seleccionado = null;
    idExcursion = null;
    participantesCtrl.clear();
    estado = EstadoSolicitud.pendiente;
    idExperto = null;
    idUsuario = null;
    idReserva = null;
    materialesSolicitados = {};
  }

  void dispose() {
    participantesCtrl.dispose();
  }
}
