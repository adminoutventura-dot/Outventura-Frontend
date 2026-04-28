import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:outventura/app/theme/app_theme.dart';
import 'package:outventura/features/auth/presentation/pages/login_page.dart';
import 'package:outventura/features/preferences/controllers/preferences_controller.dart';
import 'package:outventura/features/preferences/data/models/preferences.dart';

// TODO: Revisar si se divide entre entities y models (Recordatorio)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Preferencias> preferenciasAsync = ref.watch(preferenciasProvider);

    return preferenciasAsync.when(
      data: (Preferencias preferences) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Outventura',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: preferences.temaOscuro ? ThemeMode.dark : ThemeMode.light,
        home: const LoginPage(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
