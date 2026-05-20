import 'package:flutter/material.dart';

// Controlador para campos de búsqueda usados en formularios.
class SearchFieldController {
  // Controlador de texto que debe pasarse al `TextField`.
  final TextEditingController controller = TextEditingController();
  // Consulta actual
  String query = '';

  // Limpia el campo y la query asociada.
  void clear() {
    controller.clear();
    query = '';
  }

  // Liberar recursos cuando se descarte el formulario/página.
  void dispose() => controller.dispose();
}
