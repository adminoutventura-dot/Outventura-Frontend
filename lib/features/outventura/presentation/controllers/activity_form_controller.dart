import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

class ActivityFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController puntoInicioController = TextEditingController();
  final TextEditingController puntoFinController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController participantesController = TextEditingController();
  late final TextEditingController precioController = TextEditingController(text: '0');

  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now().add(const Duration(days: 1));
  TimeOfDay horaInicio = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay horaFin = const TimeOfDay(hour: 17, minute: 0);
  ActivityStatus estado = ActivityStatus.disponible;
  List<ActivityCategory> categorias = [];
  String? imagenAsset;
  bool editando = false;

  Activity? seleccionado;

  bool validar() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }
  
  void alternarCategoria(ActivityCategory cat) {
    if (categorias.contains(cat)) {
      categorias.remove(cat);
    } else {
      categorias.add(cat);
    }
  }

  // Cargar los datos de una actividad en los inputs
  void cargarActividad(Activity actividad) {
    editando = true;
    seleccionado = actividad;
    puntoInicioController.text = actividad.startPoint;
    puntoFinController.text = actividad.endPoint;
    descripcionController.text = actividad.description ?? '';
    participantesController.text = '${actividad.maxParticipants}';
    fechaInicio = actividad.initDate;
    fechaFin = actividad.endDate;
    horaInicio = TimeOfDay.fromDateTime(actividad.initDate);
    horaFin = TimeOfDay.fromDateTime(actividad.endDate);
    estado = actividad.status;
    categorias = List<ActivityCategory>.from(actividad.categories);
    imagenAsset = actividad.imageAsset;
    precioController.text = actividad.price.toStringAsFixed(2);
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
    horaInicio = const TimeOfDay(hour: 9, minute: 0);
    horaFin = const TimeOfDay(hour: 17, minute: 0);
    estado = ActivityStatus.disponible;
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

  // Construye una actividad a partir de los datos del formulario.
  Activity construirActividad() {
    final String puntoInicio = puntoInicioController.text.trim();
    final String puntoFin = puntoFinController.text.trim();
    return Activity(
      id: seleccionado?.id ?? GeneradorId.idEntero(),
      title: [puntoInicio, puntoFin].where((e) => e.isNotEmpty).join(' - '),
      description: descripcionController.text.trim().isEmpty ? null : descripcionController.text.trim(),
      initDate: fechaInicio.copyWith(hour: horaInicio.hour, minute: horaInicio.minute, second: 0),
      endDate: fechaFin.copyWith(hour: horaFin.hour, minute: horaFin.minute, second: 0),
      difficulty: seleccionado?.difficulty ?? 1,
      maxParticipants: int.tryParse(participantesController.text) ?? 1,
      startEndPoint: [puntoInicio, puntoFin].where((e) => e.isNotEmpty).join(' - '),
      categories: List<ActivityCategory>.from(categorias),
      imageAsset: imagenAsset,
      status: estado,
      price: double.tryParse(precioController.text.replaceAll(',', '.')) ?? 0,
      materialsPerParticipant: seleccionado?.materialsPerParticipant ?? {},
    );
  }

  void dispose() {
    puntoInicioController.dispose();
    puntoFinController.dispose();
    descripcionController.dispose();
    participantesController.dispose();
    precioController.dispose();
  }
}