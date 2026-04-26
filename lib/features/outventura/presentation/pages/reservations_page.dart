import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/core/widgets/app_tab.dart';
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
  EstadoReserva? _filtro;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final usuarioActual = ref.watch(currentUserProvider);
    final List<Reserva> reservas = ref.watch(reservasProvider);
    final ReservasNotifier notifier = ref.read(reservasProvider.notifier);

    List<Reserva> base = reservas;
    if (!widget.puedeGestionar && usuarioActual != null) {
      base = reservas
          .where((Reserva r) => r.idUsuario == usuarioActual.id)
          .toList();
    }

    List<Reserva> filtradas;
    if (_filtro == null) {
      filtradas = base;
    } else {
      filtradas = base.where((Reserva res) => res.estado == _filtro).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.puedeGestionar ? 'Gestión de reservas' : 'Reservas'),
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
                final Reserva? nueva = await Navigator.of(context)
                    .push<Reserva>(
                      MaterialPageRoute(
                        builder: (_) => const ReservationFormPage(),
                      ),
                    );
                if (nueva != null) {
                  notifier.agregar(nueva);
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
                  seleccionado: _filtro == null,
                  onTap: () => setState(() => _filtro = null),
                ),
              ),
              for (final EstadoReserva estadoR in EstadoReserva.values)
                Expanded(
                  child: AppTab(
                    label: estadoR.label,
                    seleccionado: _filtro == estadoR,
                    onTap: () => setState(() => _filtro = estadoR),
                  ),
                ),
            ],
          ),

          // Lista
          Expanded(
            child: filtradas.isEmpty
                ? Center(child: Text('No hay reservas', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                    itemCount: filtradas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, int i) {
                      final Reserva res = filtradas[i];

                      VoidCallback? onAprobar;
                      if (widget.puedeGestionar && res.estado == EstadoReserva.pendiente) {
                        onAprobar = () => mostrarDialogoAprobacion(context, res, () => notifier.aprobar(res));
                      }

                      VoidCallback? onRechazar;
                      if (widget.puedeGestionar && res.estado == EstadoReserva.pendiente) {
                        onRechazar = () => mostrarDialogoRechazo(context, res, () => notifier.rechazar(res));
                      }

                      VoidCallback? onRegistrarDevolucion;
                      if (widget.puedeGestionar && res.estado == EstadoReserva.pendiente) {
                        onRegistrarDevolucion = () => mostrarDialogoDevolucion(context, res, () => notifier.registrarDevolucion(res));
                      }

                      VoidCallback? onCancelar;
                      if (widget.puedeGestionar && res.estado == EstadoReserva.confirmada) {
                        onCancelar = () => mostrarDialogoCancelacion( context, res, () => notifier.cancelar(res));
                      } else if (!widget.puedeGestionar && (res.estado == EstadoReserva.pendiente || res.estado == EstadoReserva.confirmada)) {
                        onCancelar = () => mostrarDialogoCancelacion( context, res, () => notifier.cancelar(res));
                      }

                      return ReservaCard(
                        reserva: res,
                        lineas: res.lineas.map((LineaReserva linea) => (
                          nombre: notifier.nombreEquipamiento(linea.idEquipamiento),
                          imagen: notifier.imagenEquipamiento(linea.idEquipamiento),
                          cantidad: linea.cantidad,
                        )).toList(),
                        
                        nombreUsuario: notifier.nombreUsuario(res.idUsuario),
                        nombreExcursion: notifier.nombreExcursion(res.idExcursion),
                        onEditar: () async { 
                          final Reserva? resultado = await Navigator.of(context) .push<Reserva>(
                            MaterialPageRoute( 
                              builder: (BuildContext _) =>
                              ReservationFormPage( reserva: res, initialIdUsuario: widget.puedeGestionar ? null : usuarioActual?.id),
                            ),
                          );
                          if (resultado != null) {
                            notifier.actualizar(res, resultado);
                          }
                        },
                        onAprobar: onAprobar,
                        onRechazar: onRechazar,
                        onRegistrarDevolucion: onRegistrarDevolucion,
                        onCancelar: onCancelar,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
