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
      filtradas = reservas.where((Reserva res) => res.estado == _filtro).toList();
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
              for (final EstadoReserva estadoR in EstadoReserva.values)
                Expanded(
                  child: ExcursionCategoryTab(
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
                    padding: const EdgeInsets.all(12),
                    itemCount: filtradas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, int i) {
                      final Reserva res = filtradas[i];

                      VoidCallback? onAprobar;
                      if (res.estado == EstadoReserva.pendiente) {
                        onAprobar = () => mostrarDialogoAprobacion(context, res, () => notifier.aprobar(res));
                      }

                      VoidCallback? onRechazar;
                      if (res.estado == EstadoReserva.pendiente) {
                        onRechazar = () => mostrarDialogoRechazo(context, res, () => notifier.rechazar(res));
                      }

                      VoidCallback? onRegistrarDevolucion;
                      if (res.estado == EstadoReserva.confirmada) {
                        onRegistrarDevolucion = () => mostrarDialogoDevolucion(context, res, () => notifier.registrarDevolucion(res));
                      }

                      VoidCallback? onCancelar;
                      if (res.estado == EstadoReserva.confirmada) {
                        onCancelar = () => mostrarDialogoCancelacion(context, res, () => notifier.cancelar(res));
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
                          final Reserva? resultado = await Navigator.of(context).push<Reserva>(
                            MaterialPageRoute(builder: (BuildContext _) => ReservationFormPage(reserva: res)),
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
