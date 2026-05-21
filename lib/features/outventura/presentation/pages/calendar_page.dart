import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/pages/request_detail_page.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/controllers/calendar_page_controller.dart';
import 'package:outventura/app/theme/app_text_styles.dart';
import 'package:outventura/core/widgets/evento_tile.dart';

// Wrapper que permite estado local dentro de ConsumerWidget
class CalendarPage extends ConsumerStatefulWidget {
  final User usuario;
  final bool esAdmin;

  const CalendarPage({super.key, required this.usuario, required this.esAdmin});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _controller = CalendarPageController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    final List<Booking> reservas = ref.watch(reservationsProvider).value ?? [];
    final List<Request> solicitudes  = ref.watch(requestsProvider).value ?? [];
    final List<Activity> actividades  = ref.watch(activitiesProvider).value ?? [];

    final misReservas = (widget.esAdmin
            ? reservas
            : reservas.where((r) => r.userId == widget.usuario.id))
        .where((r) => r.status == BookingStatus.confirmada || r.status == BookingStatus.enCurso)
        .toList();

    final misSolicitudes = (widget.esAdmin
            ? solicitudes
            : solicitudes.where((s) => s.userId == widget.usuario.id))
        .where((s) => s.status == RequestStatus.confirmada || s.status == RequestStatus.enCurso)
        .toList();

    final eventosSeleccionados = _selectedDay != null
        ? _controller.eventosDelDia(_selectedDay!, misReservas, misSolicitudes, actividades)
        : <Object>[];

    // Leyenda de colores
    final colorReserva   = cs.tertiary;
    final colorSolicitud = cs.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: s.calendarTitle),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Empuja el contenido justo debajo de la parte plana del AppBar
          // (kToolbarHeight + status bar). Las partes sin nada son transparentes
          // y dejan ver el calendario por detrás.
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
              child: TableCalendar(
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
                eventLoader: (day) => _controller.eventosDelDia(day, misReservas, misSolicitudes, actividades),
                locale: Localizations.localeOf(context).toString(),
                startingDayOfWeek: StartingDayOfWeek.monday,

                // Estilo del header (mes y flechas)
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  titleTextStyle: AppTextStyles.titleMedium.copyWith(color: cs.onSurface),
                  leftChevronIcon: Icon(Icons.chevron_left, color: cs.onSurfaceVariant),
                  rightChevronIcon: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ),

                // Estilo de la fila de días de la semana 
                daysOfWeekHeight: 36,
                daysOfWeekStyle: DaysOfWeekStyle(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  weekdayStyle: AppTextStyles.labelMedium.copyWith(color: cs.onSurfaceVariant),
                  weekendStyle: AppTextStyles.labelMedium.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.55)),
                ),
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    final days = [s.monShort, s.tueShort, s.wedShort, s.thuShort, s.friShort, s.satShort, s.sunShort];
                    final label = days[day.weekday - 1];
                    final isWeekend = day.weekday == 6 || day.weekday == 7;
                    return Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isWeekend ? cs.onSurfaceVariant.withValues(alpha: 0.55) : cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  },

                  // Celda seleccionada: fondo blanco + círculo azul
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
                          style: AppTextStyles.bodySmall.copyWith(color: cs.onPrimary),
                        ),
                      ),
                    );
                  },

                  // Marcadores de eventos debajo del número del día
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox.shrink();
                    final reservas = events.whereType<Booking>().length;
                    final solicitudes = events.whereType<Request>().length;
                    return Positioned(
                      bottom: 2,
                      left: 2,
                      right: 2,
                      child: Wrap(
                        // Wrap para permitir el salto de línea 
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 3, 
                        runSpacing: 2, 
                        children: [
                          if (reservas > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: colorReserva,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.reservationsBadge(reservas),
                                style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
                              ),
                            ),
                          if (solicitudes > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: colorSolicitud,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s.requestsBadge(solicitudes),
                                style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                // Altura de las filas (días)
                rowHeight: 55,

                // Estilo de las celdas
                calendarStyle: CalendarStyle(
                  
                  cellMargin: EdgeInsets.zero,
                  
                  // Día de hoy (sin seleccionar)
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: cs.onTertiary, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onTertiary),

                  // Días fuera del mes actual
                  outsideTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onSurface.withValues(alpha: 0.28)),
                  outsideDaysVisible: true,

                  // Días normales del mes
                  defaultTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onSurface),
                  weekendTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onSurface),

                  // Fondo de celdas 
                  defaultDecoration: BoxDecoration(color: cs.surface),
                  weekendDecoration: BoxDecoration(color: cs.surface),
                  outsideDecoration: BoxDecoration(color: cs.surface),
                ),
              ),
            ),
          ), // ColoredBox

          Divider(height: 1, color: cs.onSurfaceVariant.withValues(alpha: 0.12)),

          // Lista de eventos del día seleccionado o Mensaje central
          Expanded(
            child: eventosSeleccionados.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: eventosSeleccionados.length,
                    itemBuilder: (context, index) {
                      final evento = eventosSeleccionados[index];
                      if (evento is Booking) {
                        return EventoTile(
                          titulo: s.reservationEvent,
                          subtitulo: evento.status.localizedLabel(s),
                          color: colorReserva,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ReservationDetailPage(reserva: evento),
                          )),
                        );
                      } else if (evento is Request) {
                        return EventoTile(
                          titulo: s.requestEvent,
                          subtitulo: evento.status.localizedLabel(s),
                          color: colorSolicitud,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RequestDetailPage(solicitud: evento),
                          )),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  )
                : Center(
                  // TODO: HARDCODEADO
                  child: Text(
                    _selectedDay != null ? s.noEventsToday : "Selecciona un día para ver las reservas y solicitudes" ,
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