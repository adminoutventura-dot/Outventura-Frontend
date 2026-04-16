import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

class UserFormController {
  final formKey = GlobalKey<FormState>();

  final nombre = TextEditingController();
  final apellidos = TextEditingController();
  final email = TextEditingController();
  final telefono = TextEditingController();
  final password = TextEditingController();

  TipoRol rol = TipoRol.usuario;
  bool activo = true;
  bool isEditing = false;

  Usuario? seleccionado;

  // Cargar los datos
  void cargarUsuario(Usuario usuario) {
    isEditing = true;
    seleccionado = usuario;
    nombre.text = usuario.nombre;
    apellidos.text = usuario.apellidos;
    email.text = usuario.email;
    telefono.text = usuario.telefono ?? '';
    rol = usuario.rol;
    activo = usuario.activo;
  }

  // Limpiar todos los campos
  void limpiar() {
    isEditing = false;
    seleccionado = null;
    nombre.clear();
    apellidos.clear();
    email.clear();
    telefono.clear();
    password.clear();
    rol = TipoRol.usuario;
    activo = true;
  }

  bool submit() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  void dispose() {
    nombre.dispose();
    apellidos.dispose();
    email.dispose();
    telefono.dispose();
    password.dispose();
  }
}
