import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outventura/core/widgets/evento_tile.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/presentation/pages/booking_page.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/booking_act_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
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

    final bool isGuest =
        usuario.role.code == 'INVITADO' || usuario.role.code == 'GUEST';

    final today = DateTime.now();
    final rawDate = DateFormat.yMMMMEEEEd(locale).format(today);
    final dateStr = rawDate[0].toUpperCase() + rawDate.substring(1);

    final List<Booking> todasMisReservas = isGuest
        ? []
        : (ref.watch(reservationsProvider).value ?? [])
              .where((r) => r.userId == usuario.id)
              .toList();

    final misReservasMateriales = todasMisReservas
        .where((b) => !b.lines.any((l) => l.activityId != null))
        .toList();
    final misExcursiones = todasMisReservas
        .where((b) => b.lines.any((l) => l.activityId != null))
        .toList();
    final int pendientes = misExcursiones
        .where((b) => b.status == WorkflowStatus.pendiente)
        .length;

    final actividadesRecientes = ref.watch(recentActivitiesProvider(5));

    return Scaffold(
      backgroundColor: cs.onPrimary,
      extendBodyBehindAppBar: true,
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
                HomeStatSlot(
                  value: '${misReservasMateriales.length}',
                  label: s.myReservations,
                ),
                HomeStatSlot(
                  value: '${misExcursiones.length}',
                  label: s.myRequests,
                ),
                HomeStatSlot(value: '$pendientes', label: s.pendingLabel),
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
                    if (!isGuest)
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
                                label: s.myRequestsBtn,
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
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),
                    if (actividadesRecientes.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Actividades Destacadas'.toUpperCase(),
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
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
                    ],

                    if (!isGuest && todasMisReservas.isNotEmpty) ...[
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
                      for (final sol in misExcursiones.take(2))
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
                                    sol.lines
                                        .firstWhere((l) => l.activityId != null)
                                        .activityId,
                                  ),
                                ) ??
                                s.unknown,
                            color: cs.primary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                // Cambiado 'reserva' por 'solicitud'
                                builder: (_) =>
                                    BookingActFormPage(reserva: sol),
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
