import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/controllers/user_form_controller.dart';

class ProfileFormController {
  final UserFormController form;
  final LoginController login;

  ProfileFormController({required this.form, required this.login});

  bool validar() => form.validar();

  // Builds the payload to send to PATCH /users/:id.
  // Includes password only if a new one has been entered.
  Map<String, dynamic> buildPayload() {
    final phone = form.telefono.text.trim();
    final password = login.passwordController.text.trim();

    return {
      'name': form.nombre.text.trim(),
      'surname': form.apellidos.text.trim(),
      'email': form.email.text.trim(),
      'phone': phone.isEmpty ? null : phone,
      if (password.isNotEmpty) 'password': password,
    };
  }

  void dispose() {
    form.dispose();
    login.dispose();
  }
}
