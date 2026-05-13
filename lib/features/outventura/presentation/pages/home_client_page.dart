import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
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

    final List<Reservation> misReservas = (ref.watch(reservationsProvider).value ?? [])
        .where((Reservation r) => r.userId == usuario.id)
        .toList();
    final List<Request> misSolicitudes = (ref.watch(requestsProvider).value ?? [])
        .where((Request s) => s.userId == usuario.id)
        .toList();
    final int solicitudesPendientes = misSolicitudes
        .where((Request s) => s.status == RequestStatus.pendiente)
        .length;
    final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.clientPanel),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceContainer,
                Theme.of(context).colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            color: cs.surfaceContainer,
            child: SafeArea(
              bottom: false,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.onPrimary,
                  border: Border(
                    bottom: BorderSide(
                      color: cs.onSurfaceVariant.withAlpha(50),
                      width: 2,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReservationsPage(puedeGestionar: false, puedeCrear: true),
                            ),
                          ),
                          child: StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value: '${misReservas.length}',
                            label: s.myReservations,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RequestsPage(puedeGestionar: false, puedeCrear: true),
                            ),
                          ),
                          child: StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value: '${misSolicitudes.length}',
                            label: s.myRequests,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          colorScheme: cs,
                          textTheme: tt,
                          value: '$solicitudesPendientes',
                          label: s.pendingLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 24),
                Text(
                  s.greeting(usuario.name),
                  style: tt.titleLarge?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  s.clientDescription,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: s.myReservationsBtn,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReservationsPage(puedeGestionar: false, puedeCrear: true),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: s.myRequestsBtn,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RequestsPage(puedeGestionar: false, puedeCrear: true),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.recentRequests,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                if (misSolicitudes.isEmpty)
                  Text(
                    s.noRequestsYet,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  )
                else
                  for (final Request solicitud in misSolicitudes.take(3))
                    Builder(builder: (context) {
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
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  )
                else
                // Muestra las 3 actividades más recientes (asumiendo que están ordenadas por fecha de creación)
                  for (final Activity actividad in actividades.take(3).toList().reversed)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.hiking_outlined),
                        title: Text(actividad.startPoint, style: tt.titleMedium),
                        subtitle: actividad.description != null
                          ? Text(actividad.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                            : null,
                        trailing: Icon(Icons.arrow_forward_ios, color: cs.primary, size: 18),
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
