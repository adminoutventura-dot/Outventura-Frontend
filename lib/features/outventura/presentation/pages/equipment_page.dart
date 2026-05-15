import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/equipment_page_controller.dart';
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
  final EquipmentPageController _controller = EquipmentPageController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final AppLocalizations s = AppLocalizations.of(context)!;

    // Escucha los equipamientos filtrados según el estado del controlador.
    // equipamientosFiltradosProvider(...) — provider que internamente coge todos los equipamientos y aplica los filtros.
    // Query: texto de búsqueda.
    // Estado: estado seleccionado (disponible, agotado, en mantenimiento...).
    // Categoria: caategoria seleccionada.
    final AsyncValue<List<Equipment>> equipamientosFiltrados = ref.watch(filteredEquipmentProvider((
      query: _search.query,
      estado: _controller.estadoFiltro,
      categoria: _controller.categoriaFiltro,
    )));

    return Scaffold(
      appBar: CustomAppBar(
        title: s.equipmentTitle,
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
      drawer: const AppDrawer(),
      floatingActionButton: widget.puedeGestionar
          ? AddFab(
              onPressed: () async {
                final Equipment? nuevo = await Navigator.of(context)
                    .push<Equipment>(
                      MaterialPageRoute(
                        builder: (_) => const EquipmentFormPage(),
                      ),
                    );
                if (nuevo == null) {
                  return;
                }
                ref.read(equipmentProvider.notifier).agregar(nuevo);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.materialCreated)),
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
              labelText: s.searchByName,
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
              data: (List<Equipment> lista) => ListView.separated(
              padding: EdgeInsets.fromLTRB( 12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
              itemCount: lista.isEmpty ? 1 : lista.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                if (lista.isEmpty) {
                  return Center(
                    child: Text(
                      s.noEquipmentForCategory,
                      style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                final Equipment equipamiento = lista[index];
                return EquipmentCard(
                  equipamiento: equipamiento,
                  onEditar: widget.puedeGestionar
                      ? () async {
                          final Equipment? actualizado =
                              await Navigator.of(context).push<Equipment>(
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
                          ref.read(equipmentProvider.notifier).actualizar(equipamiento, actualizado);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.materialUpdated)),
                          );
                        }
                      : null,
                  onEliminar: widget.puedeGestionar
                      ? () async {
                          final bool confirm = await showConfirmDialog(
                            context: context,
                            title: s.deleteEquipment,
                            content: s.deleteEquipmentConfirm(equipamiento.title),
                          );
                          if (confirm) {
                            ref.read(equipmentProvider.notifier).eliminar(equipamiento);
                          }
                        }
                      : null,
                  onAlquilar: widget.puedeSolicitar
                      ? () async {
                          final usuario = ref.read(currentUserProvider);
                          if (usuario == null) {
                            return;
                          }

                          final Reservation? reserva = await Navigator.of(context)
                              .push<Reservation>(
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

                          ref.read(reservationsProvider.notifier).agregar(reserva);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.reservationCreated)),
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
