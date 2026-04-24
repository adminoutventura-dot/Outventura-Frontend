import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/catalog/pages/catalog_page.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/pages/login_page.dart';
import 'package:outventura/features/auth/presentation/pages/profile_form_page.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/preferences/presentation/pages/preferences_page.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Usuario? usuario = ref.watch(currentUserProvider);
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del Drawer.
          DrawerHeader(
            decoration: BoxDecoration(color: cs.primary),
            child: Text(
              'Outventura',
              style: tt.headlineSmall?.copyWith(
                color: cs.onPrimary,
              ),
            ),
          ),
          // Crear/Editar usuario
          ListTile(
            leading: Icon(Icons.person, color: cs.onSurface),
            title: Text(
              'Perfil',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            onTap: () {
              if (usuario == null) return;
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileFormPage(usuario: usuario),
                ),
              );
            },
          ),
          // Catálogo de Componentes.
          ListTile(
            leading: Icon(Icons.map, color: cs.onSurface),
            title: Text(
              'Catálogo de Componentes',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CatalogPage(),
                ),
              );
            },
          ),
          // Page de preferencias.
          ListTile(
            leading: Icon(Icons.settings_outlined, color: cs.onSurface),
            title: Text(
              'Preferencias',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PreferencesPage(),
                ),
              );
            },
          ),
          // Botón de cerrar sesión.
          ListTile(
            leading: Icon(Icons.logout, color: cs.onSurface),
            title: Text(
              'Cerrar sesión',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}