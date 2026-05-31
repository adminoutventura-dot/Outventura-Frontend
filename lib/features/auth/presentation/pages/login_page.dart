import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/controllers/login_controller.dart';
import 'package:outventura/features/auth/presentation/pages/register_page.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/main_scaffold.dart';
import 'package:outventura/l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final LoginController _controller = LoginController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
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
                  // Logo Outventura
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 280,
                    fit: BoxFit.contain,
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
                            labelText: s.email,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: ValidadoresFormulario.email(s),
                          ),
                          const SizedBox(height: 16),

                          // Contraseña
                          CustomInputField(
                            controller: _controller.passwordController,
                            labelText: s.password,
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

                          const SizedBox(height: 12),

                          // Botón principal
                          _isLoading
                                // Si está cargando, mostrar un indicador de progreso en lugar del botón de login
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                // Si no está cargando, mostrar el botón de login
                              : PrimaryButton(
                                  label: s.login,
                                  onPressed: () async {
                                    if (!(_controller.formKey.currentState?.validate() ?? false)) {
                                      return;
                                    }
                                    setState(() => _isLoading = true);
                                    try {
                                      final String email = _controller.emailController.text.trim();
                                      final String password = _controller.passwordController.text;
                                      final usuario = await ref.read(currentUserProvider.notifier).login(email, password);

                                      if (!context.mounted || usuario == null) {
                                        return;
                                      }

                                      // Navegar a la pantalla principal, reemplazando el login.
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute( builder: (_) => MainScaffold(usuario: usuario)),
                                      );
                                    } catch (e) {

                                      // Si ocurre un error mostrar un SnackBar con el mensaje de error.
                                      if (context.mounted) {
                                        showErrorSnackBar(context, e.toString());
                                      }

                                    } finally {
                                      // Detener el indicador de carga.
                                      if (mounted) {
                                        setState(() => _isLoading = false);
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
                                  s.or,
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
                                s.noAccount,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(179),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterPage()),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                                child: Text(
                                  s.register,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // ENTRAR COMO INVITADO
                          SecondaryButton(
                            label: 'Entrar como invitado', 
                            onPressed: () {
                              const invitado = User(
                                id: null, 
                                name: 'Invitado', 
                                surname: '',
                                email: '',
                                active: true, 
                                role: UserRole(
                                  id: 4, 
                                  code: 'INVITADO', 
                                  description: 'Usuario invitado'
                                ), 
                              );
                              
                              ref.read(currentUserProvider.notifier).setUsuario(invitado);
                              
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute( builder: (_) => MainScaffold(usuario: invitado)),
                              );
                            },
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