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

  List<ActivityCategory> categorias = [];
  EquipmentStatus estado = EquipmentStatus.disponible;
  String? imagenAsset;
  bool editando = false;

  Equipment? seleccionado;

  // Valida el formulario antes de enviarlo.
  bool validar() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  // Alternar la selección de una categoría
  void alternarCategoria(ActivityCategory cat) {
    if (categorias.contains(cat)) {
      categorias.remove(cat);
    } else {
      categorias.add(cat);
    }
  }

  // Cargar los datos de un material
  void cargarEquipo(Equipment equipamiento) {
    editando = true;
    seleccionado = equipamiento;
    nombreController.text = equipamiento.title;
    descripcionController.text = equipamiento.description ?? '';
    stockController.text = '${equipamiento.units}';
    stockTotalController.text = '${equipamiento.totalUnits}';
    // toStringAsFixed(2) convierte un double a String con exactamente 2 decimales.
    precioController.text = equipamiento.pricePerDay.toStringAsFixed(2);
    tarifaController.text = equipamiento.damageFee.toStringAsFixed(2);
    categorias = List<ActivityCategory>.from(equipamiento.categories);
    estado = equipamiento.status;
    imagenAsset = equipamiento.imageAsset;
  }

  // Construye el objeto Equipamiento con los datos del formulario.
  Equipment? crearEquipamiento() {
    if (!validar()) {
      return null;
    }
    
    final int id = seleccionado?.id ?? GeneradorId.idEntero();
    return Equipment(
      id: id,
      title: nombreController.text.trim(),
      description: descripcionController.text.trim().isEmpty ? null : descripcionController.text.trim(),
      categories: List<ActivityCategory>.from(categorias),
      units: int.tryParse(stockController.text) ?? 0,
      totalUnits: int.tryParse(stockTotalController.text) ?? 0,
      status: estado,
      pricePerDay: double.tryParse(precioController.text) ?? 0,
      damageFee: double.tryParse(tarifaController.text) ?? 0,
      imageAsset: imagenAsset,
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
    estado = EquipmentStatus.disponible;
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