import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/reservations_page.dart';
import 'package:outventura/features/outventura/presentation/pages/requests_page.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class HomeClientePage extends ConsumerWidget {
  final User usuario;

  const HomeClientePage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    final List<Booking> misReservas = (ref.watch(reservationsProvider).value ?? [])
        .where((Booking r) => r.userId == usuario.id)
        .toList();
    final List<Request> misSolicitudes = (ref.watch(requestsProvider).value ?? [])
        .where((Request s) => s.userId == usuario.id)
        .toList();
    final int solicitudesPendientes = misSolicitudes
        .where((Request s) => s.status == RequestStatus.pendiente)
        .length;
    final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];

    return Scaffold(
      appBar: CustomAppBar(
        title: s.clientPanel,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReservationsPage(puedeGestionar: false, puedeCrear: true),
                      ),
                    ),
                    child: StatCard(value: '${misReservas.length}', label: s.myReservations, foregroundColor: cs.onPrimary),
                  ),
                ),
                _HeaderDivider(),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RequestsPage(puedeGestionar: false, puedeCrear: true),
                      ),
                    ),
                    child: StatCard(value: '${misSolicitudes.length}', label: s.myRequests, foregroundColor: cs.onPrimary),
                  ),
                ),
                _HeaderDivider(),
                Expanded(child: StatCard(value: '$solicitudesPendientes', label: s.pendingLabel, foregroundColor: cs.onPrimary)),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.of(context).padding.bottom + 32),
        children: [
          Text(
            s.greeting(usuario.name),
            style: tt.titleLarge?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            s.clientDescription,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          
          // --- FILA HORIZONTAL DE BOTONES ---
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: s.myReservationsBtn,
                  backgroundColor: cs.surface,
                  borderColor: cs.tertiary,
                  borderRadius: 5,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReservationsPage(puedeGestionar: false, puedeCrear: true),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SecondaryButton(
                  label: s.myRequestsBtn,
                  backgroundColor: cs.surface,
                  borderColor: cs.tertiary,
                  borderRadius: 5,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RequestsPage(puedeGestionar: false, puedeCrear: true),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          Text(
            s.recentRequests,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          
          if (misSolicitudes.isEmpty)
            Text(
              s.noRequestsYet,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
            )
          else
            // Eliminado el Builder gracias al uso directo de tu provider
            ...misSolicitudes.take(3).map((Request solicitud) {
              final Activity? act = ref.watch(activityByIdProvider(solicitud.activityId));
              if (act == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RequestCard(
                  solicitud: solicitud,
                  actividad: act,
                  nombreUsuario: '${usuario.name} ${usuario.surname}',
                ),
              );
            }),
            
          const SizedBox(height: 24),
          Text(
            s.nuevasActividades,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          
          if (actividades.isEmpty)
            Text(
              s.noNuevasActividades,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
            )
          else
            ...actividades.take(3).toList().reversed.map((Activity actividad) {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.hiking_outlined, 
                    color: cs.primary,
                  ),
                  title: Text(actividad.startPoint, style: tt.titleMedium),
                  subtitle: actividad.description != null
                      ? Text(actividad.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                      : null,
                ),
              );
            }),
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
      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
    );
  }
}