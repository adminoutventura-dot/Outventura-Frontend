import 'package:flutter/material.dart';
import 'package:outventura/catalog/pages/catalog_page.dart';
import 'package:outventura/features/auth/presentation/pages/login_page.dart';
import 'package:outventura/features/preferences/presentation/pages/preferences_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header del Drawer.
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Text(
              'Outventura',
              style: tt.headlineSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Catálogo de Componentes.
          ListTile(
            leading: Icon(Icons.map, color: colorScheme.onSurface),
            title: Text(
              'Catálogo de Componentes',
              style: tt.titleMedium?.copyWith(color: colorScheme.onSurface),
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
            leading: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
            title: Text(
              'Preferencias',
              style: tt.titleMedium?.copyWith(color: colorScheme.onSurface),
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
            leading: Icon(Icons.logout, color: colorScheme.onSurface),
            title: Text(
              'Cerrar sesión',
              style: tt.titleMedium?.copyWith(color: colorScheme.onSurface),
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