import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/presentation/pages/booking_detail_page.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/activity_detail_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    // ROL DEL USUARIO
    final usuarioActual = ref.watch(currentUserProvider);
    final bool isGuest = usuarioActual == null ||
        usuarioActual.role.code == 'INVITADO' ||
        usuarioActual.role.code == 'GUEST';
    final bool isAdmin = usuarioActual?.role.code == 'ADMIN' ||
        usuarioActual?.role.code == 'SUPER';

    // DATOS
    final List<Booking> todasLasReservas =
        ref.watch(reservationsProvider).value ?? [];
    final List<Activity> todasLasActividades = 
        ref.watch(activitiesProvider).value ?? [];

    // RESERVAS (Solo si no es invitado)
    List<Booking> misSolicitudes = [];
    List<Booking> misReservas = [];

    if (!isGuest) {
      misSolicitudes = todasLasReservas.where((r) {
        // Si no es admin, solo ve lo suyo
        if (!isAdmin && r.userId != usuarioActual.id) return false;
        return r.lines.any((l) => l.activityId != null);
      }).toList();

      misReservas = todasLasReservas.where((r) {
        if (!isAdmin && r.userId != usuarioActual.id) return false;
        return !r.lines.any((l) => l.activityId != null);
      }).toList();
    }

    // NUEVO MOTOR DE EVENTOS SEGÚN EL ROL
    List<dynamic> eventosDelDia(DateTime day) {
      if (isGuest) {
        // Si es INVITADO, devuelve las Actividades disponibles ese día
        return todasLasActividades
            .where((a) => isSameDay(a.initDate, day))
            .toList();
      } else {
        // Si es USUARIO (ve lo suyo) o ADMIN (ve todo), devuelve los Bookings
        final res = misReservas.where((r) => isSameDay(r.startDate, day)).toList();
        final sol = misSolicitudes.where((s) => isSameDay(s.startDate, day)).toList();
        return [...res, ...sol];
      }
    }

    final eventosSeleccionados = _selectedDay != null
        ? eventosDelDia(_selectedDay!)
        : [];

    // Colores de la leyenda
    final colorReserva = cs.tertiary;
    final colorSolicitud = cs.primary;
    final colorActividad = cs.secondary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: s.calendarTitle),
      drawer: const AppDrawer(),
      body: Column(
        children: [
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
              child: TableCalendar<dynamic>(
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
                eventLoader: (day) => eventosDelDia(day),
                locale: Localizations.localeOf(context).toString(),
                startingDayOfWeek: StartingDayOfWeek.monday,

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

                calendarBuilders: CalendarBuilders<dynamic>(
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

                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox.shrink();

                    int reservasCount = 0;
                    int solicitudesCount = 0;
                    int actividadesCount = 0;

                    for (final e in events) {
                      if (e is Booking) {
                        if (e.lines.any((l) => l.activityId != null)) {
                          solicitudesCount++;
                        } else {
                          reservasCount++;
                        }
                      } else if (e is Activity) {
                        actividadesCount++;
                      }
                    }

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
                                style: AppTextStyles.titleSmall.copyWith(color: cs.surface),
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
                                style: AppTextStyles.titleSmall.copyWith(color: cs.surface),
                              ),
                            ),
                          // BADGE PARA ACTIVIDADES DEL CATÁLOGO (Invitados)
                          if (actividadesCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: colorActividad,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$actividadesCount A', // TODO: HARCODEADO Usa s.actividadesTitle si tienes
                                style: AppTextStyles.titleSmall.copyWith(color: cs.surface),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                rowHeight: 55,
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
          Expanded(
            child: eventosSeleccionados.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: eventosSeleccionados.length,
                    itemBuilder: (context, index) {
                      final dynamic evento = eventosSeleccionados[index];

                      // RENDERIZADO SEGÚN EL TIPO DE EVENTO
                      if (evento is Activity) {
                        return EventoTile(
                          titulo: 'Excursión programada',
                          subtitulo: evento.title,
                          color: colorActividad,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ActivityDetailPage(actividad: evento),
                            ),
                          ),
                        );
                      } else if (evento is Booking) {
                        final bool esExcursion = evento.lines.any(
                          (l) => l.activityId != null,
                        );

                        if (!esExcursion) {
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
                      }
                      return const SizedBox.shrink();
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