import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/reservations_page_controller.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_dialogs.dart';

class ReservationsPage extends ConsumerStatefulWidget {
  final bool puedeGestionar;
  final bool puedeCrear;

  const ReservationsPage({
    super.key,
    this.puedeGestionar = true,
    this.puedeCrear = true,
  });

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage> {
  final SearchFieldController _search = SearchFieldController();
  final ReservationsPageController _controller = ReservationsPageController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;
    final usuarioActual = ref.watch(currentUserProvider);
    final ReservationsNotifier notifier = ref.read(reservationsProvider.notifier);
    final AsyncValue<List<Booking>> filtradas = ref.watch(filteredReservationsProvider((
      query: _search.query,
      idUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
      estado: _controller.estadoFiltro,
      fechaDesde: _controller.fechaDesde,
      fechaHasta: _controller.fechaHasta,
    )));

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.puedeGestionar ? s.reservationManagement : s.reservationsTitle,
        actions: [
          Badge(
            isLabelVisible: _controller.hayFiltros,
            alignment: const AlignmentDirectional(0.5, -0.5),
            smallSize: 7,
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: s.filtersTitle,
              padding: EdgeInsets.zero,
              onPressed: () => _controller.mostrarFiltros(context, setState),
            ),
          ),
        ],
      ),
      // Solo muestra el FAB de añadir si el usuario tiene permiso para crear reservas (puedeCrear = true).
      floatingActionButton: widget.puedeCrear
          ? AddFab(
              onPressed: () async {
                // Navega a la página de formulario de reserva. 
                final Booking? nueva = await Navigator.of(context)
                    .push<Booking>(
                      MaterialPageRoute(
                      // En modo cliente, se pasa el ID del usuario actual para que el formulario lo tenga preseleccionado y no pueda elegir otro usuario. En modo gestión, se deja null para que pueda elegir cualquier usuario.
                        builder: (_) => ReservationFormPage(
                        initialIdUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
                      ),
                      ),
                    );

                // Si el resultado es null, el usuario canceló la creación y no se hace nada.
                if (nueva == null) {
                  return;
                }
                // Agrega la nueva reserva al estado global mediante el notifier.
                notifier.agregar(nueva);

                if (!context.mounted) {
                  return;
                }

                // Muestra un snackbar de éxito.
                showSuccessSnackBar(context, s.reservationCreated);
              },
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: s.searchByUserOrActividad,
              prefixIcon: Icons.search,
              suffixIcon: _search.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(_search.clear),
                    )
                  : null,
              onChanged: (String v) => setState(() => _search.query = v),
            ),
          ),

          // Lista de reservas filtradas
          Expanded(
            child: filtradas.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(s.error(error.toString()))),
              data: (List<Booking> lista) => lista.isEmpty
                // Si no hay reservas que mostrar, se muestra un mensaje.
                ? Center(child: Text(s.noReservations, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))
                // Si hay reservas, se muestra la lista de tarjetas de reserva.
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, int i) {
                      final Booking res = lista[i];

                      // Para cada reserva, se construye una ReservationCard.
                      return ReservationCard(
                        reserva: res,
                        // Para mostrar el nombre e imagen de cada material en la reserva, 
                        // se mapean las líneas de reserva a una lista de objetos que contienen el nombre, imagen y cantidad de cada material.
                        lineas: res.lines.map((BookingLine linea) => (
                          nombre: ref.watch(equipmentNameProvider(linea.equipmentId)),
                          imagen: ref.watch(equipmentImageProvider(linea.equipmentId)),
                          cantidad: linea.quantity,
                        )).toList(),

                        nombreUsuario: ref.watch(userNameProvider(res.userId)),
                        nombreActividad: ref.watch(activityNameProvider(res.activityId)),
                        activityStartDate: res.activityId != null ? ref.watch(activityByIdProvider(res.activityId!))?.initDate : null,
                        activityEndDate: res.activityId != null ? ref.watch(activityByIdProvider(res.activityId!))?.endDate : null,

                        // Si el usuario no puede gestionar reservas y la reserva no está pendiente, no se permite editar.
                        onEditar: (!widget.puedeGestionar && res.status != BookingStatus.pendiente)
                            ? null
                            : () async {
                          // Navega a la página de formulario de reserva para editar la reserva.
                          final Booking? resultado = await Navigator.of(context).push<Booking>(
                            MaterialPageRoute(
                              builder: (BuildContext _) => ReservationFormPage(
                                reserva: res,
                                initialActivity: res.activityId != null ? ref.read(activityByIdProvider(res.activityId!)) : null,
                                initialIdUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
                              ),
                            ),
                          );

                          if (resultado == null) {
                            return;
                          }

                          // Actualiza la reserva en el estado global mediante el notifier.
                          notifier.actualizar(res, resultado);

                          if (!context.mounted) {
                            return;
                          }

                          showSuccessSnackBar(context, s.reservationUpdated);
                        },

                        // Si es gestor y la reserva está pendiente - puede aprobarla.
                        onAprobar: widget.puedeGestionar && res.status == BookingStatus.pendiente
                            ? () => mostrarDialogoAprobacion(context, res, () => notifier.aprobar(res))
                            : null,
                        // Si es gestor y la reserva está pendiente - puede rechazarla.
                        onRechazar: widget.puedeGestionar && res.status == BookingStatus.pendiente
                            ? () => mostrarDialogoRechazo(context, res, () => notifier.rechazar(res))
                            : null,
                        // Si es gestor y la reserva está en curso . puede registrar la devolución.
                        onRegistrarDevolucion: widget.puedeGestionar && res.status == BookingStatus.enCurso
                            ? () => mostrarDialogoDevolucion(context, res, () => notifier.registrarDevolucion(res))
                            : null,
                        // Si es gestor y la reserva está confirmada - puede cancelarla.
                        // Si es cliente y la reserva está pendiente o confirmada - puede cancelarla.
                        onCancelar: (widget.puedeGestionar && res.status == BookingStatus.confirmada) ||
                                    (!widget.puedeGestionar && (res.status == BookingStatus.pendiente || res.status == BookingStatus.confirmada))
                            ? () => mostrarDialogoCancelacion(context, res, () => notifier.cancelar(res))
                            : null,
                        onVerDetalle: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReservationDetailPage(reserva: res),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
