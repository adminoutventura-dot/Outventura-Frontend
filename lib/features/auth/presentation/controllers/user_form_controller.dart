import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';

class UserFormController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  TipoRol rol = TipoRol.usuario;
  bool activo = true;
  bool ocultarContrasena = true;
  bool ocultarConfirmacionContrasena = true;
  
  Usuario? _usuarioOriginal;
  bool get editando => _usuarioOriginal != null;

  void inicializar(Usuario? usuario) {
    _usuarioOriginal = usuario;
    
    if (usuario != null) {
      nombreController.text = usuario.nombre;
      apellidosController.text = usuario.apellidos;
      emailController.text = usuario.email;
      telefonoController.text = usuario.telefono ?? '';
      rol = usuario.rol;
      activo = usuario.activo;
    }
  }

  bool validar() {
    return formKey.currentState?.validate() ?? false;
  }

  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // Validadores
  String? validadorContrasena(String? value) {
    // Solo requerido si es nuevo usuario
    if (!editando && (value == null || value.isEmpty)) {
      return 'La contraseña es obligatoria';
    }
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  String? validadorConfirmacionContrasena(String? value) {
    if (!editando && (value == null || value.isEmpty)) {
      return 'Confirma la contraseña';
    }
    if (value != null && value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
