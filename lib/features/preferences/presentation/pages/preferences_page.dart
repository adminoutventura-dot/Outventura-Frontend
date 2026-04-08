import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/preferences/controllers/preferences_controller.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Observa el estado de las preferencias.
    final prefsAsync = ref.watch(preferencesProvider);

    return Scaffold(
      // Barra superior.
      appBar: AppBar(
        title: const Text('Preferencias'),
      ),
      body: prefsAsync.when(
        // Preferencias cargadas.
        data: (prefs) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Selector de idioma.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Idioma', style: tt.titleMedium),
                DropdownButton<String>(
                  value: prefs.idioma,
                  items: [
                    DropdownMenuItem(
                      value: 'es',
                      child: Text('Español', style: tt.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('Inglés', style: tt.bodyMedium),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      // Actualiza el idioma seleccionado.
                      ref.read(preferencesProvider.notifier).updatePreferences(
                        prefs.copyWith(idioma: value),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Selector de tema oscuro.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tema oscuro', style: tt.titleMedium),
                Switch(
                  value: prefs.temaOscuro,
                  onChanged: (value) {
                    // Actualiza la preferencia de tema oscuro.
                    ref.read(preferencesProvider.notifier).updatePreferences(
                      prefs.copyWith(temaOscuro: value),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Indicador de carga mientras se obtienen las preferencias.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Mensaje de error si falla la carga.
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: tt.bodyMedium?.copyWith(color: cs.error),
          ),
        ),
      ),
    );
  }
}
