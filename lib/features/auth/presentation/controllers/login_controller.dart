import 'package:flutter/material.dart';
import 'package:outventura/l10n/app_localizations.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool ocultarContrasena = true;
  bool ocultarConfirmacionContrasena = true;

  String? validadorContrasena(bool editando, String? value, AppLocalizations s) {
    if (!editando && (value == null || value.isEmpty)) {
      return s.passwordRequired;
    }
    if (value != null && value.isNotEmpty && value.length < 6) {
      return s.minSixChars;
    }
    return null;
  }

  String? validadorConfirmacionContrasena(bool editando, String? value, AppLocalizations s) {
    if (!editando && (value == null || value.isEmpty)) {
      return s.confirmPasswordRequired;
    }
    if (value != null && value != passwordController.text) {
      return s.passwordsDoNotMatch;
    }
    return null;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}