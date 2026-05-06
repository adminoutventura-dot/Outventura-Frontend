import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/pages/request_detail_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:calendar_view/calendar_view.dart';

class CalendarPage extends ConsumerWidget {

  // TODO: Cambiar estilo calendario
  final Usuario usuario;
  final bool esAdmin;

  const CalendarPage({super.key, required this.usuario, required this.esAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    // final TextTheme tt = Theme.of(context).textTheme;
    final List<Reserva> reservas = ref.watch(reservasProvider).value ?? [];
    final List<Solicitud> solicitudes = ref.watch(solicitudesProvider).value ?? [];
    final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];

    // Filtrar reservas y solicitudes confirmadas o en curso
    final List<Reserva> reservasFiltradas = reservas.where((r) =>
      r.estado == EstadoReserva.confirmada || r.estado == EstadoReserva.enCurso
    ).toList();
    final List<Solicitud> solicitudesFiltradas = solicitudes.where((s) =>
      s.estado == EstadoSolicitud.confirmada || s.estado == EstadoSolicitud.enCurso
    ).toList();

    // Si no es admin, filtrar solo las del usuario
    final List<Reserva> misReservas = esAdmin ? reservasFiltradas : reservasFiltradas.where((r) => r.idUsuario == usuario.id).toList();
    final List<Solicitud> misSolicitudes = esAdmin ? solicitudesFiltradas : solicitudesFiltradas.where((s) => s.idUsuario == usuario.id).toList();

    final List<CalendarEventData> eventos = [
      ...misReservas.map((r) => CalendarEventData(
            title: 'Reserva #${r.id}',
            description: 'Estado: ${r.estado.label}',
            date: r.fechaInicio,
            endDate: r.fechaFin,
            event: r,
            color: cs.tertiary,
          )),
      ...misSolicitudes.map((s) {
        final Excursion exc = excursiones.firstWhere(
          (e) => e.id == s.idExcursion
        );
        return CalendarEventData(
          title: 'Solicitud #${s.id}',
          description: 'Estado: ${s.estado.label}',
          date: exc.fechaInicio,
          endDate: exc.fechaFin,
          event: s,
          color: cs.primary,
        );
      }).whereType<CalendarEventData>(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
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
      body: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth  = constraints.maxWidth;
            final double availableHeight = constraints.maxHeight;

            // Alturas fijas del MonthView: barra de navegación + fila de días
            const double navHeaderHeight   = 55.0;
            const double weekdayRowHeight  = 41.0;
            final double cellAreaHeight = availableHeight - navHeaderHeight - weekdayRowHeight;

            // Celda: 7 columnas, máximo 6 filas por mes
            final double cellWidth  = availableWidth / 7;
            final double cellHeight = cellAreaHeight / 6;
            final double cellAspectRatio = (cellWidth / cellHeight).clamp(0.1, 10.0);

            return ClipRect(
              child: SizedBox(
                width:  availableWidth,
                height: availableHeight,
                child: CalendarControllerProvider(
                  controller: EventController(),
                  child: MonthView(
                    controller: EventController()..addAll(eventos),
                    monthViewStyle: MonthViewStyle(
                      minMonth: DateTime.now().subtract(const Duration(days: 365)),
                      maxMonth: DateTime.now().add(const Duration(days: 365)),
                      initialMonth: DateTime.now(),
                      cellAspectRatio: cellAspectRatio,
                    ),
                    monthViewBuilders: MonthViewBuilders(
                      onEventTap: (event, date) {
                        if (event.event is Reserva) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ReservationDetailPage(reserva: event.event as Reserva),
                          ));
                        } else if (event.event is Solicitud) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RequestDetailPage(solicitud: event.event as Solicitud),
                          ));
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
