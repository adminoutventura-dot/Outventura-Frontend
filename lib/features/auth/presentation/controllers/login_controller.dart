import 'package:flutter/material.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool ocultarContrasena = true;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}