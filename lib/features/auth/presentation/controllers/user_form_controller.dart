import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

class UserFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellidos = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController credenciales = TextEditingController();

  List<Category> categoriasGuia = [];

  UserRole rol = UserRole.usuario;
  bool activo = true;
  String? foto;
  bool editando = false;

  User? seleccionado;

  bool validar() {
    return formKey.currentState?.validate() ?? false;
  }

  // Cargar los datos
  void cargarUsuario(User usuario, {List<Category>? categoriasGuia, String? credencialesGuia}) {
    editando = true;
    seleccionado = usuario;
    nombre.text = usuario.name;
    apellidos.text = usuario.surname;
    email.text = usuario.email;
    telefono.text = usuario.phone ?? '';
    rol = usuario.role;
    activo = usuario.active;
    foto = usuario.photo;
    this.categoriasGuia = categoriasGuia ?? [];
    credenciales.text = credencialesGuia ?? '';
  }

  // Limpiar todos los campos
  void limpiar() {
    editando = false;
    seleccionado = null;
    nombre.clear();
    apellidos.clear();
    email.clear();
    telefono.clear();
    credenciales.clear();
    categoriasGuia = [];
    rol = UserRole.usuario;
    activo = true;
  }

  // Construye un Usuario a partir de los datos del formulario.
  User construirUsuario() {
    return User(
      id: seleccionado?.id,
      name: nombre.text.trim(),
      surname: apellidos.text.trim(),
      email: email.text.trim(),
      phone: telefono.text.trim().isEmpty ? null : telefono.text.trim(),
      role: rol,
      active: activo,
      photo: foto,
    );
  }

  void dispose() {
    nombre.dispose();
    apellidos.dispose();
    email.dispose();
    telefono.dispose();
    credenciales.dispose();
  }
}

