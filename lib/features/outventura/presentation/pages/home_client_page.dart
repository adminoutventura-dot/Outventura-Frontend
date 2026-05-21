import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outventura/core/widgets/evento_tile.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
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

    // Si usuario.id es nulo, pasa un 0 de forma segura.
    final int safeId = usuario.id ?? 0;

    final List<Booking> misReservas = ref.watch(userReservationsProvider(safeId));
    final List<Request> misSolicitudes = ref.watch(userRequestsProvider(safeId));
    final int solicitudesPendientes = ref.watch(userPendingRequestsCountProvider(safeId));

    // Últimas 5 actividades para el carrusel
    final actividadesRecientes = ref.watch(recentActivitiesProvider(5));

    return Scaffold(
      backgroundColor: cs.onPrimary,
      // Extender el cuerpo por detrás del AppBar
      extendBodyBehindAppBar: true, 
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          // TODO: Texto de header igual al de otras paginas
          // -- HEADER COLAPSABLE --
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
          
          // -- CONTENIDO --
          SliverPadding(
            padding: EdgeInsets.only(
              top: 20, 
              bottom: MediaQuery.of(context).padding.bottom + 40,
            ),
            sliver: SliverToBoxAdapter(
              // Aplicamos el Transform para empujar todo hacia arriba
              child: Transform.translate(
                offset: const Offset(0, -35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // MENÚ RÁPIDO SUPERIOR
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Mis Reservas
                          Expanded(
                            child: _QuickActionButton(
                              label: s.myReservationsBtn,
                              textColor: cs.onSurfaceVariant,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ReservationsPage(
                                    puedeGestionar: false,
                                    puedeCrear: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Separador sin márgenes
                          Container(
                            width: 1,
                            color: cs.surface,
                          ),
                    
                          // Mis Solicitudes
                          Expanded(
                            child: _QuickActionButton(
                              label: s.myRequestsBtn,
                              textColor: cs.onSurfaceVariant,
                              onTap: () => Navigator.of(context).push(
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

                    // ACTIVIDADES DESTACADAS - CARRUSEL
                    if (actividadesRecientes.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          // TODO: traducir "Actividades Destacadas"
                          'Actividades Destacadas'.toUpperCase(),
                          style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
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

                    // MIS ACTIVIDADES RECIENTES (reservas activas + solicitudes pendientes)
                    if (misReservas.where((r) => r.status == BookingStatus.confirmada || r.status == BookingStatus.enCurso).isNotEmpty ||
                        misSolicitudes.where((s) => s.status == RequestStatus.pendiente || s.status == RequestStatus.confirmada).isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          s.recentActivity.toUpperCase(),
                          style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                      // Solicitudes pendientes o confirmadas
                      for (final sol in misSolicitudes
                          .where((s) => s.status == RequestStatus.pendiente || s.status == RequestStatus.confirmada)
                          .take(2))
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: EventoTile(
                            titulo: s.requestEvent,
                            subtitulo: ref.watch(activityNameProvider(sol.activityId)) ?? s.unknown,
                            color: cs.primary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => RequestDetailPage(solicitud: sol)),
                            ),
                          ),
                        ),
                      // Reservas confirmadas o en curso
                      for (final res in misReservas
                          .where((r) => r.status == BookingStatus.confirmada || r.status == BookingStatus.enCurso)
                          .take(2))
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: EventoTile(
                            titulo: s.reservationEvent,
                            subtitulo: ref.watch(activityNameProvider(res.activityId)) ?? s.unknown,
                            color: cs.tertiary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ReservationDetailPage(reserva: res)),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
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

// Componente para los botones del menú de lado a lado
class _QuickActionButton extends StatelessWidget {
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(top: 30, bottom: 25),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}