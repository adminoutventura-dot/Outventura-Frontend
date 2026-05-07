import 'package:flutter/material.dart';
import 'package:outventura/catalog/demos/buttons_demo.dart';
import 'package:outventura/catalog/demos/cards_demo.dart';
import 'package:outventura/catalog/demos/inputs_demo.dart';
import 'package:outventura/catalog/demos/overlays_demo.dart';
import 'package:outventura/catalog/demos/theme_demo.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Componentes'),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.surfaceContainer, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Colores y tipografía', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
            subtitle: Text('Paleta de color, escala tipográfica', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThemeDemo())),
          ),

          const SizedBox(height: 8),

          ListTile(
            title: Text('Botones', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
            subtitle: Text('PrimaryButton, SecondaryButton, TertiaryButton, MiniButton, AddFab', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ButtonsDemo())),
          ),

          const SizedBox(height: 8),

          ListTile(
            title: Text('Inputs & Widgets', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
            subtitle: Text('Campos, dropdowns, fecha, hora, chips, tags, imágenes, filtros', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InputsDemo())),
          ),

          const SizedBox(height: 8),

          ListTile(
            title: Text('Diálogos & Overlays', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
            subtitle: Text('showConfirmDialog, diálogos de reserva, línea de reserva', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OverlaysDemo())),
          ),

          const SizedBox(height: 8),

          ListTile(
            title: Text('Cards', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
            subtitle: Text('Stat, excursión, solicitud, reserva, equipamiento, usuario', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CardsDemo())),
          ),
        ],
      ),
    );
  }
}
