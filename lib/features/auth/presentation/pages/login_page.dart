import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/main_scaffold.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final LoginController _controller = LoginController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.onSurface.withAlpha(128),
                    colorScheme.onSurface.withAlpha(179),
                  ],
                ),
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
                    'OUTVENTURA',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      color: colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Tu próxima aventura te espera',
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
                      key: _controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          CustomInputField(
                            controller: _controller.emailController,
                            labelText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: ValidadoresFormulario.email,
                          ),
                          const SizedBox(height: 16),

                          // Contraseña
                          CustomInputField(
                            controller: _controller.passwordController,
                            labelText: 'Contraseña',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _controller.ocultarContrasena,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _controller.ocultarContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                () => _controller.ocultarContrasena =
                                    !_controller.ocultarContrasena,
                              ),
                            ),
                          ),

                          // Recuperar contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Recuperar contraseña
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Botón principal
                          PrimaryButton(
                            label: 'Iniciar sesión',
                            onPressed: () async {
                              if (_controller.formKey.currentState?.validate() ?? false) {
                                final String email = _controller.emailController.text.trim();
                                final String password = _controller.passwordController.text;
                                try {
                                  final usuario = await ref.read(currentUserProvider.notifier).login(email, password);
                                  if (!context.mounted || usuario == null) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext _) => MainScaffold(usuario: usuario),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  final msg = e.toString().contains('401') || e.toString().contains('Credenciales')
                                      ? 'Usuario o contraseña incorrectos'
                                      : 'Error de conexión o inesperado';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg)),
                                  );
                                }
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: colorScheme.onSurfaceVariant.withAlpha(
                                    77,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'O',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: colorScheme.onSurfaceVariant.withAlpha(
                                    77,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Registro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Aún no tienes cuenta? ',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(179),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Página de registro
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                child: Text(
                                  'Regístrate',
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
