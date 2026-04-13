import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/material.dart' as mat;

class MaterialFormController {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nombreController;
  late final TextEditingController descripcionController;
  late final TextEditingController stockController;
  late final TextEditingController precioController;
  late final TextEditingController tarifaController;

  late CategoriaActividad categoria;
  late mat.EstadoMaterial estado;
  late bool isEditing;

  void initialize(mat.Material? material) {
    final m = material;
    isEditing = m != null;
    nombreController = TextEditingController(text: m?.nombre ?? '');
    descripcionController = TextEditingController(text: m?.descripcion ?? '');
    stockController = TextEditingController(text: m != null ? '${m.stock}' : '');
    precioController = TextEditingController(
      text: m != null ? m.precioAlquilerDiario.toStringAsFixed(2) : '',
    );
    tarifaController = TextEditingController(
      text: m != null ? m.tarifaDanios.toStringAsFixed(2) : '',
    );
    categoria = m?.categoria ?? CategoriaActividad.montania;
    estado = m?.estado ?? mat.EstadoMaterial.disponible;
  }

  bool submit() {
    return formKey.currentState?.validate() ?? false;
  }

  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    stockController.dispose();
    precioController.dispose();
    tarifaController.dispose();
  }
}