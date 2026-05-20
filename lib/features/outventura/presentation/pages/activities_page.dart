import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/activities_page_controller.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/activity_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/widgets/activity_card.dart';

class ActivitiesPage extends ConsumerStatefulWidget {
  final bool puedeGestionar;
  final bool puedeSolicitar;

  const ActivitiesPage({
    super.key,
    this.puedeGestionar = true,
    this.puedeSolicitar = false,
  });

  @override
  ConsumerState<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends ConsumerState<ActivitiesPage> {
  final SearchFieldController _search = SearchFieldController();
  final ActivitiesPageController _controller = ActivitiesPageController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final AsyncValue<List<Activity>> actividadesFiltradas = ref.watch(filteredActivitiesProvider((
      query: _search.query,
      estado: _controller.estadoFiltro,
      categoria: _controller.categoriaFiltro,
      fechaDesde: _controller.fechaDesde,
      fechaHasta: _controller.fechaHasta,
    )));

    return Scaffold(
      appBar: CustomAppBar(
        title: s.actividadesTitle,
        actions: [
          // Botón de filtros.
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
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              // Boton add
              child: AddFab(
                onPressed: () async {
                  final Activity? nueva = await Navigator.of(context)
                      .push<Activity>(
                        MaterialPageRoute(builder: (_) => const ActivityFormPage()),
                      );
                  if (nueva == null) {
                    return;
                  }
                  ref.read(activitiesProvider.notifier).agregar(nueva);
                  if (!context.mounted) {
                    return;
                  }
                  showSuccessSnackBar(context, s.actividadCreada);
                },
              ),
            )
          : null,

      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: s.searchByRoute,
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
          // Lista de actividades filtradas
          Expanded(
            child: actividadesFiltradas.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(s.error(error.toString()))),
              data: (List<Activity> lista) => ListView.separated(
              padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
              itemCount: lista.isEmpty ? 1 : lista.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {

                // Si la lista está vacía, se muestra un mensaje en vez de una card.
                if (lista.isEmpty) {
                  return Center(
                    child: Text(
                      s.noActividadesParaCategoria,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                final Activity actividad = lista[index];

                // Card de actividad 
                return ActivityCard(
                  actividad: actividad,
                  // Editar solo si puede gestionar
                  onEditar: widget.puedeGestionar
                      ? () async { 
                          final Activity? actualizada =
                              // Navega al formulario de edición pasando la actividad actual como argumento. 
                              // El formulario devuelve la actividad actualizada (o null si se canceló).
                              await Navigator.of(context).push<Activity>(
                                MaterialPageRoute(
                                  builder: (BuildContext _) =>
                                      ActivityFormPage(actividad: actividad),
                                ),
                              );
                          
                          if (actualizada == null) {
                            return;
                          }

                          // Actualiza la actividad en el provider.
                          ref.read(activitiesProvider.notifier).actualizar(actividad, actualizada);

                          if (!context.mounted) {
                            return;
                          }

                          // Muestra un snackbar de éxito.
                          showSuccessSnackBar(context, s.actividadActualizada);
                        }
                      : null,

                  // Eliminar solo si puede gestionar
                  onEliminar: widget.puedeGestionar
                      ? () async {
                        // Muestra un diálogo de confirmación antes de eliminar.
                          final bool confirm = await showConfirmDialog(
                            context: context,
                            title: s.deleteActividad,
                            content: s.deleteActividadConfirm('${actividad.startPoint} → ${actividad.endPoint}'),
                          );

                          // Si el usuario confirma, elimina la actividad del provider.
                          if (confirm) {
                            ref.read(activitiesProvider.notifier).eliminar(actividad);
                          }
                        }
                      : null,

                  // Solicitar solo si puede solicitar
                  onSolicitar: widget.puedeSolicitar
                      ? () async {
                        // Obtiene el usuario actual. Si no hay usuario (no debería pasar), no hace nada.
                          final usuario = ref.read(currentUserProvider);
                          if (usuario == null) {
                            showErrorSnackBar(context, s.error('Usuario no autenticado'));
                            return;
                          }

                          //
                          final Request? solicitud =
                          // Navega al formulario de solicitud pasando la actividad e ID de usuario como argumentos.
                              await Navigator.of(context).push<Request>(
                                // El formulario devuelve la solicitud creada (o null si se canceló).
                                MaterialPageRoute(
                                  builder: (_) => SolicitudFormPage(
                                    initialIdActividad: actividad.id,
                                    initialIdUsuario: usuario.id,
                                  ),
                                ),
                              );

                          if (solicitud == null) {
                            return;
                          }
                          // Agrega la solicitud al provider.
                          ref.read(requestsProvider.notifier).agregar(solicitud);
                          if (!context.mounted) {
                            return;
                          }

                          // Muestra un snackbar de éxito. 
                          // El mensaje varía si la solicitud tiene una reserva asociada o no.
                          final String mensaje = solicitud.reservationId != null
                              ? s.requestCreatedWithReservation
                              : s.requestCreated;
                          showSuccessSnackBar(context, mensaje);
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
