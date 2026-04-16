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

  @override
  void initState() {
    super.initState();
    _controller = UserFormController()..initialize(widget.usuario);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.submit()) return;
    // TODO: guardar usuario
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.inverseSurface,
        foregroundColor: cs.onInverseSurface,
        title: Text(
          _controller.isEditing ? 'Editar usuario' : 'Nuevo usuario',
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
                validator: (v) {
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
                validator: (v) {
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
                validator: _controller.emailValidator,
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
                children: TipoRol.values.map((rol) {
                  final selected = _controller.rol == rol;
                  return ChoiceChip(
                    label: Text(rol.nombre),
                    selected: selected,
                    onSelected: (_) => setState(() => _controller.rol = rol),
                    selectedColor: cs.primaryContainer,
                    backgroundColor: cs.onPrimary,
                    labelStyle: tt.labelMedium?.copyWith(
                      color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                    ),
                    side: BorderSide(
                      color: selected ? cs.primary : cs.onSurfaceVariant,
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
                      onChanged: (v) => setState(() => _controller.activo = v),
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
                labelText: _controller.isEditing ? 'Nueva contraseña (opcional)' : 'Contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: _controller.obscurePassword,
                validator: _controller.passwordValidator,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _controller.obscurePassword = !_controller.obscurePassword);
                  },
                  icon: Icon(
                    _controller.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.confirmPasswordController,
                labelText: _controller.isEditing ? 'Confirmar nueva contraseña' : 'Confirmar contraseña',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: _controller.obscureConfirmPassword,
                validator: _controller.confirmPasswordValidator,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _controller.obscureConfirmPassword = !_controller.obscureConfirmPassword);
                  },
                  icon: Icon(
                    _controller.obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                      label: _controller.isEditing ? 'Guardar cambios' : 'Crear usuario',
                      onPressed: _submit,
                      icon: _controller.isEditing ? Icons.save_outlined : Icons.add,
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
