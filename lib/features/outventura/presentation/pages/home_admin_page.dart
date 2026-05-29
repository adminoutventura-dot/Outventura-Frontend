import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outventura/core/widgets/evento_tile.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservations_page.dart';
import 'package:outventura/features/outventura/presentation/pages/users_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/home_shared_widgets.dart';
import 'package:outventura/features/outventura/presentation/widgets/legend_item.dart';
import 'package:outventura/features/outventura/presentation/widgets/weekly_bar_chart.dart';
import 'package:outventura/features/outventura/presentation/widgets/home_app_bar_delegate.dart';
import 'package:outventura/features/outventura/presentation/providers/dashboard_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/solicitud_form_page.dart';
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

    final reservas = ref.watch(reservationsProvider).value ?? [];
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
          final totalMateriales = statsMap['totalMateriales'] ?? 0;
          final totalExcursiones = statsMap['totalExcursiones'] ?? 0;
          final pendientes = statsMap['pendientesAprobacion'] ?? 0;

          final excursionesPendientes = reservas.where((b) {
            final tieneActividad = b.lines.any((l) => l.activityId != null);
            return tieneActividad && b.status == WorkflowStatus.pendiente;
          }).toList();

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
                      value: '$totalExcursiones',
                      label: s.activitiesToday,
                    ),
                    HomeStatSlot(
                      value: '$totalMateriales',
                      label: s.reservationsToday,
                    ),
                    HomeStatSlot(value: '$pendientes', label: s.requestsActive),
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
                              if (!isGuide) ...[
                                Expanded(
                                  child: HomeQuickActionButton(
                                    label: s.usersTitle,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const UsersPage(),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(width: 1, color: cs.surface),
                              ],
                              Expanded(
                                child: HomeQuickActionButton(
                                  label: s.reservationsTitle,
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
                              reservasData: const [0, 0, 0, 0, 0, 0, 0],
                              solicitudesData: const [0, 0, 0, 0, 0, 0, 0],
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
                              reservasLabel: s.reservationsTitle,
                              solicitudesLabel: s.requestsTitle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            s.requestsByStatus.toUpperCase(),
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
                                        PieChartSectionData(
                                          value: pendientes.toDouble() + 1,
                                          color: cs.tertiary,
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
                                      LegendItem(
                                        color: cs.tertiary,
                                        label: s.pending,
                                        value: pendientes,
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
                                vertical: 4,
                              ),
                              child: EventoTile(
                                titulo: s.requestEvent,
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
                                    // Cambiado 'reserva' por 'solicitud'
                                    builder: (_) =>
                                        SolicitudFormPage(reserva: r),
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
