import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

class ExcursionFormController {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController puntoInicioController;
  late final TextEditingController puntoFinController;
  late final TextEditingController descripcionController;
  late final TextEditingController participantesController;

  late DateTime fechaInicio;
  late DateTime fechaFin;
  late EstadoExcursion estado;
  late List<CategoriaActividad> categorias;
  late bool isEditing;

  void initialize(Excursion? excursion) {
    final escursion = excursion;
    isEditing = escursion != null;
    puntoInicioController = TextEditingController(text: escursion?.puntoInicio ?? '');
    puntoFinController = TextEditingController(text: escursion?.puntoFin ?? '');
    descripcionController = TextEditingController(text: escursion?.descripcion ?? '');
    participantesController = TextEditingController(
      text: escursion != null ? '${escursion.numeroParticipantes}' : '',
    );
    fechaInicio = escursion?.fechaInicio ?? DateTime.now();
    fechaFin = escursion?.fechaFin ?? DateTime.now().add(const Duration(days: 1));
    estado = escursion?.estado ?? EstadoExcursion.disponible;
    categorias = List.from(escursion?.categorias ?? []);
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
    categorias.contains(cat) ? categorias.remove(cat) : categorias.add(cat);
  }

  bool submit() {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (categorias.isEmpty) return false;
    return true;
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