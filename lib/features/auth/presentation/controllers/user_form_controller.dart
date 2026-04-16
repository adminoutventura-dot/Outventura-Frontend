import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';

class UserFormController {
  final formKey = GlobalKey<FormState>();
  
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final emailController = TextEditingController();
  final telefonoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  TipoRol rol = TipoRol.usuario;
  bool activo = true;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  
  Usuario? _usuarioOriginal;
  bool get isEditing => _usuarioOriginal != null;

  void initialize(Usuario? usuario) {
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

  bool submit() {
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
  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Introduce un email válido';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    // Solo requerido si es nuevo usuario
    if (!isEditing && (value == null || value.isEmpty)) {
      return 'La contraseña es obligatoria';
    }
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (!isEditing && (value == null || value.isEmpty)) {
      return 'Confirma la contraseña';
    }
    if (value != null && value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
