import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

class ExcursionFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController puntoInicioController = TextEditingController();
  final TextEditingController puntoFinController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController participantesController = TextEditingController();

  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now().add(const Duration(days: 1));
  EstadoExcursion estado = EstadoExcursion.disponible;
  List<CategoriaActividad> categorias = [];
  String? imagenAsset;
  bool editando = false;

  Excursion? seleccionado;

  bool validar() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }
  
  void alternarCategoria(CategoriaActividad cat) {
    if (categorias.contains(cat)) {
      categorias.remove(cat);
    } else {
      categorias.add(cat);
    }
  }

  // Cargar los datos de una excursión en los input
  void cargarExcursion(Excursion excursion) {
    editando = true;
    seleccionado = excursion;
    puntoInicioController.text = excursion.puntoInicio;
    puntoFinController.text = excursion.puntoFin;
    descripcionController.text = excursion.descripcion ?? '';
    participantesController.text = '${excursion.numeroParticipantes}';
    fechaInicio = excursion.fechaInicio;
    fechaFin = excursion.fechaFin;
    estado = excursion.estado;
    categorias = List<CategoriaActividad>.from(excursion.categorias);
    imagenAsset = excursion.imagenAsset;
  }

  // Limpiar todos los campos
  void limpiar() {
    editando = false;
    seleccionado = null;
    puntoInicioController.clear();
    puntoFinController.clear();
    descripcionController.clear();
    participantesController.clear();
    fechaInicio = DateTime.now();
    fechaFin = DateTime.now().add(const Duration(days: 1));
    estado = EstadoExcursion.disponible;
    categorias = [];
  }

  void establecerFecha({required bool isStart, required DateTime value}) {
    if (isStart) {
      fechaInicio = value;
      if (fechaFin.isBefore(value)) {
        fechaFin = value.add(const Duration(days: 1));
      }
      return;
    }
    fechaFin = value;
  }

  String formatearFecha(DateTime dt) {
    return FormateadorFecha.short(dt);
  }

  void dispose() {
    puntoInicioController.dispose();
    puntoFinController.dispose();
    descripcionController.dispose();
    participantesController.dispose();
  }
}