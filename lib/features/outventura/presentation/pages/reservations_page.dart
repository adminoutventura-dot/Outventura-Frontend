import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_category_tab.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_dialogs.dart';

class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage> {
  EstadoReserva? _filtro;

  // TODO: Esto puede ser mejor moverlo a otro archivo
  Future<void> _abrirEdicion(Reserva r) async {
    final Reserva? resultado = await Navigator.of(context).push<Reserva>(
      MaterialPageRoute(builder: (_) => ReservationFormPage(reserva: r)),
    );
    if (resultado != null) {
      ref.read(reservasProvider.notifier).actualizar(r, resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Reserva> reservas = ref.watch(reservasProvider);
    final ReservasNotifier notifier = ref.read(reservasProvider.notifier);

    List<Reserva> filtradas;
    if (_filtro == null) {
      filtradas = reservas;
    } else {
      filtradas = reservas.where((r) => r.estado == _filtro).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de reservas'),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          // Filtros 
          Row(
            children: [
              Expanded(
                child: ExcursionCategoryTab(
                  label: 'Todas',
                  seleccionado: _filtro == null,
                  onTap: () => setState(() => _filtro = null),
                ),
              ),
              for (final EstadoReserva e in EstadoReserva.values)
                Expanded(
                  child: ExcursionCategoryTab(
                    label: e.label,
                    seleccionado: _filtro == e,
                    onTap: () => setState(() => _filtro = e),
                  ),
                ),
            ],
            
          ),

          // Lista
          Expanded(
            child: filtradas.isEmpty
                ? Center(child: Text('No hay reservas', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtradas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, int i) {
                      final Reserva r = filtradas[i];

                      VoidCallback? onAprobar;
                      if (r.estado == EstadoReserva.pendiente) {
                        onAprobar = () => mostrarDialogoAprobacion(context, r, () => notifier.aprobar(r));
                      }

                      VoidCallback? onRechazar;
                      if (r.estado == EstadoReserva.pendiente) {
                        onRechazar = () => mostrarDialogoRechazo(context, r, () => notifier.rechazar(r));
                      }

                      VoidCallback? onRegistrarDevolucion;
                      if (r.estado == EstadoReserva.confirmada) {
                        onRegistrarDevolucion = () => mostrarDialogoDevolucion(context, r, () => notifier.registrarDevolucion(r));
                      }

                      VoidCallback? onCancelar;
                      if (r.estado == EstadoReserva.confirmada) {
                        onCancelar = () => mostrarDialogoCancelacion(context, r, () => notifier.cancelar(r));
                      }

                      return ReservaCard(
                        reserva: r,
                        lineas: r.lineas.map((LineaReserva l) => (
                          nombre: notifier.nombreEquipamiento(l.idEquipamiento),
                          imagen: notifier.imagenEquipamiento(l.idEquipamiento),
                          cantidad: l.cantidad,
                        )).toList(),
                        nombreUsuario: notifier.nombreUsuario(r.idUsuario),
                        nombreExcursion: notifier.nombreExcursion(r.idExcursion),
                        onEditar: () => _abrirEdicion(r),
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
