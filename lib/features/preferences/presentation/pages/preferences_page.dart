import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/preferences/controllers/preferences_controller.dart';
import 'package:outventura/features/preferences/data/models/preferences.dart';
import 'package:outventura/l10n/app_localizations.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    // Observa el estado de las preferencias.
    final AsyncValue<Preferencias> prefsAsync = ref.watch(preferenciasProvider);

    return Scaffold(
      // Barra superior.
      appBar: AppBar(
        title: Text(s.preferencesTitle),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.surfaceContainer, Theme.of(context).colorScheme.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: prefsAsync.when(
        data: (Preferencias prefs) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            // IDIOMA
            _PrefsCard(
              icon: Icons.language_outlined,
              title: s.language,
              cs: cs,
              tt: tt,
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: prefs.idioma,
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    DropdownMenuItem(value: 'es', child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(s.spanish, style: tt.bodyMedium))),
                    DropdownMenuItem(value: 'en', child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(s.english, style: tt.bodyMedium))),
                    DropdownMenuItem(value: 'ca', child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(s.catalan, style: tt.bodyMedium))),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      ref.read(preferenciasProvider.notifier).actualizarPreferencias(
                        prefs.copyWith(idioma: value),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // TEMA OSCURO
            _PrefsCard(
              icon: prefs.temaOscuro ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              title: s.darkTheme,
              cs: cs,
              tt: tt,
              trailing: Switch(
                value: prefs.temaOscuro,
                onChanged: (bool value) {
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
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace stack) => Center(
          child: Text('Error: $err', style: tt.bodyMedium?.copyWith(color: cs.error)),
        ),
      ),
    );
  }
}

// CARD DE PREFERENCIAS 
class _PrefsCard extends StatelessWidget {
  const _PrefsCard({
    required this.icon,
    required this.title,
    required this.cs,
    required this.tt,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final ColorScheme cs;
  final TextTheme tt;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
      ),
      color: cs.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: cs.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: tt.titleMedium)),
            trailing,
          ],
        ),
      ),
    );
  }
}
