import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/reservations_page_controller.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart'; // <-- IMPORTANTE
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_dialogs.dart';

import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';

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
      floatingActionButton: widget.puedeCrear
          ? AddFab(
              onPressed: () async {
                final Booking? nueva = await Navigator.of(context)
                    .push<Booking>(
                      MaterialPageRoute(
                        builder: (_) => ReservationFormPage(
                        initialIdUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
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
              error: (error, _) => Center(child: Text(s.error(error.toString()))),
              data: (List<Booking> lista) => lista.isEmpty
                ? Center(child: Text(s.noReservations, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, int i) {
                      final Booking res = lista[i];

                      return ReservationCard(
                        reserva: res,
                        lineas: res.lines.map((BookingLine linea) => (
                          nombre: ref.watch(equipmentNameProvider(linea.equipmentId)),
                          imagen: ref.watch(equipmentImageProvider(linea.equipmentId)),
                          cantidad: linea.quantity,
                        )).toList(),

                        nombreUsuario: ref.watch(userNameProvider(res.userId)),
                        nombreActividad: ref.watch(activityNameProvider(res.activityId)),

                        onEditar: (!widget.puedeGestionar && res.status != WorkflowStatus.pendiente)
                            ? null
                            : () async {
                          
                          // REDIRECCIÓN A LA SOLICITUD ORIGINAL
                          if (res.activityId != null) {
                            final solicitudes = ref.read(requestsProvider).value ?? [];
                            final solicitudAsociada = solicitudes.where((s) => s.bookingId == res.id).firstOrNull;

                            if (solicitudAsociada != null) {
                              
                              // ABRE EL FORMULARIO Y ESPERA EL OBJETO REQUEST DE VUELTA
                              final Request? resultadoSolicitud = await Navigator.of(context).push<Request>(
                                MaterialPageRoute(
                                  builder: (_) => SolicitudFormPage(
                                    solicitud: solicitudAsociada,
                                    initialIdUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
                                  ),
                                ),
                              );
                              
                              // SI EL USUARIO GUARDA, LO ENVIA AL BACKEND
                              if (resultadoSolicitud != null && context.mounted) {
                                try {
                                  await ref.read(requestsProvider.notifier).actualizar(solicitudAsociada, resultadoSolicitud);
                                  
                                  // Invalida para que todo se repinte con los nuevos valores
                                  ref.invalidate(reservationsProvider);
                                  ref.invalidate(equipmentProvider);
                                  
                                  if (context.mounted) {
                                    showSuccessSnackBar(context, "Sol·licitud actualitzada amb èxit");
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error del servidor: $e'),
                                        backgroundColor: cs.error,
                                      ),
                                    );
                                  }
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("No s'ha trobat la sol·licitud original en memòria. Actualitza la llista."),
                                  backgroundColor: cs.error,
                                ),
                              );
                            }
                            return; // Salie para no ejecutar la lógica de reserva normal
                          }


                          // FLUJO NORMAL: Si es una Reserva directa (sin actividad)

                          final Booking? resultado = await Navigator.of(context).push<Booking>(
                            MaterialPageRoute(
                              builder: (BuildContext _) => ReservationFormPage(
                                reserva: res,
                                initialActivity: res.activityId != null ? ref.read(activityByIdProvider(res.activityId!)) : null,
                                initialIdUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
                              ),
                            ),
                          );

                          if (resultado == null) return;
                          try {
                            await notifier.actualizar(res, resultado);
                            ref.invalidate(equipmentProvider);

                            if (!context.mounted) return;
                            showSuccessSnackBar(context, s.reservationUpdated);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error del servidor: $e'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },

                        onAprobar: widget.puedeGestionar && res.status == WorkflowStatus.pendiente
                            ? () => mostrarDialogoAprobacion(context, res, () async {
                                  await notifier.aprobar(res);
                                  ref.invalidate(equipmentProvider);
                                })
                            : null,
                        onRechazar: widget.puedeGestionar && res.status == WorkflowStatus.pendiente
                            ? () => mostrarDialogoRechazo(context, res, () async {
                                  await notifier.rechazar(res);
                                  ref.invalidate(equipmentProvider);
                                })
                            : null,
                        onRegistrarDevolucion: widget.puedeGestionar && res.status == WorkflowStatus.enCurso
                            ? () => mostrarDialogoDevolucion(context, res, () async {
                                  await notifier.registrarDevolucion(res);
                                  ref.invalidate(equipmentProvider);
                                })
                            : null,
                        onCancelar: (widget.puedeGestionar && res.status == WorkflowStatus.confirmada) ||
                                    (!widget.puedeGestionar && (res.status == WorkflowStatus.pendiente || res.status == WorkflowStatus.confirmada))
                            ? () => mostrarDialogoCancelacion(context, res, () async {
                                  await notifier.cancelar(res);
                                  ref.invalidate(equipmentProvider);
                                })
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