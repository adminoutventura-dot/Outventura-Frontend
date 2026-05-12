import 'package:flutter/material.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

class ExcursionFormController {
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
  EstadoExcursion estado = EstadoExcursion.disponible;
  List<CategoriaActividad> categorias = [];
  String? imagenAsset;
  bool editando = false;

  Activity? seleccionado;

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
  void cargarExcursion(Activity excursion) {
    editando = true;
    seleccionado = excursion;
    puntoInicioController.text = excursion.startPoint;
    puntoFinController.text = excursion.endPoint;
    descripcionController.text = excursion.description ?? '';
    participantesController.text = '${excursion.maxParticipants}';
    fechaInicio = excursion.initDate;
    fechaFin = excursion.endDate;
    horaInicio = TimeOfDay.fromDateTime(excursion.initDate);
    horaFin = TimeOfDay.fromDateTime(excursion.endDate);
    estado = excursion.status;
    categorias = List<CategoriaActividad>.from(excursion.categories);
    imagenAsset = excursion.imageAsset;
    precioController.text = excursion.price.toStringAsFixed(2);
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

  // Construye una excursión a partir de los datos del formulario.
  Activity construirExcursion() {
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
      categories: List<CategoriaActividad>.from(categorias),
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