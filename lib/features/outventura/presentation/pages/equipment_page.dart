import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/equipment_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_tab.dart';
import 'package:outventura/features/outventura/presentation/widgets/equipment_card.dart';

class EquipmentPage extends ConsumerStatefulWidget {
  final bool puedeGestionar;
  final bool puedeSolicitar;

  const EquipmentPage({
    super.key,
    this.puedeGestionar = true,
    this.puedeSolicitar = false,
  });

  @override
  ConsumerState<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends ConsumerState<EquipmentPage> {
  CategoriaActividad? _categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider);

    List<Equipamiento> equipamientosFiltrados;
    if (_categoriaSeleccionada == null) {
      equipamientosFiltrados = equipamientos;
    } else {
      equipamientosFiltrados = equipamientos
          .where(
            (Equipamiento e) => e.categorias.contains(_categoriaSeleccionada),
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipamiento'),
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
      floatingActionButton: widget.puedeGestionar
          ? AddFab(
              onPressed: () async {
                final Equipamiento? nuevo = await Navigator.of(context)
                    .push<Equipamiento>(
                      MaterialPageRoute(
                        builder: (_) => const EquipmentFormPage(),
                      ),
                    );
                if (nuevo != null) {
                  ref.read(equipamientosProvider.notifier).agregar(nuevo);
                }
              },
            )
          : null,
      body: Column(
        // Barra de categorías
        children: [
          Row(
            children: [
              Expanded(
                child: AppTab(
                  label: 'Todos',
                  seleccionado: _categoriaSeleccionada == null,
                  onTap: () => setState(() => _categoriaSeleccionada = null),
                ),
              ),
              for (final CategoriaActividad categoria
                  in CategoriaActividad.values)
                Expanded(
                  child: AppTab(
                    label: categoria.label,
                    seleccionado: _categoriaSeleccionada == categoria,
                    onTap: () =>
                        setState(() => _categoriaSeleccionada = categoria),
                  ),
                ),
            ],
          ),

          // Lista de materiales filtrados
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                MediaQuery.of(context).padding.bottom + 80,
              ),
              // Si no hay materiales muestra un mensaje en lugar de la lista.
              itemCount: equipamientosFiltrados.isEmpty
                  ? 1
                  : equipamientosFiltrados.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                if (equipamientosFiltrados.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay equipamientos para esta categoría.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                final Equipamiento equipamiento = equipamientosFiltrados[index];
                return EquipmentCard(
                  equipamiento: equipamiento,
                  onEditar: widget.puedeGestionar
                      ? () async {
                          final Equipamiento? actualizado =
                              await Navigator.of(context).push<Equipamiento>(
                                MaterialPageRoute(
                                  builder: (BuildContext _) =>
                                      EquipmentFormPage(
                                        equipamiento: equipamiento,
                                      ),
                                ),
                              );
                          if (actualizado != null) {
                            ref
                                .read(equipamientosProvider.notifier)
                                .actualizar(equipamiento, actualizado);
                          }
                        }
                      : null,
                  onEliminar: widget.puedeGestionar
                      ? () async {
                          final bool confirm = await showConfirmDialog(
                            context: context,
                            title: 'Eliminar equipamiento',
                            content: '¿Eliminar "${equipamiento.nombre}"?',
                          );
                          if (confirm) {
                            ref
                                .read(equipamientosProvider.notifier)
                                .eliminar(equipamiento);
                          }
                        }
                      : null,
                  onAlquilar: widget.puedeSolicitar
                      ? () async {
                          final usuario = ref.read(currentUserProvider);
                          if (usuario == null) {
                            return;
                          }

                          final Reserva? reserva = await Navigator.of(context)
                              .push<Reserva>(
                                MaterialPageRoute(
                                  builder: (_) => ReservationFormPage(
                                    initialIdUsuario: usuario.id,
                                    initialIdEquipamiento: equipamiento.id,
                                  ),
                                ),
                              );

                          if (reserva == null) {
                            return;
                          }

                          ref.read(reservasProvider.notifier).agregar(reserva);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reserva creada correctamente.'),
                            ),
                          );
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
