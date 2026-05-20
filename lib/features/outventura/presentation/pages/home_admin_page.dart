import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/evento_tile.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/request_detail_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservations_page.dart';
import 'package:outventura/features/outventura/presentation/pages/requests_page.dart';
import 'package:outventura/features/outventura/presentation/pages/users_page.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/legend_item.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/weekly_bar_chart.dart';
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
    final usuarios = ref.watch(usuariosProvider).value ?? [];
    final reservas = ref.watch(reservationsProvider).value ?? [];
    final solicitudes = ref.watch(requestsProvider).value ?? [];
    final actividades = ref.watch(activitiesProvider).value ?? [];

    final int pendientes = solicitudes
        .where((r) => r.status == RequestStatus.pendiente)
        .length;
    final int enCurso = solicitudes
        .where((r) => r.status == RequestStatus.enCurso)
        .length;
    final int confirmadas = solicitudes
        .where((r) => r.status == RequestStatus.confirmada)
        .length;
    final int finalizadas = solicitudes
        .where((r) => r.status == RequestStatus.finalizada)
        .length;
    final int canceladas = solicitudes
        .where((r) => r.status == RequestStatus.cancelada)
        .length;

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final int actividadesHoy = actividades
        .where(
          (a) => a.initDate.isBefore(todayEnd) && a.endDate.isAfter(todayStart),
        )
        .length;
    final int reservasHoy = reservas
        .where(
          (r) =>
              r.startDate.isBefore(todayEnd) && r.endDate.isAfter(todayStart),
        )
        .length;

    final double ingresosTotales = solicitudes
        .where(
          (r) =>
              r.status == RequestStatus.confirmada ||
              r.status == RequestStatus.finalizada,
        )
        .fold(0.0, (sum, r) => sum + r.totalPrice);

    final weeklyData = _getWeeklyData(
      reservas,
      solicitudes,
      actividades,
      today,
    );

    final rawDate = DateFormat.yMMMMEEEEd(locale).format(today);
    final dateStr = rawDate[0].toUpperCase() + rawDate.substring(1);
    final greeting = adminName.isNotEmpty
        ? s.greeting(adminName)
        : s.adminPanel;

    return Scaffold(
      backgroundColor: cs.surface,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          // -- HEADER COLAPSABLE --
          SliverPersistentHeader(
            pinned: true,
            delegate: _HomeAppBarDelegate(
              topPadding: MediaQuery.of(context).padding.top,
              title: s.adminPanel,
              greeting: greeting,
              dateStr: dateStr,
              activitiesTodayLabel: s.activitiesToday,
              reservationsTodayLabel: s.reservationsToday,
              requestsActiveLabel: s.requestsActive,
              actividadesHoy: actividadesHoy,
              reservasHoy: reservasHoy,
              enCurso: enCurso,
              collapsedHeight: 32.0, // Cambiar a 72.5 para contraer hasta la mitad
            ),
          ),

          // -- CONTENIDO --
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 40,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // // KPI CARDS //
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: StatCard(
                            value: '${ingresosTotales.toStringAsFixed(0)} €',
                            label: s.revenue,
                            foregroundColor: cs.primary,
                          ),
                        ),
                        _HeaderDivider(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.20),
                        ),
                        Expanded(
                          child: StatCard(
                            value: '${usuarios.length}',
                            label: s.totalUsers,
                            foregroundColor: cs.tertiary,
                          ),
                        ),
                        _HeaderDivider(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.20),
                        ),
                        Expanded(
                          child: StatCard(
                            value: '${reservas.length}',
                            label: s.totalReservations,
                            foregroundColor: cs.secondary,
                          ),
                        ),
                        _HeaderDivider(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.20),
                        ),
                        Expanded(
                          child: StatCard(
                            value: '${solicitudes.length}',
                            label: s.requestsTitle,
                            foregroundColor: pendientes > 0
                                ? cs.error
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // // QUICK ACTIONS //
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      s.quickActions,
                      style: tt.labelLarge?.copyWith(color: cs.onSurface),
                    ),
                  ),
                  // Botones centrados con wrap
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        SecondaryButton(
                          label: s.usersTitle,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const UsersPage(),
                            ),
                          ),
                        ),
                        SecondaryButton(
                          label: s.reservationsTitle,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReservationsPage(
                                puedeGestionar: true,
                                puedeCrear: true,
                              ),
                            ),
                          ),
                        ),
                        SecondaryButton(
                          label: s.requestsTitle,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RequestsPage(
                                puedeGestionar: true,
                                puedeCrear: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // // GRÁFICO SEMANAL //
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      s.weeklyOverview,
                      style: tt.labelLarge?.copyWith(color: cs.onSurface),
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
                        reservasData: weeklyData.$1,
                        solicitudesData: weeklyData.$2,
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

                  // // PIE CHART //
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      s.requestsByStatus,
                      style: tt.labelLarge?.copyWith(color: cs.onSurface),
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
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 24,
                                      sections: [
                                        if (pendientes > 0)
                                          PieChartSectionData(
                                            value: pendientes.toDouble(),
                                            color: cs.tertiary,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                        if (confirmadas > 0)
                                          PieChartSectionData(
                                            value: confirmadas.toDouble(),
                                            color: cs.primary,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                        if (enCurso > 0)
                                          PieChartSectionData(
                                            value: enCurso.toDouble(),
                                            color: cs.secondary,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                        if (finalizadas > 0)
                                          PieChartSectionData(
                                            value: finalizadas.toDouble(),
                                            color: cs.onSurfaceVariant,
                                            radius: 28,
                                            showTitle: false,
                                          ),
                                        if (canceladas > 0)
                                          PieChartSectionData(
                                            value: canceladas.toDouble(),
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
                                      if (pendientes > 0)
                                        LegendItem(
                                          color: cs.tertiary,
                                          label: s.pending,
                                          value: pendientes,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                      if (confirmadas > 0)
                                        LegendItem(
                                          color: cs.primary,
                                          label: s.confirmed,
                                          value: confirmadas,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                      if (enCurso > 0)
                                        LegendItem(
                                          color: cs.secondary,
                                          label: s.inProgress,
                                          value: enCurso,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                      if (finalizadas > 0)
                                        LegendItem(
                                          color: cs.onSurfaceVariant,
                                          label: s.finished,
                                          value: finalizadas,
                                          tt: tt,
                                          cs: cs,
                                        ),
                                      if (canceladas > 0)
                                        LegendItem(
                                          color: cs.error,
                                          label: s.cancelled,
                                          value: canceladas,
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

                  // // ACTIVIDAD RECIENTE //
                  if (solicitudes
                          .where((r) => r.status == RequestStatus.pendiente)
                          .isNotEmpty ||
                      reservas
                          .where(
                            (r) =>
                                r.status == BookingStatus.confirmada ||
                                r.status == BookingStatus.enCurso,
                          )
                          .isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        s.recentActivity,
                        style: tt.labelLarge?.copyWith(color: cs.onSurface),
                      ),
                    ),

                    for (final r
                        in solicitudes
                            .where((r) => r.status == RequestStatus.pendiente)
                            .take(2))
                      EventoTile(
                        titulo: s.requestEvent(r.id),
                        subtitulo: ref.watch(activityByIdProvider(r.activityId))?.title ?? s.unknown,
                        color: cs.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RequestDetailPage(solicitud: r),
                          ),
                        ),
                      ),
                    for (final r
                        in reservas
                            .where(
                              (r) =>
                                  r.status == BookingStatus.confirmada ||
                                  r.status == BookingStatus.enCurso,
                            )
                            .take(2))
                      EventoTile(
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
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (List<double>, List<double>) _getWeeklyData(
    List<Booking> reservas,
    List<Request> solicitudes,
    List<Activity> actividades,
    DateTime today,
  ) {
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final reservasData = List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final dayEnd = day.add(const Duration(days: 1));
      return reservas
          .where((r) => r.startDate.isBefore(dayEnd) && r.endDate.isAfter(day))
          .length
          .toDouble();
    });
    final solicitudesData = List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final dayEnd = day.add(const Duration(days: 1));
      return solicitudes
          .where((s) {
            final act = actividades
                .where((a) => a.id == s.activityId)
                .firstOrNull;
            if (act == null) return false;
            return act.initDate.isBefore(dayEnd) && act.endDate.isAfter(day);
          })
          .length
          .toDouble();
    });
    return (reservasData, solicitudesData);
  }
}

////////////
class _HomeAppBarDelegate extends SliverPersistentHeaderDelegate {
  static const double _kBottomHeight = 145.0;

  final double topPadding;
  final String title;
  final String greeting;
  final String dateStr;
  final String activitiesTodayLabel;
  final String reservationsTodayLabel;
  final String requestsActiveLabel;
  final int actividadesHoy;
  final int reservasHoy;
  final int enCurso;
  final double collapsedHeight;

  const _HomeAppBarDelegate({
    required this.topPadding,
    required this.title,
    required this.greeting,
    required this.dateStr,
    required this.activitiesTodayLabel,
    required this.reservationsTodayLabel,
    required this.requestsActiveLabel,
    required this.actividadesHoy,
    required this.reservasHoy,
    required this.enCurso,
    this.collapsedHeight = 0.0,
  });

  @override
  double get maxExtent => topPadding + kToolbarHeight + _kBottomHeight;

  @override
  double get minExtent => topPadding + kToolbarHeight + collapsedHeight;

  @override
  bool shouldRebuild(covariant _HomeAppBarDelegate old) =>
      old.topPadding != topPadding ||
      old.greeting != greeting ||
      old.dateStr != dateStr ||
      old.actividadesHoy != actividadesHoy ||
      old.reservasHoy != reservasHoy ||
      old.enCurso != enCurso;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = (shrinkOffset / _kBottomHeight).clamp(0.0, 1.0);

    return ClipPath(
      clipper: AppBarClipper(),
      child: Material(
        elevation: overlapsContent ? 4 : 0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(gradient: AppGradients.appBar(cs)),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: _circle(180, cs.onPrimary.withAlpha(18)),
              ),
              Positioned(
                top: 20,
                right: 90,
                child: _circle(80, cs.onPrimary.withAlpha(12)),
              ),
              Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila del toolbar (siempre visible)
                    SizedBox(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu),
                              color: cs.onPrimary,
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              title,
                              style: tt.titleMedium?.copyWith(
                                color: cs.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contenido colapsable
                    SizedBox(
                      height: (maxExtent - shrinkOffset - topPadding - kToolbarHeight)
                          .clamp(0.0, _kBottomHeight),
                      child: OverflowBox(
                        minHeight: 0,
                        maxHeight: _kBottomHeight,
                        alignment: Alignment.topLeft,
                        child: Opacity(
                          opacity: (1 - progress * 2).clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  greeting,
                                  style: tt.titleLarge?.copyWith(
                                    color: cs.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr,
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onPrimary.withValues(alpha: 0.78),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        value: '$actividadesHoy',
                                        label: activitiesTodayLabel,
                                        foregroundColor: cs.onPrimary,
                                      ),
                                    ),
                                    const _HeaderDivider(),
                                    Expanded(
                                      child: StatCard(
                                        value: '$reservasHoy',
                                        label: reservationsTodayLabel,
                                        foregroundColor: cs.onPrimary,
                                      ),
                                    ),
                                    const _HeaderDivider(),
                                    Expanded(
                                      child: StatCard(
                                        value: '$enCurso',
                                        label: requestsActiveLabel,
                                        foregroundColor: cs.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

////////////
class _HeaderDivider extends StatelessWidget {
  final Color? color;

  const _HeaderDivider({this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color:
          color ??
          Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.30),
    );
  }
}
