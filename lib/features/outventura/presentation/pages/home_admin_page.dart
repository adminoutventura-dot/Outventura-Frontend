import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outventura/core/widgets/evento_tile.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/pages/booking_page.dart';
import 'package:outventura/features/outventura/presentation/pages/users_page.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/home_shared_widgets.dart';
import 'package:outventura/features/outventura/presentation/widgets/legend_item.dart';
import 'package:outventura/features/outventura/presentation/widgets/weekly_bar_chart.dart';
import 'package:outventura/features/outventura/presentation/widgets/home_app_bar_delegate.dart';
import 'package:outventura/features/outventura/presentation/providers/dashboard_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/booking_form_page.dart';
import 'package:outventura/l10n/app_localizations.dart';
class HomeAdminPage extends ConsumerWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final currentUser = ref.watch(currentUserProvider);
    final String adminName = currentUser?.name ?? '';
    final bool isGuide = currentUser?.role.code == 'GUIDE';
    final bool isAdmin = currentUser?.role.code == 'ADMIN';

    final reservasAsync = ref.watch(allReservationsProvider);
    final dashboardStatsAsync = ref.watch(adminDashboardStatsProvider);

    final today = DateTime.now();
    final rawDate = DateFormat.yMMMMEEEEd(locale).format(today);
    final dateStr = rawDate[0].toUpperCase() + rawDate.substring(1);
    final greeting = adminName.isNotEmpty
        ? s.greeting(adminName)
        : s.adminPanel;

    return Scaffold(
      backgroundColor: cs.onPrimary,
      drawer: const AppDrawer(),
      body: dashboardStatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(s.error(err.toString()))),
        data: (statsMap) {
          final reservas = reservasAsync.value ?? [];
          final pendientes = statsMap['pendientesAprobacion'] ?? 0;
          final materialesHoy = statsMap['materialesHoy'] ?? 0;
          final actividadesHoy = statsMap['actividadesHoy'] ?? 0;

          final excursionesPendientes = reservas.where((b) {
            final tieneActividad = b.lines.any((l) => l.activityId != null);
            return tieneActividad && b.status == WorkflowStatus.pendiente;
          }).toList();

          // Calcular reservas por día de la semana actual para el gráfico
          final weeklyActividades = List<double>.filled(7, 0.0);
          final weeklyMateriales = List<double>.filled(7, 0.0);

          final hoy = DateTime.now();
          final inicioSemana = DateTime(hoy.year, hoy.month, hoy.day)
              .subtract(Duration(days: hoy.weekday - 1));
          final finSemana = inicioSemana.add(const Duration(days: 7));

          final reservasSemana = reservas.where((r) {
            final fecha = r.startDate;
            return !fecha.isBefore(inicioSemana) && fecha.isBefore(finSemana);
          });

          for (final reserva in reservasSemana) {
            final reservaDate = reserva.startDate;
            final dayIndex = reservaDate.weekday - 1; // lunes = 0, domingo = 6
            if (dayIndex >= 0 && dayIndex < 7) {
              final tieneActividad = reserva.lines.any((l) => l.activityId != null);
              if (tieneActividad) {
                weeklyActividades[dayIndex]++;
              } else {
                weeklyMateriales[dayIndex]++;
              }
            }
          }

          // Calcular reservas por estado para el gráfico circular
          final pendingCount = reservas.where((b) => b.status.code == 'PENDING').length;
          final acceptedCount = reservas.where((b) => b.status.code == 'ACCEPTED').length;
          final inProgressCount = reservas.where((b) => b.status.code == 'IN_PROGRESS').length;
          final finishedCount = reservas.where((b) => b.status.code == 'FINISHED').length;
          final cancelledCount = reservas.where((b) => b.status.code == 'CANCELLED').length;

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeAppBarDelegate(
                  topPadding: MediaQuery.of(context).padding.top,
                  title: s.adminPanel,
                  greeting: greeting,
                  dateStr: dateStr,
                  statSlots: [
                    HomeStatSlot(
                      value: '$actividadesHoy',
                      label: s.activitiesToday,
                    ),
                    HomeStatSlot(
                      value: '$materialesHoy',
                      label: s.materialReservationsToday,
                    ),
                    HomeStatSlot(value: '$pendientes', label: s.pending),
                  ],
                  collapsedHeight: 32.0,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 40,
                ),
                // Cambiado 'child' por 'sliver'
                sliver: SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                              Container(width: 1, color: cs.surface),
                              Expanded(
                                child: HomeQuickActionButton(
                                  label: s.myActivitiesBtn,
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
                              if (!isGuide) ...[
                                Container(width: 1, color: cs.surface),
                                Expanded(
                                  child: HomeQuickActionButton(
                                  label: isAdmin ? 'Guías' : s.usersTitle,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => UsersPage(
                                          soloGuiasOInferior: isAdmin,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            s.weeklyOverview.toUpperCase(),
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
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
                                color: cs.onSurfaceVariant.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                            child: WeeklyBarChart(
                              actividadesData: weeklyActividades,
                              materialesData: weeklyMateriales,
                              cs: cs,
                              tt: tt,
                              dayLabels: [
                                s.mon,
                                s.tue,
                                s.wed,
                                s.thu,
                                s.fri,
                                s.sat,
                                s.sun,
                              ],
                              actividadesLabel: s.myActivityReservations,
                              materialesLabel: s.myMaterialReservations,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            s.reservationsTitle.toUpperCase(),
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: cs.onSurfaceVariant.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 24,
                                      sections: [
                                        if (pendingCount > 0)
                                          PieChartSectionData(
                                            value: pendingCount.toDouble(),
                                            color: cs.tertiary,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                        if (acceptedCount > 0)
                                          PieChartSectionData(
                                            value: acceptedCount.toDouble(),
                                            color: cs.primary,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                        if (inProgressCount > 0)
                                          PieChartSectionData(
                                            value: inProgressCount.toDouble(),
                                            color: cs.secondary,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                        if (finishedCount > 0)
                                          PieChartSectionData(
                                            value: finishedCount.toDouble(),
                                            color: cs.onSurfaceVariant,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                        if (cancelledCount > 0)
                                          PieChartSectionData(
                                            value: cancelledCount.toDouble(),
                                            color: cs.error,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (pendingCount > 0)
                                        LegendItem(
                                          color: cs.tertiary,
                                          label: s.pending,
                                          value: pendingCount,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                      if (acceptedCount > 0)
                                        LegendItem(
                                          color: cs.primary,
                                          label: s.confirmed,
                                          value: acceptedCount,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                      if (inProgressCount > 0)
                                        LegendItem(
                                          color: cs.secondary,
                                          label: s.inProgress,
                                          value: inProgressCount,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                      if (finishedCount > 0)
                                        LegendItem(
                                          color: cs.onSurfaceVariant,
                                          label: s.finished,
                                          value: finishedCount,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                      if (cancelledCount > 0)
                                        LegendItem(
                                          color: cs.error,
                                          label: s.cancelled,
                                          value: cancelledCount,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (excursionesPendientes.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Text(
                              s.recentActivity.toUpperCase(),
                              style: tt.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          for (final r in excursionesPendientes.take(2))
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: EventoTile(
                                titulo: s.reservationEvent,
                                subtitulo:
                                    ref.watch(
                                      activityNameProvider(
                                        r.lines
                                            .firstWhere(
                                              (l) => l.activityId != null,
                                            )
                                            .activityId,
                                      ),
                                    ) ??
                                    s.unknown,
                                color: cs.primary,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BookingFormPage(booking: r),
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
          );
        },
      ),
    );
  }
}
