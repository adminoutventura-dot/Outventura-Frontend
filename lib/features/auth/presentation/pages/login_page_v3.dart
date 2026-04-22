import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/outventura/presentation/pages/main_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset('assets/images/Camino.jpg', fit: BoxFit.cover),
          ),

          // Overlay suave
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface.withAlpha(217),
                    colorScheme.surface.withAlpha(235),
                    colorScheme.surface.withAlpha(242),
                  ],
                ),
              ),
            ),
          ),

          // Contenido
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  margin: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Card principal
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo y título
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withAlpha(26),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.landscape_rounded,
                                  size: 48,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'OUTVENTURA',
                                textAlign: TextAlign.center,
                                style: textTheme.displaySmall!.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 6),

                              Text(
                                'Tu próxima aventura te espera',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium!.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),

                              const SizedBox(height: 36),

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
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: textTheme.bodySmall!.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Botón principal
                              PrimaryButton(
                                label: 'Iniciar sesión',
                                onPressed: () {
                                  if (_controller.formKey.currentState?.validate() ?? false) {
                                    // Busca el usuario y si no lo encuentra usa el primero de la lista.
                                    final String email = _controller
                                        .emailController
                                        .text
                                        .trim();
                                    final Usuario usuario = usuariosFake.firstWhere(
                                      (Usuario u) => u.email == email,
                                      orElse: () => usuariosFake[0],
                                    );

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext _) =>
                                            MainScaffold(usuario: usuario),
                                      ),
                                    );
                                  }
                                },
                              ),

                              const SizedBox(height: 20),

                              // Divider con texto
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.onSurfaceVariant
                                          .withAlpha(51),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'O',
                                      style: textTheme.bodySmall!.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.onSurfaceVariant
                                          .withAlpha(51),
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
                                    style: textTheme.bodyMedium!.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                    ),
                                    child: Text(
                                      'Regístrate',
                                      style: textTheme.labelLarge!.copyWith(
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
