import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outventura/core/widgets/evento_tile.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/request_detail_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservations_page.dart';
import 'package:outventura/features/outventura/presentation/pages/requests_page.dart';
import 'package:outventura/features/outventura/presentation/pages/users_page.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/legend_item.dart';
import 'package:outventura/features/outventura/presentation/widgets/weekly_bar_chart.dart';
import 'package:outventura/features/outventura/presentation/widgets/home_app_bar_delegate.dart';
import 'package:outventura/features/outventura/presentation/providers/dashboard_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class HomeAdminPage extends ConsumerWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final String adminName = ref.watch(currentUserProvider)?.name ?? '';
    final reservas = ref.watch(reservationsProvider).value ?? [];
    final solicitudes = ref.watch(requestsProvider).value ?? [];
    final stats = ref.watch(adminRequestsStatsProvider);
    final daily = ref.watch(adminDailyStatsProvider);
    final weeklyData = ref.watch(weeklyStatsProvider);

    final today = DateTime.now();
    final rawDate = DateFormat.yMMMMEEEEd(locale).format(today);
    final dateStr = rawDate[0].toUpperCase() + rawDate.substring(1);
    final greeting = adminName.isNotEmpty ? s.greeting(adminName) : s.adminPanel;

    return Scaffold(
      backgroundColor: cs.onPrimary,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          // TODO: Extilo de titulo que sea igual a las otras paginas
          // -- HEADER COLAPSABLE --
          SliverPersistentHeader(
            pinned: true,
            delegate: HomeAppBarDelegate(
              topPadding: MediaQuery.of(context).padding.top,
              title: s.adminPanel,
              greeting: greeting,
              dateStr: dateStr,
              statSlots: [
                // Actividades de hoy
                HomeStatSlot(value: '${daily.actividadesHoy}', label: s.activitiesToday),
                // Reservas de hoy
                HomeStatSlot(value: '${daily.reservasHoy}', label: s.reservationsToday),
                // Solicitudes en curso
                HomeStatSlot(value: '${stats.enCurso}', label: s.requestsActive),
              ],
              collapsedHeight: 32.0,
            ),
          ),

          // -- CONTENIDO --
          SliverPadding(
            padding: EdgeInsets.only(
              // Reiniciamos a 0 para que nazca pegado al header
              top: 20, 
              bottom: MediaQuery.of(context).padding.bottom + 40,
            ),
            sliver: SliverToBoxAdapter(
              // Aplicamos el Transform para empujar todo hacia arriba
              child: Transform.translate(
                offset: const Offset(0, -35), // <-- AJUSTA ESTE NÚMERO
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // MENÚ RÁPIDO
                    IntrinsicHeight( 
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Usuarios
                          Expanded(
                            child: _QuickActionButton(
                              label: s.usersTitle,
                              textColor: cs.onSurfaceVariant,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const UsersPage(),
                                ),
                              ),
                            ),
                          ),
                          
                          // Separador sin márgenes
                          Container(
                            width: 1,
                            color: cs.surface,
                          ),
                    
                          // Reservas
                          Expanded(
                            child: _QuickActionButton(
                              label: s.reservationsTitle,
                              textColor: cs.onSurfaceVariant,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ReservationsPage(
                                    puedeGestionar: true,
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
                    
                          // Solicitudes
                          Expanded(
                            child: _QuickActionButton(
                              label: s.requestsTitle,
                              textColor: cs.onSurfaceVariant,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RequestsPage(
                                    puedeGestionar: true,
                                    puedeCrear: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // GRÁFICO SEMANAL
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        s.weeklyOverview.toUpperCase(),
                        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 210,
                        padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.onSurface.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: WeeklyBarChart(
                          reservasData: weeklyData.reservasData,
                          solicitudesData: weeklyData.solicitudesData,
                          cs: cs,
                          tt: tt,
                          dayLabels: [ s.mon, s.tue, s.wed, s.thu, s.fri, s.sat, s.sun],
                          reservasLabel: s.reservationsTitle,
                          solicitudesLabel: s.requestsTitle,
                        ),
                      ),
                    ),

                    // Texto: estado actual de solicitudes
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        s.requestsByStatus.toUpperCase(),
                        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),

                    // Gráfico de pastel con número de solicitudes por estado
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.onSurface.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        // Si no hay solicitudes, muestra un mensaje centrado. 
                        child: solicitudes.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    s.allGood,
                                    style: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  // Gráfico de pastel con segmentos para cada estado de solicitud.
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 24,
                                        sections: [
                                          if (stats.pendientes > 0) 
                                            PieChartSectionData(value: stats.pendientes.toDouble(), color: cs.tertiary, radius: 28, showTitle: false),
                                          if (stats.confirmadas > 0) 
                                            PieChartSectionData(value: stats.confirmadas.toDouble(), color: cs.primary, radius: 28, showTitle: false),
                                          if (stats.enCurso > 0) 
                                            PieChartSectionData(value: stats.enCurso.toDouble(), color: cs.secondary, radius: 28, showTitle: false),
                                          if (stats.finalizadas > 0) 
                                            PieChartSectionData(value: stats.finalizadas.toDouble(), color: cs.onSurfaceVariant, radius: 28, showTitle: false),
                                          if (stats.canceladas > 0) 
                                            PieChartSectionData(value: stats.canceladas.toDouble(), color: cs.error, radius: 28, showTitle: false),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Leyenda con número de solicitudes por estado.
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (stats.pendientes > 0) LegendItem(color: cs.tertiary, label: s.pending, value: stats.pendientes, tt: tt, cs: cs),
                                        if (stats.confirmadas > 0) LegendItem(color: cs.primary, label: s.confirmed, value: stats.confirmadas, tt: tt, cs: cs),
                                        if (stats.enCurso > 0) LegendItem(color: cs.secondary, label: s.inProgress, value: stats.enCurso, tt: tt, cs: cs),
                                        if (stats.finalizadas > 0) LegendItem(color: cs.onSurfaceVariant, label: s.finished, value: stats.finalizadas, tt: tt, cs: cs),
                                        if (stats.canceladas > 0) LegendItem(color: cs.error, label: s.cancelled, value: stats.canceladas, tt: tt, cs: cs),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // ACTIVIDAD RECIENTE 
                    if (solicitudes.where((r) => r.status == RequestStatus.pendiente).isNotEmpty ||
                        reservas.where((r) => r.status == BookingStatus.confirmada || r.status == BookingStatus.enCurso).isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          s.recentActivity.toUpperCase(),
                          style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),

                      // Muestra hasta 2 solicitudes pendientes y 2 reservas activas más recientes.
                      for (final r in solicitudes.where((r) => r.status == RequestStatus.pendiente).take(2))
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: EventoTile(
                            titulo: s.requestEvent(r.id),
                            subtitulo: ref.watch(activityByIdProvider(r.activityId))?.title ?? s.unknown,
                            color: cs.primary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RequestDetailPage(solicitud: r),
                              ),
                            ),
                          ),
                        ),

                      // Recorre las reservas confirmadas o en curso, muestra las 2 más recientes.
                      for (final r in reservas.where( (r) => r.status == BookingStatus.confirmada || r.status == BookingStatus.enCurso).take(2))
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: EventoTile(
                            titulo: s.reservationEvent(r.id),
                            subtitulo: r.activityId != null
                                ? ref.watch(activityByIdProvider(r.activityId!))?.title ?? s.unknown
                                : s.unknown,
                            color: cs.tertiary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReservationDetailPage(reserva: r),
                              ),
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}