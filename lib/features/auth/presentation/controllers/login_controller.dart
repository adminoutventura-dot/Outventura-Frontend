import 'package:flutter/material.dart';

class LoginController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, introduce un correo';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');

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