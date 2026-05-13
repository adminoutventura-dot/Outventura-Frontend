import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/reservations_page_controller.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/search_controller.dart';
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
    final AsyncValue<List<Reservation>> filtradas = ref.watch(filteredReservationsProvider((
      query: _search.query,
      idUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
      estado: _controller.estadoFiltro,
      fechaDesde: _controller.fechaDesde,
      fechaHasta: _controller.fechaHasta,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.puedeGestionar ? s.reservationManagement : s.reservationsTitle),
        automaticallyImplyLeading: true,
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
      floatingActionButton: widget.puedeCrear
          ? AddFab(
              onPressed: () async {
                final Reservation? nueva = await Navigator.of(context)
                    .push<Reservation>(
                      MaterialPageRoute(
                        builder: (_) => const ReservationFormPage(),
                      ),
                    );
                if (nueva == null) {
                  return;
                }
                notifier.agregar(nueva);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.reservationCreated)),
                );
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
          // Lista
          Expanded(
            child: filtradas.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (List<Reservation> lista) => lista.isEmpty
                ? Center(child: Text(s.noReservations, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, int i) {
                      final Reservation res = lista[i];

                      VoidCallback? onAprobar;
                      if (widget.puedeGestionar && res.status == ReservationStatus.pendiente) {
                        onAprobar = () => mostrarDialogoAprobacion(context, res, () => notifier.aprobar(res));
                      }

                      VoidCallback? onRechazar;
                      if (widget.puedeGestionar && res.status == ReservationStatus.pendiente) {
                        onRechazar = () => mostrarDialogoRechazo(context, res, () => notifier.rechazar(res));
                      }

                      VoidCallback? onRegistrarDevolucion;
                      if (widget.puedeGestionar && res.status == ReservationStatus.enCurso) {
                        onRegistrarDevolucion = () => mostrarDialogoDevolucion(context, res, () => notifier.registrarDevolucion(res));
                      }

                      VoidCallback? onCancelar;
                      if (widget.puedeGestionar && res.status == ReservationStatus.confirmada) {
                        onCancelar = () => mostrarDialogoCancelacion( context, res, () => notifier.cancelar(res));
                      } else if (!widget.puedeGestionar && (res.status == ReservationStatus.pendiente || res.status == ReservationStatus.confirmada)) {
                        onCancelar = () => mostrarDialogoCancelacion( context, res, () => notifier.cancelar(res));
                      }

                      return ReservationCard(
                        reserva: res,
                        lineas: res.lines.map((ReservationLine linea) => (
                          nombre: ref.watch(equipmentNameProvider(linea.equipmentId)),
                          imagen: ref.watch(equipmentImageProvider(linea.equipmentId)),
                          cantidad: linea.quantity,
                        )).toList(),
                        
                        nombreUsuario: ref.watch(userNameProvider(res.userId)),
                        nombreActividad: ref.watch(activityNameProvider(res.activityId)),
                        onEditar: (!widget.puedeGestionar && res.status != ReservationStatus.pendiente)
                            ? null
                            : () async { 
                          final Reservation? resultado = await Navigator.of(context) .push<Reservation>(
                            MaterialPageRoute( 
                              builder: (BuildContext _) =>
                              ReservationFormPage( reserva: res, initialIdUsuario: widget.puedeGestionar ? null : usuarioActual?.id),
                            ),
                          );
                          if (resultado == null) {
                            return;
                          }
                          notifier.actualizar(res, resultado);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.reservationUpdated)),
                          );
                        },
                        onAprobar: onAprobar,
                        onRechazar: onRechazar,
                        onRegistrarDevolucion: onRegistrarDevolucion,
                        onCancelar: onCancelar,
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
