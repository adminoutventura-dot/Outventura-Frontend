import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/activities_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservations_page.dart';
import 'package:outventura/features/outventura/presentation/pages/requests_page.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/core/utils/enum_translations.dart';
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
    
    // Actividades recientes (últimas 5)
    final actividadesRecientes = actividades.take(5).toList();
    
    // Categorías más populares
    final categoriasCount = <Category, int>{};
    for (final act in actividades) {
      for (final cat in act.categories) {
        categoriasCount[cat] = (categoriasCount[cat] ?? 0) + 1;
      }
    }
    final categoriasPopulares = categoriasCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                    child: StatCard(
                      value: '${misReservas.length}',
                      label: s.myReservations,
                      foregroundColor: cs.onPrimary,
                    ),
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
                    child: StatCard(
                      value: '${misSolicitudes.length}',
                      label: s.myRequests,
                      foregroundColor: cs.onPrimary,
                    ),
                  ),
                ),
                _HeaderDivider(),
                Expanded(
                  child: StatCard(
                    value: '$solicitudesPendientes',
                    label: s.pendingLabel,
                    foregroundColor: cs.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 32),
        children: [
          // SALUDO
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.greeting(usuario.name),
                  style: tt.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.clientDescription,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ACCIONES RÁPIDAS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: s.myReservationsBtn,
                    backgroundColor: cs.surface,
                    borderColor: cs.tertiary,
                    borderRadius: 5,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReservationsPage(
                          puedeGestionar: false,
                          puedeCrear: true,
                        ),
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
                        builder: (_) => const RequestsPage(
                          puedeGestionar: false,
                          puedeCrear: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // CATEGORÍAS POPULARES
          if (categoriasPopulares.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                // TODO: traducir "Categorías Populares"
                'Categorías Populares',
                style: tt.labelLarge?.copyWith(color: cs.onSurface),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categoriasPopulares.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final entry = categoriasPopulares[index];
                  return _CategoryCard(
                    categoria: entry.key,
                    count: entry.value,
                    cs: cs,
                    tt: tt,
                    s: s,
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ACTIVIDADES DESTACADAS - CARRUSEL
          if (actividadesRecientes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actividades Destacadas',
                    style: tt.labelLarge?.copyWith(color: cs.onSurface),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navegar a página de actividades
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ActivitiesPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Ver todas',
                      style: tt.labelSmall?.copyWith(color: cs.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: actividadesRecientes.length,
                itemBuilder: (context, index) {
                  final actividad = actividadesRecientes[index];
                  return _ActivityCarouselCard(
                    actividad: actividad,
                    cs: cs,
                    tt: tt,
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],

          // MIS SOLICITUDES RECIENTES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              s.recentRequests,
              style: tt.labelLarge?.copyWith(color: cs.onSurface),
            ),
          ),
          const SizedBox(height: 12),

          if (misSolicitudes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.noRequestsYet,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...misSolicitudes.take(3).map((Request solicitud) {
              final Activity? act = ref.watch(
                activityByIdProvider(solicitud.activityId),
              );
              if (act == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: RequestCard(
                  solicitud: solicitud,
                  actividad: act,
                  nombreUsuario: '${usuario.name} ${usuario.surname}',
                ),
              );
            }),
        ],
      ),
    );
  }
}

// CARD DE CATEGORÍA HORIZONTAL
class _CategoryCard extends StatelessWidget {
  final Category categoria;
  final int count;
  final ColorScheme cs;
  final TextTheme tt;
  final AppLocalizations s;

  const _CategoryCard({
    required this.categoria,
    required this.count,
    required this.cs,
    required this.tt,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.12),
            cs.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(categoria),
                color: cs.primary,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria.localizedLabel(s),
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ${count == 1 ? "actividad" : "actividades"}',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(Category cat) {
    return switch (cat) {
      Category.acuatico => Icons.kayaking,
      Category.montana => Icons.terrain,
      Category.nieve => Icons.ac_unit,
      _ => Icons.hiking,
    };
  }
}

// CARD DE ACTIVIDAD PARA CARRUSEL
class _ActivityCarouselCard extends StatelessWidget {
  final Activity actividad;
  final ColorScheme cs;
  final TextTheme tt;

  const _ActivityCarouselCard({
    required this.actividad,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer,
                  cs.primaryContainer.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: actividad.imageAsset != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        actividad.imageAsset!,
                        fit: BoxFit.cover,
                      ),
                      // Degradado overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(
                      Icons.landscape,
                      size: 48,
                      color: cs.onPrimaryContainer.withValues(alpha: 0.5),
                    ),
                  ),
          ),

          // CONTENIDO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${actividad.startPoint} → ${actividad.endPoint}',
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${actividad.maxParticipants} plazas',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (actividad.price > 0)
                        Text(
                          '${actividad.price.toStringAsFixed(0)}€',
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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
      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
    );
  }
}