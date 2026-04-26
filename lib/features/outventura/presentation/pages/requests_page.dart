import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/controllers/requests_page_controller.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_tab.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

class RequestsPage extends ConsumerStatefulWidget {
  final bool puedeGestionar;
  final bool puedeCrear;

  const RequestsPage({
    super.key,
    this.puedeGestionar = true,
    this.puedeCrear = true,
  });

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  EstadoSolicitud? _estadoSeleccionado;
  final RequestsPageController _controller = RequestsPageController();

  // TODO: En equipamiento las acciones estaban en ek mismo  onEditar, onEliminar...
  void _aceptar(Solicitud soli) => _controller.aceptar(
    solicitud: soli,
    context: context,
    ref: ref,
    isMounted: () => mounted,
  );

  void _editar(Solicitud soli) => _controller.editar(
    solicitud: soli,
    context: context,
    ref: ref,
    fixedIdUsuario: widget.puedeGestionar ? null : ref.read(currentUserProvider)?.id,
  );

  void _rechazar(Solicitud soli) => _controller.rechazar(
    solicitud: soli,
    context: context,
    ref: ref,
    isMounted: () => mounted,
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final usuarioActual = ref.watch(currentUserProvider);
    final List<Solicitud> solicitudes = ref.watch(solicitudesProvider);
    final List<Excursion> excursiones = ref.watch(excursionesProvider);
    final List<Reserva> reservas = ref.watch(reservasProvider);

    List<Solicitud> base = solicitudes;
    if (!widget.puedeGestionar && usuarioActual != null) {
      base = solicitudes
          .where((Solicitud s) => s.idUsuario == usuarioActual.id)
          .toList();
    }

    List<Solicitud> filtradas;
    if (_estadoSeleccionado == null) {
      filtradas = base;
    } else {
      filtradas = base
          .where((Solicitud soli) => soli.estado == _estadoSeleccionado)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.puedeGestionar ? 'Gestión de solicitudes' : 'Solicitudes',
        ),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.inverseSurface, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: widget.puedeCrear
          ? AddFab(
              onPressed: () async {
                final Solicitud? nueva = await Navigator.of(context)
                    .push<Solicitud>(
                      MaterialPageRoute(
                        builder: (_) => const SolicitudFormPage(),
                      ),
                    );
                if (nueva != null) {
                  ref.read(solicitudesProvider.notifier).agregar(nueva);
                }
              },
            )
          : null,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filtros
          Row(
            children: [
              Expanded(
                child: AppTab(
                  label: 'Todas',
                  seleccionado: _estadoSeleccionado == null,
                  onTap: () => setState(() => _estadoSeleccionado = null),
                ),
              ),
              for (final EstadoSolicitud e in EstadoSolicitud.values)
                Expanded(
                  child: AppTab(
                    label: e.label,
                    seleccionado: _estadoSeleccionado == e,
                    onTap: () => setState(() => _estadoSeleccionado = e),
                  ),
                ),
            ],
          ),

          // Lista
          Expanded(
            child: filtradas.isEmpty
                ? Center(
                    child: Text(
                      'No hay solicitudes',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                    itemCount: filtradas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final Solicitud soli = filtradas[index];
                      Excursion excursion = excursiones.first;
                      for (final Excursion e in excursiones) {
                        if (e.id == soli.idExcursion) {
                          excursion = e;
                          break;
                        }
                      }

                      final usuarios = ref.read(usuariosProvider);
                      final usuario = soli.idUsuario != null
                          ? usuarios.firstWhere((u) => u.id == soli.idUsuario, orElse: () => usuarios.first)
                          : null;

                      Reserva? reservaAsociada;
                      if (soli.idReserva != null) {
                        for (final Reserva r in reservas) {
                          if (r.id == soli.idReserva) {
                            reservaAsociada = r;
                            break;
                          }
                        }
                      }

                      return SolicitudCard(
                        solicitud: soli,
                        excursion: excursion,
                        nombreUsuario: (!widget.puedeGestionar)
                            ? null
                            : usuario != null
                            ? '${usuario.nombre} ${usuario.apellidos}'
                            : null,
                        onGestionar:
                            widget.puedeGestionar &&
                                soli.estado == EstadoSolicitud.pendiente
                            ? () => _aceptar(soli)
                            : null,
                        onCancelar: soli.estado == EstadoSolicitud.pendiente
                            ? () => _rechazar(soli)
                            : null,
                        onEditar: () => _editar(soli),
                        onEditarReserva: reservaAsociada == null
                            ? null
                            : () async {
                                final Reserva? actualizada =
                                    await Navigator.of(context).push<Reserva>(
                                      MaterialPageRoute(
                                        builder: (_) => ReservationFormPage(
                                          reserva: reservaAsociada,
                                          initialIdUsuario:
                                              widget.puedeGestionar
                                              ? null
                                              : usuarioActual?.id,
                                        ),
                                      ),
                                    );

                                if (actualizada != null) {
                                  ref
                                      .read(reservasProvider.notifier)
                                      .actualizar(
                                        reservaAsociada!,
                                        actualizada,
                                      );

                                  final Map<int, int> materialesActualizados = {
                                    for (final LineaReserva linea
                                        in actualizada.lineas)
                                      linea.idEquipamiento: linea.cantidad,
                                  };

                                  ref
                                      .read(solicitudesProvider.notifier)
                                      .actualizar(
                                        soli,
                                        soli.copyWith(
                                          materialesSolicitados:
                                              materialesActualizados,
                                          idReserva: actualizada.id,
                                        ),
                                      );
                                }
                              },
                        onVerDetalle: () {},
                        // => showSolicitudDetailSheet(
                        //   context: context,
                        //   solicitud: s,
                        //   onAceptar: () => _aceptar(s),
                        //   onRechazar: () => _rechazar(s),
                        // ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
