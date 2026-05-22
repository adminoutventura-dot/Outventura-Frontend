import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:outventura/app/theme/app_theme.dart';
import 'package:outventura/core/widgets/splash_wrapper.dart';
import 'package:outventura/features/auth/presentation/pages/login_page.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/main_scaffold.dart';
import 'package:outventura/features/preferences/controllers/preferences_controller.dart';
import 'package:outventura/features/preferences/data/models/preferences.dart';

// TODO: Revisar si se divide entre entities y models (Recordatorio)
// TODO: Añadir el subir fotos.
// TODO: Añadir borde a logo
// TODO: GO_ROUTE
// TODO: En reserva no es obligatorio seleccionar una actividad, de hecho que no aparezca esa opcion
// TODO: EN RESERVAS QUE NO SEA DESPLEGABLE EL USUARO SI ES MODO CLIENTE, QUE SE LE ASIGNE DIRECTAMENTE EL USUARIO ACTUAL Y NO PUEDA CAMBIARLO Y QUE NO APAREZCA LA PARTE DE EXPERTO.

void main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeDateFormatting();
  runApp(const ProviderScope(child: SplashWrapper()));
}

Locale _localeFromString(String code) {
  switch (code) {
    case 'en':
      return const Locale('en');
    case 'ca':
      return const Locale('ca');
    default:
      return const Locale('es');
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Preferencias> preferenciasAsync = ref.watch(preferenciasProvider);
    // Restaurar sesión al iniciar la app.
    ref.watch(sessionRestorerProvider);
    // Observar el usuario actual para decidir qué pantalla mostrar.
    final User? usuarioActual = ref.watch(currentUserProvider);

    return preferenciasAsync.when(
      data: (Preferencias preferences) {
        return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Outventura',
        locale: _localeFromString(preferences.idioma),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: preferences.temaOscuro ? ThemeMode.dark : ThemeMode.light,
        // Si hay usuario logueado, mostrar MainScaffold. Si no, mostrar LoginPage.
        home: usuarioActual != null
            ? MainScaffold(usuario: usuarioActual)
            : const LoginPage(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
