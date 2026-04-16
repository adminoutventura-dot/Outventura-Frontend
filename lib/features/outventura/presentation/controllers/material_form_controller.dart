import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/material.dart' as mat;

class MaterialFormController {
  final formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final stockController = TextEditingController();
  final precioController = TextEditingController();
  final tarifaController = TextEditingController();

  List<CategoriaActividad> categorias = [];
  mat.EstadoMaterial estado = mat.EstadoMaterial.disponible;
  bool isEditing = false;

  mat.Material? seleccionado;

  // Cargar los datos de un material
  void cargarMaterial(mat.Material material) {
    isEditing = true;
    seleccionado = material;
    nombreController.text = material.nombre;
    descripcionController.text = material.descripcion ?? '';
    stockController.text = '${material.stock}';
    precioController.text = material.precioAlquilerDiario.toStringAsFixed(2);
    tarifaController.text = material.tarifaDanios.toStringAsFixed(2);
    categorias = List.from(material.categorias);
    estado = material.estado;
  }

  // Limpiar todos los campos
  void limpiar() {
    isEditing = false;
    seleccionado = null;
    nombreController.clear();
    descripcionController.clear();
    stockController.clear();
    precioController.clear();
    tarifaController.clear();
    categorias = [];
    estado = mat.EstadoMaterial.disponible;
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

  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    stockController.dispose();
    precioController.dispose();
    tarifaController.dispose();
  }
}