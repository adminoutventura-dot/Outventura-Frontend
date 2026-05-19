import 'package:flutter/material.dart';
import 'package:outventura/l10n/app_localizations.dart';

class RegisterController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool ocultarPassword = true;
  bool ocultarConfirm = true;

  String? validadorPassword(String? value, AppLocalizations s) {
    if (value == null || value.isEmpty) {
      return s.passwordRequired;
    }
    if (value.length < 8) {
      return s.minSixChars;
    }
    return null;
  }

  String? validadorConfirmacion(String? value, AppLocalizations s) {
    if (value == null || value.isEmpty) {
      return s.confirmPasswordRequired;
    }
    if (value != passwordController.text) {
      return s.passwordsDoNotMatch;
    }
    return null;
  }

  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
