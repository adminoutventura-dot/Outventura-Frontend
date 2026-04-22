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
    );
  }

  void limpiar() {
    editando = false;
    seleccionado = null;
    idExcursion = null;
    participantesCtrl.clear();
    estado = EstadoSolicitud.pendiente;
    idExperto = null;
  }

  void dispose() {
    participantesCtrl.dispose();
  }
}
