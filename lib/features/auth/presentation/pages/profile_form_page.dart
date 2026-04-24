import 'package:flutter/material.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/controllers/user_form_controller.dart';

class ProfileFormPage extends StatefulWidget {
  final Usuario usuario;
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.inverseSurface,
        foregroundColor: cs.onInverseSurface,
        title: Text(
          'Editar perfil',
          style: tt.titleMedium?.copyWith(color: cs.onInverseSurface),
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
                  backgroundImage: widget.usuario.foto != null
                      ? NetworkImage(widget.usuario.foto!)
                      : null,
                  child: widget.usuario.foto == null
                      ? Icon(Icons.person_outline, size: 44, color: cs.onPrimaryContainer)
                      : null,
                ),
              ),
              const SizedBox(height: 28),

              // Datos personales
              Text('Datos personales', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              CustomInputField(
                controller: _controller.nombre,
                labelText: 'Nombre',
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.apellidos,
                labelText: 'Apellidos',
                prefixIcon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.email,
                labelText: 'Email',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: ValidadoresFormulario.email,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.telefono,
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // Cambiar contraseña
              Text('Cambiar contraseña', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              CustomInputField(
                controller: _loginController.passwordController,
                labelText: 'Nueva contraseña (opcional)',
                prefixIcon: Icons.lock_outline,
                obscureText: _loginController.ocultarContrasena,
                validator: (v) => _loginController.validadorContrasena(true, v),
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
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: _loginController.ocultarConfirmacionContrasena,
                validator: (v) => _loginController.validadorConfirmacionContrasena(true, v),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _loginController.ocultarConfirmacionContrasena = !_loginController.ocultarConfirmacionContrasena),
                  icon: Icon(
                    _loginController.ocultarConfirmacionContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Guardar',
                      icon: Icons.save_outlined,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

