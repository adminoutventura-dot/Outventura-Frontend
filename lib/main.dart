import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/app/theme/app_theme.dart';
import 'package:outventura/features/auth/presentation/pages/login_page.dart';
import 'package:outventura/features/preferences/controllers/preferences_controller.dart';

// TODO: Revisar la diferencia entre entities y models (Recordatorio)
// TODO: Los nombres de los objetos y atributos tienen que ir en inglés o español?
// TODO: En que carpeta van los entities?

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(preferencesProvider);

    return preferencesAsync.when(
      data: (preferences) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Outventura',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: preferences.temaOscuro ? ThemeMode.dark : ThemeMode.light,
        home: const LoginPage(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
