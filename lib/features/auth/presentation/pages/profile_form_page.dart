import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/controllers/user_form_controller.dart';
import 'package:outventura/l10n/app_localizations.dart';

class ProfileFormPage extends StatefulWidget {
  final User usuario;
  const ProfileFormPage({super.key, required this.usuario});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  late final UserFormController _controller;
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _controller = UserFormController()..cargarUsuario(widget.usuario);
    _loginController = LoginController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _loginController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.validar()) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.editProfile),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.profileHeader(cs),
          ),
        ),
      ),
      body: Form(
        key: _controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).padding.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: widget.usuario.photo != null
                      ? NetworkImage(widget.usuario.photo!)
                      : null,
                  child: widget.usuario.photo == null
                      ? Icon(Icons.person_outline, size: 44, color: cs.onPrimaryContainer)
                      : null,
                ),
              ),
              const SizedBox(height: 28),

              // Datos personales
              Text(s.personalData, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              CustomInputField(
                controller: _controller.nombre,
                labelText: s.name,
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? s.fieldRequired : null,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.apellidos,
                labelText: s.surname,
                prefixIcon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? s.fieldRequired : null,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.email,
                labelText: s.email,
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: ValidadoresFormulario.email(s),
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.telefono,
                labelText: s.phoneOptional,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // Cambiar contraseña
              Text(s.changePassword, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              CustomInputField(
                controller: _loginController.passwordController,
                labelText: s.newPasswordOptional,
                prefixIcon: Icons.lock_outline,
                obscureText: _loginController.ocultarContrasena,
                validator: (v) => _loginController.validadorContrasena(true, v, s),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _loginController.ocultarContrasena = !_loginController.ocultarContrasena),
                  icon: Icon(
                    _loginController.ocultarContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _loginController.confirmPasswordController,
                labelText: s.confirmNewPassword,
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: _loginController.ocultarConfirmacionContrasena,
                validator: (v) => _loginController.validadorConfirmacionContrasena(true, v, s),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _loginController.ocultarConfirmacionContrasena = !_loginController.ocultarConfirmacionContrasena),
                  icon: Icon(
                    _loginController.ocultarConfirmacionContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: s.save,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

