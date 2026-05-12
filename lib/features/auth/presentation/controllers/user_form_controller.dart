import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

class UserFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellidos = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController telefono = TextEditingController();

  TipoRol rol = TipoRol.usuario;
  bool activo = true;
  String? foto;
  bool editando = false;

  Usuario? seleccionado;

  bool validar() {
    return formKey.currentState?.validate() ?? false;
  }

  // Cargar los datos
  void cargarUsuario(Usuario usuario) {
    editando = true;
    seleccionado = usuario;
    nombre.text = usuario.name;
    apellidos.text = usuario.surname;
    email.text = usuario.email;
    telefono.text = usuario.phone ?? '';
    rol = usuario.role;
    activo = usuario.active;
    foto = usuario.photo;
  }

  // Limpiar todos los campos
  void limpiar() {
    editando = false;
    seleccionado = null;
    nombre.clear();
    apellidos.clear();
    email.clear();
    telefono.clear();
    rol = TipoRol.usuario;
    activo = true;
  }

  // Construye un Usuario a partir de los datos del formulario.
  Usuario construirUsuario() {
    return Usuario(
      id: seleccionado?.id ?? DateTime.now().millisecondsSinceEpoch,
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
  }
}

