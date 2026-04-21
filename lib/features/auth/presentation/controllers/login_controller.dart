import 'package:flutter/material.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool ocultarContrasena = true;

  // TODO: Esto creo que esta repetido eln validciones globales
  String? validadorEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, introduce un correo';
    }

    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');

    if (!emailRegex.hasMatch(value)) {
      return 'Introduce un correo válido';
    }
    return null;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}