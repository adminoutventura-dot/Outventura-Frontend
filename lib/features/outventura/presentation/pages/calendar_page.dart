import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/pages/request_detail_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/app/theme/app_text_styles.dart';

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

  // Devuelve todos los eventos (reservas y solicitudes) que ocurren en el día.
  List<Object> _eventosDelDia(
    DateTime day,
    List<Reservation> misReservas,
    List<Request> misSolicitudes,
    List<Activity> actividades,
  ) {
    final normalized = DateTime(day.year, day.month, day.day);
    final List<Object> result = [];

    for (final r in misReservas) {
      final start = DateTime(r.startDate.year, r.startDate.month, r.startDate.day);
      final end = DateTime(r.endDate.year, r.endDate.month, r.endDate.day);
      if (!normalized.isBefore(start) && !normalized.isAfter(end)) {
        result.add(r);
      }
    }

    for (final s in misSolicitudes) {
      final act = actividades.where((e) => e.id == s.activityId).firstOrNull;
      if (act != null) {
        final start = DateTime(act.initDate.year, act.initDate.month, act.initDate.day);
        final end = DateTime(act.endDate.year, act.endDate.month, act.endDate.day);
        if (!normalized.isBefore(start) && !normalized.isAfter(end)) {
          result.add(s);
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    final List<Reservation> reservas = ref.watch(reservationsProvider).value ?? [];
    final List<Request> solicitudes = ref.watch(requestsProvider).value ?? [];
    final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];

    final misReservas = (widget.esAdmin
            ? reservas
            : reservas.where((r) => r.userId == widget.usuario.id))
        .where((r) => r.status == ReservationStatus.confirmada || r.status == ReservationStatus.enCurso)
        .toList();

    final misSolicitudes = (widget.esAdmin
            ? solicitudes
            : solicitudes.where((s) => s.userId == widget.usuario.id))
        .where((s) => s.status == RequestStatus.confirmada || s.status == RequestStatus.enCurso)
        .toList();

    final eventosSeleccionados = _selectedDay != null
        ? _eventosDelDia(_selectedDay!, misReservas, misSolicitudes, actividades)
        : <Object>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.calendarTitle),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.surfaceContainer, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          ColoredBox(
            color: Color.alphaBlend(cs.surface.withValues(alpha: 0.8), cs.onTertiary),
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
            eventLoader: (day) => _eventosDelDia(day, misReservas, misSolicitudes, actividades),
            locale: Localizations.localeOf(context).toString(),
            startingDayOfWeek: StartingDayOfWeek.monday,

            // Estilo del header (mes y flechas)
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              decoration: BoxDecoration(color: cs.tertiary),
              titleTextStyle: AppTextStyles.titleMedium.copyWith(color: cs.surface),
              leftChevronIcon: Icon(Icons.chevron_left, color: cs.surface),
              rightChevronIcon: Icon(Icons.chevron_right, color: cs.surface),
            ),

            // Estilo de la fila de días de la semana 
            daysOfWeekHeight: 36,
            daysOfWeekStyle: DaysOfWeekStyle(
              decoration: BoxDecoration(color: cs.tertiary),
              weekdayStyle: AppTextStyles.labelMedium.copyWith(color: cs.surface),
              weekendStyle: AppTextStyles.labelMedium.copyWith(color: cs.surface.withValues(alpha: 0.7)),
            ),
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final days = [s.monShort, s.tueShort, s.wedShort, s.thuShort, s.friShort, s.satShort, s.sunShort];
                final label = days[day.weekday - 1];
                final isWeekend = day.weekday == 6 || day.weekday == 7;
                return Container(
                  color: cs.tertiary,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isWeekend ? cs.surface.withValues(alpha: 0.7) : cs.surface,
                    ),
                  ),
                );
              },

              // Celda seleccionada: fondo blanco + círculo azul
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  color: cs.surface,
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
                      style: AppTextStyles.bodySmall.copyWith(color: cs.tertiary),
                    ),
                  ),
                );
              },

              // Marcadores de eventos debajo del número del día
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                final reservas = events.whereType<Reservation>().length;
                final solicitudes = events.whereType<Request>().length;
                return Positioned(
                  bottom: 4,
                  left: 2,
                  right: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (reservas > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: cs.tertiary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s.reservationsBadge(reservas),
                            style: AppTextStyles.titleSmall.copyWith(color: cs.onPrimary),
                          ),
                        ),
                      if (solicitudes > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s.requestsBadge(solicitudes),
                            style: AppTextStyles.titleSmall.copyWith(color: cs.onPrimary),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Altura de las filas (días)
            rowHeight: 64,

            // Estilo de las celdas
            calendarStyle: CalendarStyle(
              // Día de hoy (sin seleccionar)
              todayDecoration: BoxDecoration(
                color: cs.onTertiary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.tertiary),

              // Días fuera del mes actual
              outsideTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onSurface.withValues(alpha: 0.35)),
              outsideDaysVisible: true,

              // Días normales del mes
              defaultTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onSurface),
              weekendTextStyle: AppTextStyles.bodySmall.copyWith(color: cs.onSurface),

              // Fondo de celdas 
              defaultDecoration: BoxDecoration(color: cs.surface),
              weekendDecoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.5)),
              outsideDecoration: BoxDecoration(color: cs.surface.withValues(alpha: 0.5)),
            ),
          ),
          ), // ColoredBox

          Divider(height: 1, color: cs.onTertiary),

          // Lista de eventos del día seleccionado
          if (eventosSeleccionados.isNotEmpty) ...[
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: eventosSeleccionados.length,
                itemBuilder: (context, index) {
                  final evento = eventosSeleccionados[index];
                  if (evento is Reservation) {
                    return _EventoTile(
                      titulo: s.reservationEvent(evento.id),
                      subtitulo: evento.status.localizedLabel(s),
                      color: cs.tertiary,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ReservationDetailPage(reserva: evento),
                      )),
                    );
                  } else if (evento is Request) {
                    return _EventoTile(
                      titulo: s.requestEvent(evento.id),
                      subtitulo: evento.status.localizedLabel(s),
                      color: cs.primary,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RequestDetailPage(solicitud: evento),
                      )),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ] else if (_selectedDay != null) ...[
            Expanded(
              child: Center(
                child: Text(
                  s.noEventsToday,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EventoTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _EventoTile({
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 6),
        title: Text(
          titulo,
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
