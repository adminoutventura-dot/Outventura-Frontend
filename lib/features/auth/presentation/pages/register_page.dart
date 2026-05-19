import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/features/auth/presentation/controllers/register_controller.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final RegisterController _ctrl = RegisterController();
  bool _isLoading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset('assets/images/Camino.jpg', fit: BoxFit.cover),
          ),

          // Overlay oscuro
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.loginOverlay(colorScheme),
              ),
            ),
          ),

          // Contenido
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo y título
                  Icon(
                    Icons.landscape_rounded,
                    size: 80,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    s.loginTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    s.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.surface.withAlpha(230),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Card con formulario
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withAlpha(242),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.onSurface.withAlpha(77),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _ctrl.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nombre y apellidos
                          Text(
                            'Usuario',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputField(
                                  controller: _ctrl.nameController,
                                  labelText: s.name,
                                  prefixIcon: Icons.person_outline,
                                  validator: ValidadoresFormulario.campoObligatorio(s),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomInputField(
                                  controller: _ctrl.surnameController,
                                  labelText: s.surname,
                                  prefixIcon: Icons.person_outline,
                                  validator: ValidadoresFormulario.campoObligatorio(s),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Email
                          CustomInputField(
                            controller: _ctrl.emailController,
                            labelText: s.email,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: ValidadoresFormulario.email(s),
                          ),
                          const SizedBox(height: 20),

                          // Contraseña
                          Text(
                            s.password,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomInputField(
                            controller: _ctrl.passwordController,
                            labelText: s.password,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _ctrl.ocultarPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ctrl.ocultarPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                  () => _ctrl.ocultarPassword = !_ctrl.ocultarPassword),
                            ),
                            validator: (v) => _ctrl.validadorPassword(v, s),
                          ),
                          const SizedBox(height: 16),

                          // Confirmar contraseña
                          CustomInputField(
                            controller: _ctrl.confirmPasswordController,
                            labelText: s.confirmNewPassword,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _ctrl.ocultarConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _ctrl.ocultarConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _ctrl.ocultarConfirm = !_ctrl.ocultarConfirm),
                            ),
                            validator: (v) => _ctrl.validadorConfirmacion(v, s),
                          ),
                          const SizedBox(height: 24),

                          // Botón principal
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : PrimaryButton(
                                  label: s.register,
                                  onPressed: () async {
                                    if (!(_ctrl.formKey.currentState?.validate() ?? false)) {
                                      return;
                                    }
                                    setState(() => _isLoading = true);
                                    try {
                                      await ref.read(currentUserProvider.notifier).register(
                                            _ctrl.nameController.text.trim(),
                                            _ctrl.surnameController.text.trim(),
                                            _ctrl.emailController.text.trim(),
                                            _ctrl.passwordController.text,
                                          );
                                      if (!context.mounted) return;
                                      showSuccessSnackBar(
                                          context, 'Cuenta creada. Inicia sesión.');
                                      Navigator.pop(context);
                                    } catch (e) {
                                      if (context.mounted) showErrorSnackBar(context, e);
                                    } finally {
                                      if (mounted) setState(() => _isLoading = false);
                                    }
                                  },
                                ),

                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: colorScheme.onSurfaceVariant.withAlpha(77),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  s.or,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: colorScheme.onSurfaceVariant.withAlpha(77),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Enlace a login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Ya tienes cuenta?  ',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(179),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                ),
                                child: Text(
                                  s.login,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
