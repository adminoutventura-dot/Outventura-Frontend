import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/equipment_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
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

    final AsyncValue<List<Equipamiento>> equipamientosFiltrados = ref.watch(equipamientosFiltradosProvider(_search.query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipamiento'),
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
      floatingActionButton: widget.puedeGestionar
          ? AddFab(
              onPressed: () async {
                final Equipamiento? nuevo = await Navigator.of(context)
                    .push<Equipamiento>(
                      MaterialPageRoute(
                        builder: (_) => const EquipmentFormPage(),
                      ),
                    );
                if (nuevo == null) {
                  return;
                }
                ref.read(equipamientosProvider.notifier).agregar(nuevo);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Material creado correctamente.')),
                );
              },
            )
          : null,
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: 'Buscar por nombre...',
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

          // Lista de materiales filtrados
          Expanded(
            child: equipamientosFiltrados.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (List<Equipamiento> lista) => ListView.separated(
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                MediaQuery.of(context).padding.bottom + 80,
              ),
              itemCount: lista.isEmpty ? 1 : lista.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                if (lista.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay equipamientos para esta categoría.',
                      style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                final Equipamiento equipamiento = lista[index];
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
                          if (actualizado == null) {
                            return;
                          }
                          ref.read(equipamientosProvider.notifier).actualizar(equipamiento, actualizado);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Material actualizado correctamente.')),
                          );
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
                            ref.read(equipamientosProvider.notifier).eliminar(equipamiento);
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
                            const SnackBar(content: Text('Reserva creada correctamente.')),
                          );
                        }
                      : null,
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
