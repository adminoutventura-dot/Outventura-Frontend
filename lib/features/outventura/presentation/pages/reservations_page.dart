import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/reservations_page_controller.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/solicitud_form_page.dart'; // Asegura esta importación
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/widgets/material_reservation_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/activity_reservation_card.dart';
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
    final ReservationsNotifier notifier = ref.read(
      reservationsProvider.notifier,
    );

    final AsyncValue<List<Booking>> filtradas = ref.watch(
      filteredReservationsProvider((
        query: _search.query,
        idUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
        estado: _controller.estadoFiltro,
        fechaDesde: _controller.fechaDesde,
        fechaHasta: _controller.fechaHasta,
        tipo: _controller.tipoFiltro,
      )),
    );

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CustomAppBar(
        title: widget.puedeGestionar
            ? s.reservationManagement
            : s.reservationsTitle,
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
      floatingActionButton: widget.puedeCrear
          ? AddFab(
              onPressed: () async {
                // Al crear desde el FAB general de reservas, asumimos flujo de materiales puros
                final Booking? nueva = await Navigator.of(context)
                    .push<Booking>(
                      MaterialPageRoute(
                        builder: (_) => ReservationFormPage(
                          initialIdUsuario: widget.puedeGestionar
                              ? null
                              : usuarioActual?.id,
                        ),
                      ),
                    );

                if (nueva == null) return;
                await notifier.agregar(nueva);
                ref.invalidate(equipmentProvider);

                if (!context.mounted) return;
                showSuccessSnackBar(context, s.reservationCreated);
              },
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: SegmentedButton<TipoReserva>(
              segments: const [
                ButtonSegment(value: TipoReserva.todas, label: Text('Totes')),
                ButtonSegment(
                  value: TipoReserva.materiales,
                  label: Text('Materials'),
                ),
                ButtonSegment(
                  value: TipoReserva.actividades,
                  label: Text('Excursions'),
                ),
              ],
              selected: {_controller.tipoFiltro},
              onSelectionChanged: (Set<TipoReserva> nuevaSeleccion) {
                setState(() {
                  _controller.tipoFiltro = nuevaSeleccion.first;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
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

          Expanded(
            child: filtradas.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text(s.error(error.toString()))),
              data: (List<Booking> lista) => lista.isEmpty
                  ? Center(
                      child: Text(
                        s.noReservations,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        12,
                        12,
                        12,
                        MediaQuery.of(context).padding.bottom + 80,
                      ),
                      itemCount: lista.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int i) {
                        final Booking res = lista[i];

                        final bool tieneActividad = res.lines.any(
                          (l) => l.activityId != null,
                        );

                        final lineasMapeadas = res.lines
                            .where((l) => l.equipmentId != null)
                            .map(
                              (BookingLine linea) => (
                                nombre: ref.watch(
                                  equipmentNameProvider(linea.equipmentId!),
                                ),
                                imagen: ref.watch(
                                  equipmentImageProvider(linea.equipmentId!),
                                ),
                                cantidad: linea.quantity,
                              ),
                            )
                            .toList();

                        final String nombreUsuario = ref.watch(
                          userNameProvider(res.userId),
                        );

                        void onVerDetalleCall() {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReservationDetailPage(reserva: res),
                            ),
                          );
                        }

                        final int? activityIdFromLine = res.lines
                            .where((l) => l.activityId != null)
                            .map((l) => l.activityId)
                            .firstOrNull;

                        // Enrutador dinámico de edición de formularios
                        final onEditarCall =
                            (!widget.puedeGestionar &&
                                res.status != WorkflowStatus.pendiente)
                            ? null
                            : () async {
                                final Booking?
                                resultado = await Navigator.of(context).push<Booking>(
                                  MaterialPageRoute(
                                    builder: (BuildContext _) {
                                      if (tieneActividad) {
                                        // Si tiene excursión vinculada, abre SolicitudFormPage
                                        return SolicitudFormPage(
                                          reserva: res,
                                          initialIdUsuario:
                                              widget.puedeGestionar
                                              ? null
                                              : usuarioActual?.id,
                                        );
                                      } else {
                                        // Si es sólo materiales, abre ReservationFormPage
                                        return ReservationFormPage(
                                          reserva: res,
                                          initialIdUsuario:
                                              widget.puedeGestionar
                                              ? null
                                              : usuarioActual?.id,
                                        );
                                      }
                                    },
                                  ),
                                );

                                if (resultado == null) return;
                                try {
                                  await notifier.actualizar(res, resultado);
                                  ref.invalidate(equipmentProvider);

                                  if (!context.mounted) return;
                                  showSuccessSnackBar(
                                    context,
                                    s.reservationUpdated,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error del servidor: $e'),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  );
                                }
                              };

                        // Divide el árbol de renderizado según los archivos separados
                        if (tieneActividad) {
                          return ActivityReservationCard(
                            reserva: res,
                            lineas: lineasMapeadas,
                            nombreUsuario: nombreUsuario,
                            nombreActividad: ref.watch(
                              activityNameProvider(activityIdFromLine),
                            ),
                            onEditar: onEditarCall,
                            onVerDetalle: onVerDetalleCall,
                          );
                        } else {
                          return MaterialReservationCard(
                            reserva: res,
                            lineas: lineasMapeadas,
                            nombreUsuario: nombreUsuario,
                            onEditar: onEditarCall,
                            onVerDetalle: onVerDetalleCall,
                            onAprobar:
                                widget.puedeGestionar &&
                                    res.status == WorkflowStatus.pendiente
                                ? () => mostrarDialogoAprobacion(
                                    context,
                                    res,
                                    () async {
                                      await notifier.aprobar(res);
                                      ref.invalidate(equipmentProvider);
                                    },
                                  )
                                : null,
                            onRechazar:
                                widget.puedeGestionar &&
                                    res.status == WorkflowStatus.pendiente
                                ? () => mostrarDialogoRechazo(
                                    context,
                                    res,
                                    () async {
                                      await notifier.rechazar(res);
                                      ref.invalidate(equipmentProvider);
                                    },
                                  )
                                : null,
                            onRegistrarDevolucion:
                                widget.puedeGestionar &&
                                    res.status == WorkflowStatus.enCurso
                                ? () => mostrarDialogoDevolucion(
                                    context,
                                    res,
                                    () async {
                                      await notifier.registrarDevolucion(res);
                                      ref.invalidate(equipmentProvider);
                                    },
                                  )
                                : null,
                            onCancelar:
                                (widget.puedeGestionar &&
                                        res.status ==
                                            WorkflowStatus.confirmada) ||
                                    (!widget.puedeGestionar &&
                                        (res.status ==
                                                WorkflowStatus.pendiente ||
                                            res.status ==
                                                WorkflowStatus.confirmada))
                                ? () => mostrarDialogoCancelacion(
                                    context,
                                    res,
                                    () async {
                                      await notifier.cancelar(res);
                                      ref.invalidate(equipmentProvider);
                                    },
                                  )
                                : null,
                          );
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
