import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/presentation/controllers/user_form_controller.dart';

class UserFormPage extends StatefulWidget {
  final Usuario? usuario;
  const UserFormPage({super.key, this.usuario});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  late final UserFormController _controller;
  // TODO: Revisar pagina

  @override
  void initState() {
    super.initState();
    _controller = UserFormController()..inicializar(widget.usuario);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.validar()) return;
    // TODO: guardar usuario
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.inverseSurface,
        foregroundColor: cs.onInverseSurface,
        title: Text(
          _controller.editando ? 'Editar usuario' : 'Nuevo usuario',
          style: tt.titleMedium?.copyWith(color: cs.onInverseSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datos personales',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              CustomInputField(
                controller: _controller.nombreController,
                labelText: 'Nombre',
                prefixIcon: Icons.person_outline,
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.apellidosController,
                labelText: 'Apellidos',
                prefixIcon: Icons.badge_outlined,
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.emailController,
                labelText: 'Email',
                prefixIcon: Icons.mail_outline,
                validator: _controller.validadorEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.telefonoController,
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),
              Text(
                'Rol',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TipoRol.values.map((TipoRol rol) {
                  final bool seleccionado = _controller.rol == rol;
                  return ChoiceChip(
                    label: Text(rol.nombre),
                    selected: seleccionado,
                    onSelected: (_) => setState(() => _controller.rol = rol),
                    selectedColor: cs.primaryContainer,
                    backgroundColor: cs.onPrimary,
                    labelStyle: tt.labelMedium?.copyWith(
                      color: seleccionado ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                    ),
                    side: BorderSide(
                      color: seleccionado ? cs.primary : cs.onSurfaceVariant,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Text(
                'Estado',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.onPrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _controller.activo ? Icons.verified_user_outlined : Icons.person_off_outlined,
                      color: _controller.activo ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _controller.activo ? 'Usuario activo' : 'Usuario inactivo',
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      ),
                    ),
                    Switch(
                      value: _controller.activo,
                      onChanged: (bool v) => setState(() => _controller.activo = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Contraseña',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              CustomInputField(
                controller: _controller.passwordController,
                labelText: _controller.editando ? 'Nueva contraseña (opcional)' : 'Contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: _controller.ocultarContrasena,
                validator: _controller.validadorContrasena,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _controller.ocultarContrasena = !_controller.ocultarContrasena);
                  },
                  icon: Icon(
                    _controller.ocultarContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.confirmPasswordController,
                labelText: _controller.editando ? 'Confirmar nueva contraseña' : 'Confirmar contraseña',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: _controller.ocultarConfirmacionContrasena,
                validator: _controller.validadorConfirmacionContrasena,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _controller.ocultarConfirmacionContrasena = !_controller.ocultarConfirmacionContrasena);
                  },
                  icon: Icon(
                    _controller.ocultarConfirmacionContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                      backgroundColor: cs.surface,
                      borderColor: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _controller.editando ? 'Guardar cambios' : 'Crear usuario',
                      onPressed: _submit,
                      icon: _controller.editando ? Icons.save_outlined : Icons.add,
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
