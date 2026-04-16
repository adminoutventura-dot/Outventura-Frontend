import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

class ExcursionFormController {
  final formKey = GlobalKey<FormState>();

  final puntoInicioController = TextEditingController();
  final puntoFinController = TextEditingController();
  final descripcionController = TextEditingController();
  final participantesController = TextEditingController();

  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now().add(const Duration(days: 1));
  EstadoExcursion estado = EstadoExcursion.disponible;
  List<CategoriaActividad> categorias = [];
  bool isEditing = false;

  Excursion? seleccionado;

  // Cargar los datos de una excursión en los input
  void cargarExcursion(Excursion excursion) {
    isEditing = true;
    seleccionado = excursion;
    puntoInicioController.text = excursion.puntoInicio;
    puntoFinController.text = excursion.puntoFin;
    descripcionController.text = excursion.descripcion ?? '';
    participantesController.text = '${excursion.numeroParticipantes}';
    fechaInicio = excursion.fechaInicio;
    fechaFin = excursion.fechaFin;
    estado = excursion.estado;
    categorias = List.from(excursion.categorias);
  }

  // Limpiar todos los campos
  void limpiar() {
    isEditing = false;
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
    if (categorias.isEmpty) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  bool get hasCategorias => categorias.isNotEmpty;

  String formatDate(DateTime dt) {
    const m = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
  }

  void dispose() {
    puntoInicioController.dispose();
    puntoFinController.dispose();
    descripcionController.dispose();
    participantesController.dispose();
  }
}