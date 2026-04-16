import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/presentation/controllers/user_form_controller.dart';

class UserFormPage extends StatefulWidget {
  /// Si se pasa un usuario, el formulario actúa como edición.
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
    _controller = UserFormController();
    if (widget.usuario != null) {
      _controller.cargarUsuario(widget.usuario!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.submit()) return;
    // TODO: enviar datos al repositorio
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
              // Nombre y Apellidos
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.nombre,
                      labelText: 'Nombre',
                      prefixIcon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.apellidos,
                      labelText: 'Apellidos',
                      prefixIcon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Email 
              CustomInputField(
                controller: _controller.email,
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
                  if (!regex.hasMatch(v)) {
                    return 'Email no válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Teléfono 
              CustomInputField(
                controller: _controller.telefono,
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Contraseña (solo en creación)
              if (!_controller.isEditing) ...[
                CustomInputField(
                  controller: _controller.password,
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 6),

              // Rol
              Text(
                'Rol',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: TipoRol.values.map((rol) {
                  final selected = _controller.rol == rol;
                  return AppChoiceChip(
                    label: rol.nombre,
                    selected: selected,
                    onSelected: (_) => setState(() => _controller.rol = rol),
                    selectedColor: cs.secondaryContainer,
                    selectedBorderColor: cs.tertiary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Estado activo
              Row(
                children: [
                  Text(
                    'Usuario activo',
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Switch(
                    value: _controller.activo,
                    onChanged: (v) => setState(() => _controller.activo = v),
                    activeThumbColor: cs.primary,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                      backgroundColor: cs.onError,
                      borderColor: cs.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _controller.isEditing ? 'Guardar' : 'Crear',
                      onPressed: _submit,
                      icon: _controller.isEditing ? Icons.save_outlined : Icons.person_add_outlined,
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
