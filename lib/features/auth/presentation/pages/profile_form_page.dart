import 'package:flutter/material.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
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
    final User usuarioActualizado = _controller.construirUsuario();

    final String? nuevaPassword = _loginController.passwordController.text.isNotEmpty
        ? _loginController.passwordController.text
        : null;

    Navigator.of(context).pop(<String, dynamic>{
      'usuario': usuarioActualizado,
      'password': nuevaPassword,
    });
  }

  void _mostrarDialogoDesactivar() async {
    final bool confirmar = await showConfirmDialog(
      context: context,
      title: 'Desactivar cuenta',
      content: '¿Estás seguro de que quieres desactivar tu cuenta?',
      confirmLabel: 'Desactivar',
    );
    if (confirmar && mounted) {
      Navigator.of(context).pop({'desactivar': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: s.editProfile,
      ),
      body: Form(
        key: _controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 65),

              // Avatar
              Center(
                child: AppImagePickerField(
                  imageUrl: _controller.foto,
                  isAsset: true,
                  isCircular: true,
                  placeholder: Icons.person_outline,
                  onChanged: (String? nuevaRuta) {
                    setState(() {
                      _controller.foto = nuevaRuta;
                    });
                  },
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
              const SizedBox(height: 16),

              // Botón Desactivar cuenta
              if (widget.usuario.active)
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: 'Desactivar cuenta',
                    onPressed: () => _mostrarDialogoDesactivar(),
                    borderColor: cs.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

