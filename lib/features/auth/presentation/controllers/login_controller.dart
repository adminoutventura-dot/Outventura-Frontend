import 'package:flutter/material.dart';
import 'package:outventura/core/utils/form_validators.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool ocultarContrasena = true;
  bool ocultarConfirmacionContrasena = true;

  String? validadorContrasena(bool editando, String? value) {
    if (!editando && (value == null || value.isEmpty)) {
      return 'La contraseña es obligatoria';
    }
    if (value != null && value.isNotEmpty) {
      final error = ValidadoresFormulario.longitudMinima(value, 8);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  String? validadorConfirmacionContrasena(bool editando, String? value) {
    if (!editando && (value == null || value.isEmpty)) {
      return 'Confirma la contraseña';
    }
    if (value != null && value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}