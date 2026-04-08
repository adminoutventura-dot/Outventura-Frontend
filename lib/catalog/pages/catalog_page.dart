import 'package:flutter/material.dart';
import 'package:outventura/catalog/demos/buttons_demo.dart';
import 'package:outventura/catalog/demos/cards_demo.dart';
import 'package:outventura/catalog/demos/inputs_demo.dart';
import 'package:outventura/catalog/demos/theme_demo.dart';

// Pantalla que muestra un catálogo de componentes de la app.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Componentes')),

      // El cuerpo de la pantalla se envuelve en una lista
      body: ListView(
        children: [
          // Opción para ver la demo de botones
          ListTile(
            title: Text(
              'Botones',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            subtitle: Text(
              'Variantes, estados y tamaños',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right),
            // Al pulsar, se navega a la pantalla ButtonsDemo
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ButtonsDemo()));
            },
          ),

          const SizedBox(height: 8),

          // Opción para ver la demo de inputs
          ListTile(
            title: Text(
              'Inputs',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            subtitle: Text(
              'Variantes, estados y tamaños',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right),
            // Al pulsar, se navega a la pantalla InputsDemo
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const InputsDemo()));
            },
          ),

          const SizedBox(height: 8),

          // Opción para ver la demo de cards
          ListTile(
            title: Text(
              'Cards',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            subtitle: Text(
              'Variantes, estados y tamaños',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right),
            // Al pulsar, se navega a la pantalla CardsDemo
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CardsDemo()));
            },
          ),

          const SizedBox(height: 8),

          // Opción para ver la demo de colores y tipografía
          ListTile(
            title: Text(
              'Colores y tipografía',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            subtitle: Text(
              'Variantes, estados y tamaños',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right),
            // Al pulsar, se navega a la pantalla ThemeDemo
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ThemeDemo()));
            },
          ),
        ],
      ),
    );
  }
}
