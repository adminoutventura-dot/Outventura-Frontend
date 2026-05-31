import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/l10n/app_localizations.dart';

class GuideDetailPage extends ConsumerWidget {
  final Guide guide;

  const GuideDetailPage({super.key, required this.guide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;

    final user = guide.user;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(s.error('User not found')),
        ),
      );
    }

    final Color accentColor = user.active ? cs.tertiary : cs.error;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailSliverHeader(
            title: 'Detalle de Guía',
            subtitle: user.active ? s.active : s.inactive,
            color: accentColor,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                MediaQuery.of(context).padding.bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información general
                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      DetailRow(Icons.person_outline, s.name, '${user.name} ${user.surname}'),
                      DetailRow(Icons.email_outlined, s.email, user.email),
                      if (user.phone != null)
                        DetailRow(Icons.phone_outlined, s.phone, user.phone!),
                      DetailRow(Icons.badge_outlined, s.role, user.role.localizedLabel(s)),
                      DetailRow(
                        Icons.circle_outlined,
                        s.status,
                        user.active ? s.active : s.inactive,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Credenciales del guía
                  DetailSection(
                    title: 'Credenciales',
                    children: [
                      DetailRow(Icons.card_membership_outlined, 'Credencial', guide.credentials),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Categorías del guía
                  if (guide.categories.isNotEmpty)
                    DetailSection(
                    title: 'Categorías',
                    children: [
                      Container(
                        width: double.infinity,
                        // Esto es lo que empuja los bordes blancos hacia arriba y abajo.
                        // Sube o baja el 16.0 a tu gusto (prueba con 20.0 si lo quieres más grande).
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20), 
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: guide.categories.map((category) {
                            return TagWidget(
                              text: category.description ?? category.code,
                              backgroundColor: cs.primary.withValues(alpha: 0.1),
                              textColor: cs.primary,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
