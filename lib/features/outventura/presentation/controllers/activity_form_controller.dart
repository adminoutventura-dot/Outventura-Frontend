import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

class ActivityFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Elimina precio, añade título y unifica el punto de encuentro
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController puntoInicioFinController =
      TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController participantesController = TextEditingController();

  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay horaInicio = TimeOfDay.now();
  TimeOfDay horaFin = TimeOfDay.now();

  int dificultad = 1;
  String? imagenAsset;
  List<Category> categories = [];
  Map<int, int> materialesRecomendados = {};

  int? guideId;

  bool editando = false;
  Activity? seleccionada;

  bool validar() {
    return formKey.currentState?.validate() ?? false;
  }

  void cargarActividad(Activity actividad) {
    editando = true;
    seleccionada = actividad;

    tituloController.text = actividad.title;
    puntoInicioFinController.text = actividad.startEndPoint ?? '';
    descripcionController.text = actividad.description ?? '';
    participantesController.text = actividad.maxParticipants.toString();

    fechaInicio = actividad.initDate;
    horaInicio = TimeOfDay(
      hour: actividad.initDate.hour,
      minute: actividad.initDate.minute,
    );

    fechaFin = actividad.endDate;
    horaFin = TimeOfDay(
      hour: actividad.endDate.hour,
      minute: actividad.endDate.minute,
    );

    dificultad = actividad.difficulty;
    imagenAsset = actividad.imageAsset;
    categories = List.from(actividad.categories);

    guideId = actividad.guideId;

    // La entidad de actividad ya no tiene el mapa de cantidades.
    // Para no romper la UI, asigna cantidad 1 por defecto a cada material recomendado.
    materialesRecomendados = {
      for (final id in actividad.recommendedEquipmentIds) id: 1,
    };
  }

  void alternarCategoria(Category cat) {
    if (categories.contains(cat)) {
      categories.remove(cat);
    } else {
      categories.add(cat);
    }
  }

  void establecerFecha({required bool isStart, required DateTime value}) {
    if (isStart) {
      fechaInicio = value;
      // Valida que el fin no sea antes que el inicio
      if (fechaFin.isBefore(fechaInicio)) {
        fechaFin = fechaInicio;
      }
    } else {
      fechaFin = value;
    }
  }

  Activity construirActividad() {
    final initDateTime = DateTime(
      fechaInicio.year,
      fechaInicio.month,
      fechaInicio.day,
      horaInicio.hour,
      horaInicio.minute,
    );
    final endDateTime = DateTime(
      fechaFin.year,
      fechaFin.month,
      fechaFin.day,
      horaFin.hour,
      horaFin.minute,
    );

    return Activity(
      id: seleccionada?.id,
      title: tituloController.text.trim(),
      description: descripcionController.text.trim().isEmpty
          ? null
          : descripcionController.text.trim(),
      initDate: initDateTime,
      endDate: endDateTime,
      difficulty: dificultad,
      maxParticipants: int.tryParse(participantesController.text) ?? 1,
      startEndPoint: puntoInicioFinController.text.trim().isEmpty
          ? null
          : puntoInicioFinController.text.trim(),
      categories: categories,
      imageAsset: imagenAsset,
      // Extrae solo las keys (los IDs) del mapa para enviar al backend
      recommendedEquipmentIds: materialesRecomendados.keys.toList(),
      
      guideId: guideId,
    );
  }

  void dispose() {
    tituloController.dispose();
    puntoInicioFinController.dispose();
    descripcionController.dispose();
    participantesController.dispose();
  }
}