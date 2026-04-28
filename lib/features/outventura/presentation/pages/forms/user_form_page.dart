import 'package:flutter/material.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/controllers/user_form_controller.dart';

class UserFormPage extends StatefulWidget {
  // Si se pasa un usuario, el formulario actúa como edición.
  final Usuario? usuario;

  const UserFormPage({super.key, this.usuario});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  late final UserFormController _controller;
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _controller = UserFormController();
    _loginController = LoginController();
    if (widget.usuario != null) {
      _controller.cargarUsuario(widget.usuario!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _loginController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_controller.validar()) return;
    final Usuario usuario = _controller.construirUsuario();
    Navigator.of(context).pop(usuario);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(_controller.editando ? 'Editar usuario' : 'Nuevo usuario'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.surfaceContainer, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 24),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: AppImagePickerField(
                  imageUrl: _controller.foto,
                  // le indica al widget AppImagePickerField que la imagen de perfil es un asset local (por ejemplo, assets/images/Camino.jpg) 
                  // y no una URL de internet. Así, usa Image.asset en vez de NetworkImage para mostrar la foto.
                  isAsset: true,
                  isCircular: true,
                  placeholder: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 20),
              // Nombre y Apellidos
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.nombre,
                      labelText: 'Nombre',
                      prefixIcon: Icons.person_outline,
                      validator: ValidadoresFormulario.campoObligatorio,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.apellidos,
                      labelText: 'Apellidos',
                      prefixIcon: Icons.person_outline,
                      validator: ValidadoresFormulario.campoObligatorio,
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
                validator: ValidadoresFormulario.email,
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
              if (!_controller.editando) ...[
                CustomInputField(
                  controller: _loginController.passwordController,
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (String? v) => ValidadoresFormulario.longitudMinima(v, 6),
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
                children: TipoRol.values.map((TipoRol rol) {
                  final bool seleccionado = _controller.rol == rol;
                  return AppChoiceChip(
                    label: rol.nombre,
                    seleccionado: seleccionado,
                    onSelected: (_) => setState(() => _controller.rol = rol),
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
                    onChanged: (bool v) => setState(() => _controller.activo = v),
                    activeThumbColor: cs.primary,
                    activeTrackColor: cs.primaryContainer,
                    inactiveThumbColor: cs.onSurfaceVariant,
                    inactiveTrackColor: cs.onSurfaceVariant.withValues(alpha: 0.35),
                    // Quita el borde del track en todos los estados
                    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
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
                      label: _controller.editando ? 'Guardar' : 'Crear',
                      onPressed: _submit,
                      icon: _controller.editando ? Icons.save_outlined : Icons.person_add_outlined,
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
