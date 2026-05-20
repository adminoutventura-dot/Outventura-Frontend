import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/controllers/user_form_controller.dart';

class UserFormPage extends StatefulWidget {
  // Si se pasa un usuario, el formulario actúa en modo edición y precarga sus datos.
  final User? usuario;

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
    // Si se pasa un usuario existente, carga sus datos en el controlador (modo edición).
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

  // Valida el formulario y, si es correcto, construye el usuario y lo devuelve al llamador.
  void _submit() {
    if (!_controller.validar()) return;
    final User usuario = _controller.construirUsuario();
    Navigator.of(context).pop(usuario);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    // Se pone a true dentro de cargarUsuario().
    final bool isEdit = _controller.editando;

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBar(title: isEdit ? s.editUser : s.newUser),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 24),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 65),
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

              Text(
                s.userDataSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              // Nombre y Apellidos
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.nombre,
                      labelText: s.name,
                      prefixIcon: Icons.person_outline,
                      validator: ValidadoresFormulario.campoObligatorio(s),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.apellidos,
                      labelText: s.surname,
                      prefixIcon: Icons.badge_outlined,
                      validator: ValidadoresFormulario.campoObligatorio(s),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Email 
              CustomInputField(
                controller: _controller.email,
                labelText: s.email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: ValidadoresFormulario.email(s),
              ),
              const SizedBox(height: 14),

              // Teléfono 
              CustomInputField(
                controller: _controller.telefono,
                labelText: s.phone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Contraseña (solo en creación)
              if (!isEdit) ...[
                CustomInputField(
                  controller: _loginController.passwordController,
                  labelText: s.password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (String? v) => _loginController.validadorContrasena(isEdit, v, s),
                ),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 6),

              // Rol
              Text(
                s.role.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: UserRole.values.map((UserRole rol) {
                  final bool seleccionado = _controller.rol == rol;
                  return AppChoiceChip(
                    label: rol.localizedLabel(s),
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
                    s.activeUser.toUpperCase(),
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

              // Botón Guardar / Crear
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: s.save,
                  onPressed: _submit,
                  icon: isEdit ? Icons.save_outlined : Icons.person_add_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
