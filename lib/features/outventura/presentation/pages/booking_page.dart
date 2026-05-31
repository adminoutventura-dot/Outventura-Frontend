import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/auth/presentation/providers/guides_provider.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/booking_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/outventura/presentation/widgets/booking_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/booking_dialogs.dart';
import 'package:outventura/features/outventura/presentation/pages/booking_detail_page.dart';
import 'package:outventura/features/outventura/presentation/controllers/booking_page_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';

class ReservationsPage extends ConsumerStatefulWidget {
  final bool puedeGestionar;
  final bool puedeCrear;
  final bool showGuideReservations;

  const ReservationsPage({
    super.key,
    this.puedeGestionar = true,
    this.puedeCrear = true,
    this.showGuideReservations = false,
  });

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage> {
  final SearchFieldController _search = SearchFieldController();
  final ReservationsPageController _controller = ReservationsPageController();

  @override
  void initState() {
    super.initState();
    // Aplicar filtro por guía si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usuarioActual = ref.read(currentUserProvider);
      final bool isGuide = usuarioActual?.role.code == 'GUIDE';
      final bool isAdminOSuper = usuarioActual?.role.code == 'ADMIN' || usuarioActual?.role.code == 'SUPER';

      if (isAdminOSuper && widget.puedeGestionar && !widget.showGuideReservations) {
        // ADMIN/SUPER en gestión: ven todas las reservas, sin filtro de propietario.
        ref.read(reservationsProvider.notifier).inicializarVista();
      } else if (widget.showGuideReservations && isGuide) {
        // Vista de reservas como guía (actividades asignadas al guía).
        // Esperamos a que el listado de guías cargue para poder resolver
        // el guideId del usuario actual.
        try {
          final guides = await ref.read(guidesProvider.future);
          final guide = guides.where((g) => g.userId == usuarioActual!.id).firstOrNull;
          if (guide != null) {
            ref.read(reservationsProvider.notifier).inicializarVista(guideId: guide.id);
          }
        } catch (_) {
          // Si falla la carga de guías, deja el filtro sin aplicar.
        }
      } else if (!widget.puedeGestionar && usuarioActual != null) {
        // Usuarios normales (y guías en su vista de solicitante) ven solo sus propias reservas.
        ref.read(reservationsProvider.notifier).inicializarVista(userId: usuarioActual.id);
      } else if (isGuide && widget.puedeGestionar && !widget.showGuideReservations && usuarioActual != null) {
        // Guía en modo gestión pero sin showGuideReservations -> ver sus propias reservas como solicitante
        ref.read(reservationsProvider.notifier).inicializarVista(userId: usuarioActual.id);
      }
    });
  }

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
    final String? userRole = usuarioActual?.role.code;
    final ReservationsNotifier notifier = ref.read(
      reservationsProvider.notifier,
    );
    final int currentPage = notifier.currentPage;
    final int totalPages = notifier.totalPages;

    final AsyncValue<List<Booking>> reservacionesAsync = ref.watch(reservationsProvider);

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
              onPressed: () => _controller.mostrarFiltros(context, setState, onApply: () {
                notifier.aplicarFiltrosAvanzados(
                  estado: _controller.estadoFiltro,
                  fechaDesde: _controller.fechaDesde,
                  fechaHasta: _controller.fechaHasta,
                  tipo: _controller.tipoFiltro,
                );
              }),
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
                        builder: (_) => BookingFormPage(
                          initialIdUsuario: widget.puedeGestionar
                              ? null
                              : usuarioActual?.id,
                        ),
                      ),
                    );

                if (nueva == null) return;
                
                // PROTECCIÓN EN LA CREACIÓN DE RESERVAS (FAB)
                try {
                  await notifier.agregar(nueva);
                  ref.invalidate(equipmentProvider);
                  if (!context.mounted) return;
                  showSuccessSnackBar(context, s.reservationCreated);
                } catch (e) {
                  if (!context.mounted) return;
                  final String mensajeLimpio = e.toString()
                      .replaceAll('Exception: ', '')
                      .replaceAll('Exception', '');
                  showErrorSnackBar(context, mensajeLimpio);
                }
              },
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: s.searchByUserOrActividad,
              prefixIcon: Icons.search,
              suffixIcon: _search.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _search.clear();
                        notifier.aplicarFiltroTexto('');
                      }),
                    )
                  : null,
              onChanged: (String v) => setState(() {
                _search.query = v;
                notifier.aplicarFiltroTexto(v);
              }),
            ),
          ),

          // PAGINACIÓN COMPACTA < 1 / X >
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    color: currentPage > 1
                        ? cs.primary
                        : cs.onSurfaceVariant.withValues(alpha: 0.3),
                    onPressed: currentPage > 1
                        ? () => notifier.cambiarPagina(currentPage - 1)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '$currentPage / $totalPages',
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 28),
                    color: currentPage < totalPages
                        ? cs.primary
                        : cs.onSurfaceVariant.withValues(alpha: 0.3),
                    onPressed: currentPage < totalPages
                        ? () => notifier.cambiarPagina(currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),

          Expanded(
            child: reservacionesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text(s.error(error.toString()))),
              data: (List<Booking> listaOriginal) {
                return listaOriginal.isEmpty
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
                      itemCount: listaOriginal.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int i) {
                        final Booking res = listaOriginal[i];

                        final Booking reservaActual =
                            ref.watch(reservationsProvider).value
                                ?.where((b) => b.id == res.id)
                                .firstOrNull ??
                            res;

                        final bool tieneActividad = reservaActual.lines.any(
                          (l) => l.activityId != null,
                        );

                        // Prioriza el nombre embebido en la reserva (lo incluye
                        // el backend), y solo recurre al listado /user (restringido
                        // a ADMIN/SUPER) como respaldo.
                        final String nombreUsuario = reservaActual.userName ??
                            ref.watch(userNameProvider(res.userId));

                        void onVerDetalleCall() {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReservationDetailPage(reserva: reservaActual),
                            ),
                          );
                        }

                        // Según el backend, el método update solo cambia estado, no edita fechas/líneas
                        // USER: pueden editar sus reservas pendientes (solo líneas)
                        // GUIDE: puede editar reservas con actividad asignada
                        // ADMIN/SUPER: pueden cambiar estado de reservas
                        final bool esAdminOSuper = userRole == 'ADMIN' || userRole == 'SUPER';
                        final bool esUser = userRole == 'USER';
                        final bool esPropiaReserva = res.userId == usuarioActual?.id;
                        final bool puedeEditarReserva = esAdminOSuper ||
                            (userRole == 'GUIDE' && tieneActividad) ||
                            (esUser && esPropiaReserva);

                        // ADMIN/SUPER y USER propietario solo en PENDING.
                        // GUIDE con actividad asignada puede editar siempre.
                        final onEditarCall = ((puedeEditarReserva &&
                                res.status == WorkflowStatus.pendiente) ||
                            (userRole == 'GUIDE' && tieneActividad))
                            ? () async {
                                final Booking? resultado =
                                    await Navigator.of(context).push<Booking>(
                                      MaterialPageRoute(
                                        builder: (BuildContext _) {
                                          return BookingFormPage(
                                            booking: reservaActual,
                                            initialIdUsuario:
                                                widget.puedeGestionar
                                                    ? null
                                                    : usuarioActual?.id,
                                          );
                                        },
                                      ),
                                    );

                                if (resultado == null) return;

                                // TRADUCCIÓN Y ALERTA CORRECTA EN LA EDICIÓN DE RESERVAS
                                try {
                                  if (esUser && esPropiaReserva) {
                                    // USER solo puede editar líneas
                                    await notifier.actualizarLineas(
                                      reservaActual,
                                      resultado.lines,
                                    );
                                  } else {
                                    // ADMIN/SUPER/GUIDE pueden editar todo
                                    await notifier.actualizar(
                                      reservaActual,
                                      resultado,
                                    );
                                  }
                                  ref.invalidate(equipmentProvider);

                                  if (!context.mounted) return;
                                  showSuccessSnackBar(
                                    context,
                                    s.reservationUpdated,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  final String mensajeLimpio = e.toString()
                                      .replaceAll('Exception: ', '')
                                      .replaceAll('Exception', '');
                                  showErrorSnackBar(context, mensajeLimpio);
                                }
                              }
                            : null;

                        return BookingCard(
                          reserva: reservaActual,
                          nombreUsuario: nombreUsuario,
                          esActividad: tieneActividad,
                          onVerDetalle: onVerDetalleCall,
                          onEditar: onEditarCall,
                          // Según el backend, cancelar es una edición del estado
                          // USER/GUIDE: no pueden cancelar (no pueden editar)
                          // ADMIN: puede cancelar PENDING y ACCEPTED con restricciones de tiempo
                          // SUPER: puede cancelar cualquier estado
                          onCancelar:
                              ((res.status == WorkflowStatus.pendiente && esAdminOSuper) ||
                               (res.status == WorkflowStatus.confirmada && esAdminOSuper) ||
                               (res.status == WorkflowStatus.finalizada && userRole == 'SUPER'))
                              ? () => mostrarDialogoCancelacion(
                                  context,
                                  res,
                                  () async {
                                    await notifier.cancelar(res);
                                    ref.invalidate(equipmentProvider);
                                  },
                                )
                              : null,
                          // // Solo ADMIN/SUPER puede rechazar PENDING
                          // onRechazar:
                          //     widget.puedeGestionar &&
                          //             res.status == WorkflowStatus.pendiente
                          //     ? () => mostrarDialogoRechazo(
                          //         context,
                          //         res,
                          //         () async {
                          //           await notifier.rechazar(res);
                          //           ref.invalidate(equipmentProvider);
                          //         },
                          //       )
                          //     : null,
                          // Solo ADMIN/SUPER puede aprobar PENDING
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
                          // IN_PROGRESS -> puede registrar devolución (ADMIN, SUPER, GUIDE si tiene actividad asignada)
                          onRegistrarDevolucion:
                              res.status == WorkflowStatus.enCurso &&
                              (widget.puedeGestionar || (userRole == 'GUIDE' && tieneActividad))
                              ? () => mostrarDialogoDevolucion(
                                  context,
                                  res,
                                  () async {
                                    await notifier.registrarDevolucion(res);
                                    ref.invalidate(equipmentProvider);
                                  },
                                )
                              : null,
                        );
                      },
                    );
              },
            ),
          ),
        ],    
      )
    );        
  }
}