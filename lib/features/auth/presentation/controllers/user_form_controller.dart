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
    rol = TipoRol.usuario;
    activo = true;
  }

  // Construye un Usuario a partir de los datos del formulario.
  Usuario construirUsuario() {
    return Usuario(
      id: seleccionado?.id ?? DateTime.now().millisecondsSinceEpoch,
      nombre: nombre.text.trim(),
      apellidos: apellidos.text.trim(),
      email: email.text.trim(),
      telefono: telefono.text.trim().isEmpty ? null : telefono.text.trim(),
      rol: rol,
      activo: activo,
      foto: foto,
    );
  }

  void dispose() {
    nombre.dispose();
    apellidos.dispose();
    email.dispose();
    telefono.dispose();
  }
}

