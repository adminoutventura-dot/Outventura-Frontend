import 'package:flutter/material.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

class EquipmentFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController stockTotalController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController tarifaController = TextEditingController();

  List<CategoriaActividad> categorias = [];
  EstadoEquipamiento estado = EstadoEquipamiento.disponible;
  String? imagenAsset;
  bool editando = false;

  Equipamiento? seleccionado;

  // Valida el formulario antes de enviarlo.
  bool validar() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  // Alternar la selección de una categoría
  void alternarCategoria(CategoriaActividad cat) {
    if (categorias.contains(cat)) {
      categorias.remove(cat);
    } else {
      categorias.add(cat);
    }
  }

  // Cargar los datos de un material
  void cargarEquipo(Equipamiento equipamiento) {
    editando = true;
    seleccionado = equipamiento;
    nombreController.text = equipamiento.nombre;
    descripcionController.text = equipamiento.descripcion ?? '';
    stockController.text = '${equipamiento.stock}';
    stockTotalController.text = '${equipamiento.stockTotal}';
    // toStringAsFixed(2) convierte un double a String con exactamente 2 decimales.
    precioController.text = equipamiento.precioAlquilerDiario.toStringAsFixed(2);
    tarifaController.text = equipamiento.cargoPorDanio.toStringAsFixed(2);
    categorias = List<CategoriaActividad>.from(equipamiento.categorias);
    estado = equipamiento.estado;
    imagenAsset = equipamiento.imagenAsset;
  }

  // Construye el objeto Equipamiento con los datos del formulario.
  Equipamiento? crearEquipamiento() {
    if (!validar()) {
      return null;
    }
    
    final int id = seleccionado?.id ?? GeneradorId.idEntero();
    return Equipamiento(
      id: id,
      nombre: nombreController.text.trim(),
      descripcion: descripcionController.text.trim().isEmpty ? null : descripcionController.text.trim(),
      categorias: List<CategoriaActividad>.from(categorias),
      stock: int.tryParse(stockController.text) ?? 0,
      stockTotal: int.tryParse(stockTotalController.text) ?? 0,
      estado: estado,
      precioAlquilerDiario: double.tryParse(precioController.text) ?? 0,
      cargoPorDanio: double.tryParse(tarifaController.text) ?? 0,
      imagenAsset: imagenAsset,
    );
  }

  // Limpiar todos los campos
  void limpiar() {
    editando = false;
    seleccionado = null;
    nombreController.clear();
    descripcionController.clear();
    stockController.clear();
    precioController.clear();
    tarifaController.clear();
    categorias = [];
    estado = EstadoEquipamiento.disponible;
  }

  // Libera de la memoria los TextEditingController
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    stockController.dispose();
    precioController.dispose();
    tarifaController.dispose();
  }

  
}