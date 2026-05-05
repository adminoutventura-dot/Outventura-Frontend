import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/controllers/user_form_controller.dart';
import 'package:outventura/features/auth/presentation/controllers/profile_form_controller.dart';
import 'package:outventura/features/auth/data/services/user_api_service.dart';

class ProfileFormPage extends ConsumerStatefulWidget {
  final Usuario usuario;
  const ProfileFormPage({super.key, required this.usuario});

  @override
  ConsumerState<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends ConsumerState<ProfileFormPage> {
  late final ProfileFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileFormController(
      form: UserFormController()..cargarUsuario(widget.usuario),
      login: LoginController(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_controller.validar()) return;
    try {
      await ref.read(userApiProvider).update(widget.usuario.id, _controller.buildPayload());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surfaceContainer,
        foregroundColor: cs.onSurfaceVariant,
        title: Text(
          'Editar perfil',
          style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
      body: Form(
        key: _controller.form.formKey,
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
                controller: _controller.form.nombre,
                labelText: 'Nombre',
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.form.apellidos,
                labelText: 'Apellidos',
                prefixIcon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.form.email,
                labelText: 'Email',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: ValidadoresFormulario.email,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.form.telefono,
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // Cambiar contraseña
              Text('Cambiar contraseña', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 12),

              CustomInputField(
                controller: _controller.login.passwordController,
                labelText: 'Nueva contraseña (opcional)',
                prefixIcon: Icons.lock_outline,
                obscureText: _controller.login.ocultarContrasena,
                validator: (v) => _controller.login.validadorContrasena(true, v),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _controller.login.ocultarContrasena = !_controller.login.ocultarContrasena),
                  icon: Icon(
                    _controller.login.ocultarContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.login.confirmPasswordController,
                labelText: 'Confirmar nueva contraseña',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: _controller.login.ocultarConfirmacionContrasena,
                validator: (v) => _controller.login.validadorConfirmacionContrasena(true, v),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _controller.login.ocultarConfirmacionContrasena = !_controller.login.ocultarConfirmacionContrasena),
                  icon: Icon(
                    _controller.login.ocultarConfirmacionContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Guardar',
                  icon: Icons.save_outlined,
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

