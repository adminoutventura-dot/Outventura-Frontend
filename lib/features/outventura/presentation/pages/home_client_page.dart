import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/widgets/evento_tile.dart';
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
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/pages/request_detail_page.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/home_app_bar_delegate.dart';
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
    final locale = Localizations.localeOf(context).languageCode;

    final today = DateTime.now();
    final rawDate = DateFormat.yMMMMEEEEd(locale).format(today);
    final dateStr = rawDate[0].toUpperCase() + rawDate.substring(1);

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

    // Ordenar categorías por número de actividades y convertir a lista.
    final categoriasPopulares = categoriasCount.entries.toList();
    categoriasPopulares.sort((categoria1, categoria2) => categoria2.value.compareTo(categoria1.value));

    return Scaffold(
      backgroundColor: cs.surface,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: HomeAppBarDelegate(
              topPadding: MediaQuery.of(context).padding.top,
              title: s.clientPanel,
              greeting: s.greeting(usuario.name),
              dateStr: dateStr,
              statSlots: [
                // Número de reservas activas (confirmadas o en curso)
                HomeStatSlot(value: '${misReservas.length}', label: s.myReservations),
                // Número de solicitudes activas (pendientes o confirmadas)
                HomeStatSlot(value: '${misSolicitudes.length}', label: s.myRequests),
                // Número de solicitudes pendientes
                HomeStatSlot(value: '$solicitudesPendientes', label: s.pendingLabel),
              ],
              collapsedHeight: 32.0,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 40),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < categoriasPopulares.length.clamp(0, 4); i++) ...[
                    if (i > 0) _HeaderDivider(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.50)),
                    Expanded(
                      child: StatCard(
                        value: '${categoriasPopulares[i].value}',
                        label: categoriasPopulares[i].key.localizedLabel(s),
                        foregroundColor: [cs.primary, cs.tertiary, cs.secondary, cs.onSurfaceVariant][i],
                      ),
                    ),
                  ],
                ],
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
                  // TODO: traducir "Actividades Destacadas"
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

          // MIS ACTIVIDADES RECIENTES (reservas activas + solicitudes pendientes)
          if (misReservas.where((r) => r.status == BookingStatus.confirmada || r.status == BookingStatus.enCurso).isNotEmpty ||
              misSolicitudes.where((s) => s.status == RequestStatus.pendiente || s.status == RequestStatus.confirmada).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                s.recentActivity,
                style: tt.labelLarge?.copyWith(color: cs.onSurface),
              ),
            ),
            // Solicitudes pendientes o confirmadas
            for (final sol in misSolicitudes
                .where((s) => s.status == RequestStatus.pendiente || s.status == RequestStatus.confirmada)
                .take(2))
              EventoTile(
                titulo: s.requestEvent(sol.id),
                subtitulo: ref.watch(activityByIdProvider(sol.activityId))?.title ?? s.unknown,
                color: cs.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RequestDetailPage(solicitud: sol)),
                ),
              ),
            // Reservas confirmadas o en curso
            for (final res in misReservas
                .where((r) => r.status == BookingStatus.confirmada || r.status == BookingStatus.enCurso)
                .take(2))
              EventoTile(
                titulo: s.reservationEvent(res.id),
                subtitulo: res.activityId != null
                    ? ref.watch(activityByIdProvider(res.activityId!))?.title ?? s.unknown
                    : s.unknown,
                color: cs.tertiary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ReservationDetailPage(reserva: res)),
                ),
              ),
                ],
        ],
        ),
            ),
          ),
        ],
      ),
    );
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
  final Color? color;
  const _HeaderDivider({this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: color ?? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
    );
  }
}
