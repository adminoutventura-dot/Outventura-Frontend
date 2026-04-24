import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/preferences/controllers/preferences_controller.dart';
import 'package:outventura/features/preferences/data/models/preferences.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    // Observa el estado de las preferencias.
    final AsyncValue<Preferencias> prefsAsync = ref.watch(preferenciasProvider);

    return Scaffold(
      // Barra superior.
      appBar: AppBar(
        title: const Text('Preferencias'),
      ),
      body: prefsAsync.when(
        // Preferencias cargadas.
        data: (Preferencias prefs) => ListView(
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
                  onChanged: (String? value) {
                    if (value != null) {
                      // Actualiza el idioma seleccionado.
                      ref.read(preferenciasProvider.notifier).actualizarPreferencias(
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
                    onChanged: (bool value) {
                      // Actualiza la preferencia de tema oscuro.
                      ref.read(preferenciasProvider.notifier).actualizarPreferencias(
                        prefs.copyWith(temaOscuro: value),
                      );
                    },
                    activeThumbColor: cs.primary,
                    activeTrackColor: cs.primaryContainer,
                    inactiveThumbColor: cs.onSurfaceVariant,
                    inactiveTrackColor: cs.onSurfaceVariant.withValues(alpha: 0.35),
                    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                  ),
              ],
            ),
          ],
        ),
        // Indicador de carga mientras se obtienen las preferencias.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Mensaje de error si falla la carga.
        error: (Object err, StackTrace stack) => Center(
          child: Text(
            'Error: $err',
            style: tt.bodyMedium?.copyWith(color: cs.error),
          ),
        ),
      ),
    );
  }
}
