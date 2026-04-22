import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

class UserFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellidos = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController password = TextEditingController();

  TipoRol rol = TipoRol.usuario;
  bool activo = true;
  String? foto;
  bool editando = false;

  Usuario? seleccionado;

  bool validar() {
    if (formKey.currentState == null) {
      return false;
    }
    return formKey.currentState!.validate();
  }

  // Cargar los datos
  void cargarUsuario(Usuario usuario) {
    editando = true;
    seleccionado = usuario;
    nombre.text = usuario.nombre;
    apellidos.text = usuario.apellidos;
    email.text = usuario.email;
    telefono.text = usuario.telefono ?? '';
    rol = usuario.rol;
    activo = usuario.activo;
    foto = usuario.foto;
  }

  // Limpiar todos los campos
  void limpiar() {
    editando = false;
    seleccionado = null;
    nombre.clear();
    apellidos.clear();
    email.clear();
    telefono.clear();
    password.clear();
    rol = TipoRol.usuario;
    activo = true;
  }

  void dispose() {
    nombre.dispose();
    apellidos.dispose();
    email.dispose();
    telefono.dispose();
    password.dispose();
  }
}
