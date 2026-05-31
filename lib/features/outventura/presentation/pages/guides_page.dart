import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/auth/presentation/providers/guides_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/outventura/presentation/widgets/guide_card.dart';
import 'package:outventura/features/outventura/presentation/pages/guide_detail_page.dart';

class GuidesPage extends ConsumerWidget {
  const GuidesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final AppLocalizations s = AppLocalizations.of(context)!;

    final guidesAsync = ref.watch(guidesProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: s.guides,
      ),
      body: guidesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(s.error(error.toString()))),
        data: (List<Guide> guides) {
          if (guides.isEmpty) {
            return Center(
              child: Text(
                'No hay guías registradas',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: guides.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              return GuideCard(
                guide: guides[index],
                onVerDetalle: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GuideDetailPage(guide: guides[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
