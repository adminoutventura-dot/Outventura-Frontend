import 'package:flutter/material.dart';
import 'package:outventura/catalog/pages/catalog_page.dart';
import 'package:outventura/features/auth/presentation/pages/login_page.dart';
import 'package:outventura/features/auth/presentation/pages/user_form_page.dart';
import 'package:outventura/features/preferences/presentation/pages/preferences_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Crear/Editar usuario
          ListTile(
            leading: Icon(Icons.person_add_alt_1, color: cs.onSurface),
            title: Text(
              'Crear/Editar usuario',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserFormPage(),
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