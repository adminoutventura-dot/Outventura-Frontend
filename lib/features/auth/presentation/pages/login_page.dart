import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/custom_input_field.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/outventura/presentation/pages/home_page.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Icon(Icons.landscape_rounded, size: 64, color: colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'OUTVENTURA',
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall!.copyWith(color: colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu próxima aventura te espera',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),

                const SizedBox(height: 48),

                // Email
                CustomInputField(
                  controller: _controller.emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _controller.emailValidator,
                ),
                const SizedBox(height: 16),

                // Contraseña
                CustomInputField(
                  controller: _controller.passwordController,
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _controller.obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _controller.obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _controller.obscurePassword = !_controller.obscurePassword),
                  ),
                ),

                // Recuperar contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Recuperar contraseña
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.55)),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Botón principal
                PrimaryButton(
                  label: 'Iniciar sesión',
                  onPressed: () {
                    if (_controller.formKey.currentState?.validate() ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Aún no tienes cuenta? ',
                      style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.55)),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Página de registro
                      },
                      child: Text(
                        'Regístrate',
                        style: textTheme.labelLarge!.copyWith(color: colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}