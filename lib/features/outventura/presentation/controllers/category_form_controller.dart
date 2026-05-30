import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

class CategoryFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool editando = false;
  Category? seleccionado;

  bool validar() {
    return formKey.currentState?.validate() ?? false;
  }

  void cargarCategoria(Category categoria) {
    editando = true;
    seleccionado = categoria;
    codeController.text = categoria.code;
    descriptionController.text = categoria.description ?? '';
  }

  Category? construirCategoria() {
    if (!validar()) {
      return null;
    }

    return Category(
      id: seleccionado?.id,
      code: codeController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    );
  }

  void dispose() {
    codeController.dispose();
    descriptionController.dispose();
  }
}
