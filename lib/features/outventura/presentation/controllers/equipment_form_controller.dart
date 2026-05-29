import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

class EquipmentFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController stockTotalController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController tarifaController = TextEditingController();

  List<Category> categorias = [];
  int? statusId;
  String? imagenAsset;
  bool editando = false;
  Equipment? seleccionado;

  bool validar() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  void alternarCategoria(Category cat) {
    if (categorias.contains(cat)) {
      categorias.remove(cat);
    } else {
      categorias.add(cat);
    }
  }

  void cargarEquipo(Equipment equipamiento) {
    editando = true;
    seleccionado = equipamiento;
    nombreController.text = equipamiento.title;
    descripcionController.text = equipamiento.description ?? '';
    stockTotalController.text = '${equipamiento.totalUnits}';
    precioController.text = equipamiento.pricePerDay.toStringAsFixed(2);
    tarifaController.text = equipamiento.damageFee.toStringAsFixed(2);
    categorias = List<Category>.from(equipamiento.categories);
    statusId = equipamiento.statusId;
    imagenAsset = equipamiento.imageAsset;
  }

  Equipment? crearEquipamiento() {
    if (!validar() || statusId == null) {
      return null;
    }

    return Equipment(
      id: seleccionado?.id,
      title: nombreController.text.trim(),
      description: descripcionController.text.trim().isEmpty
          ? null
          : descripcionController.text.trim(),
      categories: List<Category>.from(categorias),
      // Al crear, units (disponibles) hereda el valor total inicial
      availableUnits: int.tryParse(stockTotalController.text) ?? 0,
      totalUnits: int.tryParse(stockTotalController.text) ?? 0,
      statusId: statusId!,
      pricePerDay: double.tryParse(precioController.text) ?? 0,
      damageFee: double.tryParse(tarifaController.text) ?? 0,
      imageAsset: imagenAsset,
    );
  }

  void limpiar() {
    editando = false;
    seleccionado = null;
    nombreController.clear();
    descripcionController.clear();
    stockTotalController.clear();
    precioController.clear();
    tarifaController.clear();
    categorias = [];
    statusId = null;
    imagenAsset = null;
  }

  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    stockTotalController.dispose();
    precioController.dispose();
    tarifaController.dispose();
  }
}
