import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/booking_form_page.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/equipment_page_controller.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/equipment_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/categories_provider.dart'; 
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
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

    final usuarioActual = ref.watch(currentUserProvider);
    final bool isGuide = usuarioActual?.role.code == 'GUIDE';

    final bool isGuest =
        usuarioActual == null ||
        usuarioActual.role.code == 'INVITADO' ||
        usuarioActual.role.code == 'GUEST';

    // Escucha la lista ya filtrada por rol y paginada desde el Notifier
    final AsyncValue<List<Equipment>> equipamientosAsync = ref.watch(equipmentProvider);

    final equipmentNotifier = ref.read(equipmentProvider.notifier);
    final int currentPage = equipmentNotifier.currentPage;
    final int totalPages = equipmentNotifier.totalPages;

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
              onPressed: () async { 
                final estadosBack = await ref.read(equipmentStatusesProvider.future);
                final categoriasBack = await ref.read(categoriesProvider.future); 
                
                if (!context.mounted) return; 

                _controller.mostrarFiltros(context, (fn) {
                  setState(fn);
                  equipmentNotifier.aplicarFiltrosAvanzados(
                    estado: _controller.estadoFiltro,
                    categoria: _controller.categoriaFiltro,
                  );
                }, estadosBack, categoriasBack);
              },
            ),
          ),
        ],
      ),
      drawer: widget.puedeGestionar ? null : const AppDrawer(),
      floatingActionButton: (widget.puedeGestionar && !isGuide)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: AddFab(
                onPressed: () async {
                  final Equipment? nuevo = await Navigator.of(context)
                      .push<Equipment>(
                        MaterialPageRoute(
                          builder: (_) => const EquipmentFormPage(),
                        ),
                      );
                  if (nuevo == null) return;

                  try {
                    await ref.read(equipmentProvider.notifier).agregar(nuevo);
                    if (!context.mounted) return;
                    showSuccessSnackBar(context, s.materialCreated);
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorSnackBar(context, e.toString());
                  }
                },
              ),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: s.searchByName,
              prefixIcon: Icons.search,
              suffixIcon: _search.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _search.clear();
                        equipmentNotifier.aplicarFiltroTexto('');
                      }),
                    )
                  : null,
              onChanged: (String v) => setState(() {
                _search.query = v;
                equipmentNotifier.aplicarFiltroTexto(v);
              }),
            ),
          ),

          // Paginación Reactiva < 1 / X >
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
                        ? () => ref.read(equipmentProvider.notifier).cambiarPagina(currentPage - 1)
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
                        ? () => ref.read(equipmentProvider.notifier).cambiarPagina(currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),

          Expanded(
            child: equipamientosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(s.error(error.toString()))),
              data: (List<Equipment> lista) => ListView.separated(
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
                        s.noEquipmentForCategory,
                        style: tt.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final Equipment equipamiento = lista[index];
                  return EquipmentCard(
                    equipamiento: equipamiento,
                    onEditar: (widget.puedeGestionar && !isGuide)
                        ? () async {
                            final Equipment? actualizado =
                                await Navigator.of(context).push<Equipment>(
                              MaterialPageRoute(
                                builder: (BuildContext _) => EquipmentFormPage(
                                  equipamiento: equipamiento,
                                ),
                              ),
                            );
                            if (actualizado == null) return;

                            try {
                              await ref
                                  .read(equipmentProvider.notifier)
                                  .actualizar(equipamiento, actualizado);
                              if (!context.mounted) return;
                              showSuccessSnackBar(context, s.materialUpdated);
                            } catch (e) {
                              if (!context.mounted) return;
                              showErrorSnackBar(context, e.toString());
                            }
                          }
                        : null,
                    onEliminar: (widget.puedeGestionar && !isGuide)
                        ? () async {
                            final bool confirm = await showConfirmDialog(
                              context: context,
                              title: s.deleteEquipment,
                              content: s.deleteEquipmentConfirm(equipamiento.title));

                            if (confirm) {
                              try {
                                await ref
                                    .read(equipmentProvider.notifier)
                                    .eliminar(equipamiento);
                                if (context.mounted) {
                                  showSuccessSnackBar(context, 'Material eliminado');
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                showErrorSnackBar(context, e.toString());
                              }
                            }
                          }
                        : null,
                    onAlquilar: widget.puedeSolicitar
                        ? () async {
                            if (isGuest) {
                              showErrorSnackBar(
                                context,
                                'Necesitas iniciar sesión para alquilar equipamiento.',
                              );
                              return;
                            }

                            final usuario = ref.read(currentUserProvider);
                            if (usuario == null) return;

                            final Booking? reserva = await Navigator.of(context)
                                .push<Booking>(
                              MaterialPageRoute(
                                builder: (_) => BookingFormPage(
                                  initialIdUsuario: usuario.id,
                                  initialIdEquipamiento: equipamiento.id,
                                ),
                              ),
                            );

                            if (reserva == null) return;

                            try {
                              await ref
                                  .read(reservationsProvider.notifier)
                                  .agregar(reserva);
                              if (!context.mounted) return;
                              showSuccessSnackBar(context, s.reservationCreated);
                            } catch (e) {
                              if (!context.mounted) return;
                              showErrorSnackBar(context, e.toString());
                            }
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