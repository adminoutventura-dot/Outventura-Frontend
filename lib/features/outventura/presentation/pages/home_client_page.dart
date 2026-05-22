import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outventura/core/widgets/evento_tile.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
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
import 'package:outventura/features/outventura/presentation/widgets/home_shared_widgets.dart';
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

    final List<Booking> misReservas = ref.watch(userReservationsProvider(usuario.id!));
    final List<Request> misSolicitudes = ref.watch(userRequestsProvider(usuario.id!));
    final int solicitudesPendientes = ref.watch(userPendingRequestsCountProvider(usuario.id!));

    // Últimas 5 actividades para el carrusel
    final actividadesRecientes = ref.watch(recentActivitiesProvider(5));

    return Scaffold(
      backgroundColor: cs.onPrimary,
      // Extender el cuerpo por detrás del AppBar
      extendBodyBehindAppBar: true, 
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
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
                            child: HomeQuickActionButton(
                              label: s.myReservationsBtn,
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
                            child: HomeQuickActionButton(
                              label: s.myRequestsBtn,
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
                            return ActivityCarouselCard(actividad: actividad);
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // MIS ACTIVIDADES RECIENTES (reservas activas + solicitudes pendientes)
                    if (misReservas.where((r) => r.status == WorkflowStatus.confirmada || r.status == WorkflowStatus.enCurso).isNotEmpty ||
                        misSolicitudes.where((s) => s.status == WorkflowStatus.pendiente || s.status == WorkflowStatus.confirmada).isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          s.recentActivity.toUpperCase(),
                          style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                      // Solicitudes pendientes o confirmadas
                      for (final sol in misSolicitudes
                          .where((s) => s.status == WorkflowStatus.pendiente || s.status == WorkflowStatus.confirmada)
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
                          .where((r) => r.status == WorkflowStatus.confirmada || r.status == WorkflowStatus.enCurso)
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