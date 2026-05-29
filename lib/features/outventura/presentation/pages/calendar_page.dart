import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/app/theme/app_text_styles.dart';
import 'package:outventura/core/widgets/evento_tile.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // 🌟 Método auxiliar para agrupar las reservas y excursiones de un día concreto
  List<Booking> _eventosDelDia(
    DateTime day,
    List<Booking> misReservas,
    List<Booking> misSolicitudes,
  ) {
    final res = misReservas.where((r) => isSameDay(r.startDate, day)).toList();
    final sol = misSolicitudes
        .where((s) => isSameDay(s.startDate, day))
        .toList();
    return [...res, ...sol];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    final usuarioActual = ref.watch(currentUserProvider);
    final List<Booking> todasLasReservas =
        ref.watch(reservationsProvider).value ?? [];

    final bool isAdmin =
        usuarioActual?.role.code == 'ADMIN' ||
        usuarioActual?.role.code == 'SUPER';

    // 🌟 SEPARACIÓN LOGÍSTICA: Dividimos la colección para alimentar tus badges originales de la UI
    // Excursiones (Antiguas solicitudes): Tienen alguna línea con ID de actividad
    final misSolicitudes = todasLasReservas.where((r) {
      if (!isAdmin && r.userId != usuarioActual?.id) return false;
      return r.lines.any((l) => l.activityId != null);
    }).toList();

    // Alquiler de Material (Antiguas reservas): No tienen ninguna actividad vinculada
    final misReservas = todasLasReservas.where((r) {
      if (!isAdmin && r.userId != usuarioActual?.id) return false;
      return !r.lines.any((l) => l.activityId != null);
    }).toList();

    final eventosSeleccionados = _selectedDay != null
        ? _eventosDelDia(_selectedDay!, misReservas, misSolicitudes)
        : <Booking>[];

    // Leyenda de colores original
    final colorReserva = cs.tertiary;
    final colorSolicitud = cs.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: s.calendarTitle),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Espaciador exacto original debajo del AppBar plano
          ColoredBox(
            color: cs.surface,
            child: SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight + 25,
              width: double.infinity,
            ),
          ),
          ColoredBox(
            color: cs.surface,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TableCalendar<Booking>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) =>
                    _eventosDelDia(day, misReservas, misSolicitudes),
                locale: Localizations.localeOf(context).toString(),
                startingDayOfWeek: StartingDayOfWeek.monday,

                // Estilo del header original (mes y flechas)
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  titleTextStyle: AppTextStyles.titleMedium.copyWith(
                    color: cs.onSurface,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: cs.onSurfaceVariant,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: cs.onSurfaceVariant,
                  ),
                ),

                // Estilo de la fila de días de la semana original
                daysOfWeekHeight: 36,
                daysOfWeekStyle: DaysOfWeekStyle(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  weekdayStyle: AppTextStyles.labelMedium.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  weekendStyle: AppTextStyles.labelMedium.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                  ),
                ),

                calendarBuilders: CalendarBuilders<Booking>(
                  dowBuilder: (context, day) {
                    final days = [
                      s.monShort,
                      s.tueShort,
                      s.wedShort,
                      s.thuShort,
                      s.friShort,
                      s.satShort,
                      s.sunShort,
                    ];
                    final label = days[day.weekday - 1];
                    final isWeekend = day.weekday == 6 || day.weekday == 7;
                    return Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isWeekend
                              ? cs.onSurfaceVariant.withValues(alpha: 0.55)
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  },

                  // Celda seleccionada original: fondo blanco + círculo azul
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: cs.onTertiary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    );
                  },

                  // 🌟 TU MARCADOR ORIGINAL RESTAURADO: Badges con Wrap e incrementos numéricos por texto
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox.shrink();

                    // Contamos según las dos colecciones relacionales del BackEnd
                    final reservasCount = events
                        .where((b) => !b.lines.any((l) => l.activityId != null))
                        .length;
                    final solicitudesCount = events
                        .where((b) => b.lines.any((l) => l.activityId != null))
                        .length;

                    return Positioned(
                      bottom: 2,
                      left: 2,
                      right: 2,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 3,
                        runSpacing: 2,
                        children: [
                          if (reservasCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: colorReserva,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.reservationsBadge(reservasCount),
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (solicitudesCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: colorSolicitud,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.requestsBadge(solicitudesCount),
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                // Altura de las filas original
                rowHeight: 55,

                // Estilo de las celdas original al 100%
                calendarStyle: CalendarStyle(
                  cellMargin: EdgeInsets.zero,
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: cs.onTertiary, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: AppTextStyles.bodySmall.copyWith(
                    color: cs.onTertiary,
                  ),
                  outsideTextStyle: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.28),
                  ),
                  outsideDaysVisible: true,
                  defaultTextStyle: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurface,
                  ),
                  weekendTextStyle: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurface,
                  ),
                  defaultDecoration: BoxDecoration(color: cs.surface),
                  weekendDecoration: BoxDecoration(color: cs.surface),
                  outsideDecoration: BoxDecoration(color: cs.surface),
                ),
              ),
            ),
          ),

          Divider(
            height: 1,
            color: cs.onSurfaceVariant.withValues(alpha: 0.12),
          ),

          // 🌟 TUS CARDS ORIGINALES RESTAURADAS: ListView con EventoTile adaptado
          Expanded(
            child: eventosSeleccionados.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: eventosSeleccionados.length,
                    itemBuilder: (context, index) {
                      final Booking evento = eventosSeleccionados[index];
                      final bool esExcursion = evento.lines.any(
                        (l) => l.activityId != null,
                      );

                      if (!esExcursion) {
                        // Alquiler de Material puro (Antigua Reserva)
                        return EventoTile(
                          titulo: s.reservationEvent,
                          subtitulo: evento.status.localizedLabel(s),
                          color: colorReserva,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReservationDetailPage(reserva: evento),
                            ),
                          ),
                        );
                      } else {
                        // Excursión programada (Antigua Solicitud)
                        return EventoTile(
                          titulo: s.requestEvent,
                          subtitulo: evento.status.localizedLabel(s),
                          color: colorSolicitud,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReservationDetailPage(reserva: evento),
                            ),
                          ),
                        );
                      }
                    },
                  )
                : Center(
                    child: Text(
                      _selectedDay != null
                          ? s.noEventsToday
                          : "Selecciona un día para ver las reservas y solicitudes",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.50),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
