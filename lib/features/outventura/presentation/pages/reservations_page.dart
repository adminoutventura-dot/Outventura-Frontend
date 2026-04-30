import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
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

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final usuarioActual = ref.watch(currentUserProvider);
    final ReservasNotifier notifier = ref.read(reservasProvider.notifier);
    final AsyncValue<List<Reserva>> filtradas = ref.watch(reservasFiltadasProvider((
      query: _search.query,
      idUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.puedeGestionar ? 'Gestión de reservas' : 'Reservas'),
        automaticallyImplyLeading: true,
        actions: const [],
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
      floatingActionButton: widget.puedeCrear
          ? AddFab(
              onPressed: () async {
                final Reserva? nueva = await Navigator.of(context)
                    .push<Reserva>(
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
                  const SnackBar(content: Text('Reserva creada correctamente.')),
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
              labelText: 'Buscar por usuario o excursión...',
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
              data: (List<Reserva> lista) => lista.isEmpty
                ? Center(child: Text('No hay reservas', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, int i) {
                      final Reserva res = lista[i];

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
                          nombre: ref.watch(nombreEquipamientoProvider(linea.idEquipamiento)),
                          imagen: ref.watch(imagenEquipamientoProvider(linea.idEquipamiento)),
                          cantidad: linea.cantidad,
                        )).toList(),
                        
                        nombreUsuario: ref.watch(nombreUsuarioProvider(res.idUsuario)),
                        nombreExcursion: ref.watch(nombreExcursionProvider(res.idExcursion)),
                        onEditar: () async { 
                          final Reserva? resultado = await Navigator.of(context) .push<Reserva>(
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
                            const SnackBar(content: Text('Reserva actualizada correctamente.')),
                          );
                        },
                        onAprobar: onAprobar,
                        onRechazar: onRechazar,
                        onRegistrarDevolucion: onRegistrarDevolucion,
                        onCancelar: onCancelar,
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
