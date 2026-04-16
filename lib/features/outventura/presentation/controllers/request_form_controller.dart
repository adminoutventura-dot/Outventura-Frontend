import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

class SolicitudFormController {
  final formKey = GlobalKey<FormState>();

  final puntoInicioCtrl = TextEditingController();
  final puntoFinCtrl = TextEditingController();
  final participantesCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();

  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now().add(const Duration(days: 1));
  List<CategoriaActividad> categorias = [];
  EstadoSolicitud estado = EstadoSolicitud.pendiente;
  int? idExperto;

  bool isEditing = false;
  Solicitud? selected;

  void cargarRequest(Solicitud s) {
    isEditing = true;
    selected = s;
    puntoInicioCtrl.text = s.puntoInicio;
    puntoFinCtrl.text = s.puntoFin;
    participantesCtrl.text = '${s.numeroParticipantes}';
    descripcionCtrl.text = s.descripcion ?? '';
    fechaInicio = s.fechaInicio;
    fechaFin = s.fechaFin;
    categorias = List.from(s.categorias);
    estado = s.estado;
    idExperto = s.idExperto;
  }

  void limpiar() {
    isEditing = false;
    selected = null;
    puntoInicioCtrl.clear();
    puntoFinCtrl.clear();
    participantesCtrl.clear();
    descripcionCtrl.clear();
    fechaInicio = DateTime.now();
    fechaFin = DateTime.now().add(const Duration(days: 1));
    categorias = [];
    estado = EstadoSolicitud.pendiente;
    idExperto = null;
  }

  void setDate({required bool isStart, required DateTime value}) {
    if (isStart) {
      fechaInicio = value;
      if (fechaFin.isBefore(value)) {
        fechaFin = value.add(const Duration(days: 1));
      }
      return;
    }
    fechaFin = value;
  }

  void toggleCategoria(CategoriaActividad cat) {
    if (categorias.contains(cat)) {
      categorias.remove(cat);
    } else {
      categorias.add(cat);
    }
  }

  bool submit() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  void dispose() {
    puntoInicioCtrl.dispose();
    puntoFinCtrl.dispose();
    participantesCtrl.dispose();
    descripcionCtrl.dispose();
  }
}
