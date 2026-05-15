import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/outventura_app_bar.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/presentation/pages/users_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservations_page.dart';
import 'package:outventura/features/outventura/presentation/pages/requests_page.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';

import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/l10n/app_localizations.dart';

class HomeAdminPage extends ConsumerWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;
    final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];
    final List<Equipment> equipamientos = ref.watch(equipmentProvider).value ?? [];
    final List<Request> solicitudes = ref.watch(requestsProvider).value ?? [];

    return Scaffold(
      appBar: OutventuraAppBar(
        title: s.adminPanel,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            child: Row(
              children: [
                Expanded(child: StatCard(value: '${actividades.length}', label: s.actividadesLabel, foregroundColor: cs.onPrimary)),
                _HeaderDivider(),
                Expanded(child: StatCard(value: '${equipamientos.length}', label: s.equipmentLabel, foregroundColor: cs.onPrimary)),
                _HeaderDivider(),
                Expanded(
                  child: StatCard(
                    value: '${solicitudes.where((Request r) => r.status == RequestStatus.pendiente).length}',
                    label: s.pendingLabel,
                    foregroundColor: cs.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Drawer
      drawer: const AppDrawer(),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB( 12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
              children: [
                const SizedBox(height: 24),
                // Sección de accesos rápidos de gestión.
                Text(
                  s.management,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    backgroundColor: cs.surface,
                    label: s.users,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UsersPage()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    backgroundColor: cs.surface,
                    label: s.reservations,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReservationsPage(puedeGestionar: true, puedeCrear: true)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    backgroundColor: cs.surface,
                    label: s.requests,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RequestsPage(puedeGestionar: true, puedeCrear: true)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Título de sección.
                Text(
                  s.recentRequests,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                // Tarjetas de solicitudes recientes.
                for (Request solicitud in solicitudes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RequestCard(
                      solicitud: solicitud,
                      actividad: ref.watch(activityByIdProvider(solicitud.activityId)) ?? actividades.first,
                      nombreUsuario: solicitud.userId != null
                          ? ref.watch(userNameProvider(solicitud.userId!))
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.onPrimary.withAlpha(80),
    );
  }
}
