import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/controllers/user_form_controller.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/presentation/providers/categories_provider.dart'; 

class UserFormPage extends ConsumerStatefulWidget {
  final User? usuario;
  final Guide? guia;

  const UserFormPage({super.key, this.usuario, this.guia});

  @override
  ConsumerState<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  late final UserFormController _controller;
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _controller = UserFormController();
    _loginController = LoginController();
    if (widget.usuario != null) {
      _controller.cargarUsuario(
        widget.usuario!,
        categoriasGuia: widget.guia?.categories,
        credencialesGuia: widget.guia?.credentials,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _loginController.dispose();
    super.dispose();
  }

  bool get _esGuia => _controller.rol == UserRole.guia;

  void _submit() {
    if (!_controller.validar()) {
      return;
    }
    final User usuario = _controller.construirUsuario();
    final String? password = _controller.editando
        ? null
        : _loginController.passwordController.text;
        
    Map<String, dynamic>? guiaData;
    if (_esGuia && _controller.credenciales.text.trim().isNotEmpty) {
      guiaData = {
        'credentials': _controller.credenciales.text.trim(),
        'categoryCodes': _controller.categoriasGuia,
      };
    }
    Navigator.of(context).pop(<String, dynamic>{
      'usuario': usuario,
      'password': password,
      'guia': guiaData,
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final bool isEdit = _controller.editando;
    
    final listaCategorias = ref.watch(categoriesProvider).value ?? [];
    final User? currentUser = ref.watch(currentUserProvider);
    final bool isSuper = currentUser?.role.code == 'SUPER';

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBar(title: isEdit ? s.editUser : s.newUser),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height:
                    MediaQuery.of(context).padding.top + kToolbarHeight + 65,
              ),
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
              const SizedBox(height: 20),
              Text(
                s.userDataSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

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

              CustomInputField(
                controller: _controller.email,
                labelText: s.email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: ValidadoresFormulario.email(s),
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.telefono,
                labelText: s.phone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              if (!isEdit) ...[
                CustomInputField(
                  controller: _loginController.passwordController,
                  labelText: s.password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (String? v) =>
                      _loginController.validadorContrasena(isEdit, v, s),
                ),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 6),

              if (isSuper) ...[
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
                      onPressed: () => setState(() => _controller.rol = rol),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              if (_esGuia) ..._buildGuideSection(cs, tt, listaCategorias),

              Row(
                children: [
                  Text(
                    s.activeUser.toUpperCase(),
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Switch(
                    value: _controller.activo,
                    onChanged: (bool v) =>
                        setState(() => _controller.activo = v),
                    activeThumbColor: cs.primary,
                    activeTrackColor: cs.primaryContainer,
                    inactiveThumbColor: cs.onSurfaceVariant,
                    inactiveTrackColor: cs.onSurfaceVariant.withValues(
                      alpha: 0.35,
                    ),
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: s.save,
                  onPressed: _submit,
                  icon: isEdit
                      ? Icons.save_outlined
                      : Icons.person_add_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGuideSection(ColorScheme cs, TextTheme tt, List<Category> categoriasDisponibles) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    return [
      Text(
        'DADES DE GUIA',
        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      const SizedBox(height: 8),
      AppChipWrap(
        children: categoriasDisponibles.map((Category cat) {
          final bool sel = _controller.categoriasGuia.contains(cat);
          return AppFilterChip(
            label: cat.localizedLabel(s),
            seleccionado: sel,
            onSelected: (_) => setState(() {
              if (sel) {
                _controller.categoriasGuia.remove(cat);
              } else {
                _controller.categoriasGuia.add(cat);
              }
            }),
          );
        }).toList(),
      ),
      const SizedBox(height: 14),
      CustomInputField(
        controller: _controller.credenciales,
        labelText: 'Credencials',
        prefixIcon: Icons.verified_outlined,
        validator: (String? v) =>
            (v == null || v.trim().isEmpty) ? 'Camp obligatori' : null,
      ),
      const SizedBox(height: 20),
    ];
  }
}