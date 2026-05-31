import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/auth/presentation/providers/guides_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/activities_page_controller.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/activity_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/booking_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/activity_detail_page.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/widgets/activity_card.dart';
import 'package:outventura/l10n/app_localizations.dart';

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
  void initState() {
    super.initState();
    // Aplicar filtro por guía si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuarioActual = ref.read(currentUserProvider);
      final bool isGuide = usuarioActual?.role.code == 'GUIDE';
      if (isGuide && widget.puedeGestionar) {
        final guide = ref.read(guidesProvider).value?.where((g) => g.userId == usuarioActual!.id).firstOrNull;
        if (guide != null) {
          ref.read(activitiesProvider.notifier).aplicarFiltroGuia(guide.id);
        }
      }
    });
  }

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

    final usuarioActual = ref.watch(currentUserProvider);
    final bool isGuide = usuarioActual?.role.code == 'GUIDE';
    final bool isGuest =
        usuarioActual == null ||
        usuarioActual.role.code == 'INVITADO' ||
        usuarioActual.role.code == 'GUEST';

    final guide = isGuide ? ref.watch(guidesProvider).value?.where((g) => g.userId == usuarioActual!.id).firstOrNull : null;

    final actividadesAsync = ref.watch(activitiesProvider);

    final activitiesNotifier = ref.read(activitiesProvider.notifier);
    final int currentPage = activitiesNotifier.currentPage;
    final int totalPages = activitiesNotifier.totalPages;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CustomAppBar(
        title: s.actividadesTitle,
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
                // Derivar las categorías y dificultades disponibles del catálogo
                // ya cargado, evitando llamar a /category (que devuelve 403 para
                // los roles USER y GUEST).
                final List<Activity> todas = ref.read(allActivitiesProvider);
                final List<Category> categoriasBack = [];
                final Set<String> vistas = {};
                for (final Activity a in todas) {
                  for (final Category c in a.categories) {
                    if (vistas.add(c.code)) categoriasBack.add(c);
                  }
                }
                final List<int> dificultadesBack =
                    todas.map((Activity a) => a.difficulty).toSet().toList()
                      ..sort();

                if (!context.mounted) return;

                _controller.mostrarFiltros(context, (fn) {
                  setState(fn);
                  activitiesNotifier.aplicarFiltrosAvanzados(
                    categoria: _controller.categoriaFiltro,
                    dificultad: _controller.dificultadFiltro,
                    fechaDesde: _controller.fechaDesde,
                    fechaHasta: _controller.fechaHasta,
                  );
                }, categoriasBack, dificultadesBack);
              },
            ),
          ),
        ],
      ),
      drawer: widget.puedeGestionar ? null : const AppDrawer(),
      floatingActionButton: widget.puedeGestionar
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: AddFab(
                onPressed: () async {
                  final Activity? nueva = await Navigator.of(context)
                      .push<Activity>(
                        MaterialPageRoute(
                          builder: (_) => const ActivityFormPage(),
                        ),
                      );
                  if (nueva == null) return;
                  try {
                    await ref.read(activitiesProvider.notifier).agregar(nueva);
                    if (!context.mounted) return;
                    showSuccessSnackBar(context, s.actividadCreada);
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorSnackBar(context, s.error(e.toString()));
                  }
                },
              ),
            )
          : null,
      body: Column(
        children: [
          // 1. BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: s.searchByRoute,
              prefixIcon: Icons.search,
              suffixIcon: _search.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _search.clear();
                        activitiesNotifier.aplicarFiltroTexto('');
                      }),
                    )
                  : null,
              onChanged: (String v) => setState(() {
                _search.query = v;
                activitiesNotifier.aplicarFiltroTexto(v);
              }),
            ),
          ),

          // PAGINACIÓN COMPACTA < 1 / 2 >
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
                        ? () => ref.read(activitiesProvider.notifier).cambiarPagina(currentPage - 1)
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
                        ? () => ref.read(activitiesProvider.notifier).cambiarPagina(currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),

          // 3. LISTADO DE EXCURSIONES
          Expanded(
            child: actividadesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(s.error(error.toString()))),
              data: (List<Activity> listaOriginal) {
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    6,
                    12,
                    MediaQuery.of(context).padding.bottom + 100,
                  ),
                  itemCount: listaOriginal.isEmpty ? 1 : listaOriginal.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  if (listaOriginal.isEmpty) {
                    return Center(
                      child: Text(
                        s.noActividadesParaCategoria,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  final Activity actividad = listaOriginal[index];
                  return ActivityCard(
                    actividad: actividad,
                    onVerDetalle: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ActivityDetailPage(actividad: actividad),
                        ),
                      );
                      },
                    onEditar: (widget.puedeGestionar && (!isGuide || actividad.guideId == guide?.id))
                        ? () async {
                            final Activity? actualizada = await Navigator.of(context).push<Activity>(
                              MaterialPageRoute(
                                builder: (_) => ActivityFormPage(actividad: actividad),
                              ),
                            );
                            if (actualizada == null) return;
                            try {
                              await ref.read(activitiesProvider.notifier).actualizar(actividad, actualizada);
                              if (!context.mounted) return;
                              showSuccessSnackBar(context, s.actividadActualizada);
                            } catch (e) {
                              if (!context.mounted) return;
                              showErrorSnackBar(context, s.error(e.toString()));
                            }
                          }
                        : null,
                    onEliminar: (widget.puedeGestionar && (!isGuide || actividad.guideId == guide?.id))
                        ? () async {
                            final bool confirm = await showConfirmDialog(
                              context: context,
                              title: s.deleteActividad,
                              content: '${s.deleteActividadConfirm(actividad.title)}\n\n⚠️ ¡Atención! Al eliminar esta actividad se borrarán permanentemente totes les reserves associades a ella.',
                            );
                            if (confirm) {
                              try {
                                await ref.read(activitiesProvider.notifier).eliminar(actividad);
                                if (!context.mounted) return;
                                showSuccessSnackBar(context, 'Actividad eliminada con éxito');
                              } catch (e) {
                                if (!context.mounted) return;
                                showErrorSnackBar(context, s.error(e.toString()));
                              }
                            }
                          }
                        : null,
                    onSolicitar: widget.puedeSolicitar
                        ? () async {
                            if (isGuest) {
                              showErrorSnackBar(context, 'Necesitas iniciar sesión para apuntarte a una excursión.');
                              return;
                            }
                            final usuario = ref.read(currentUserProvider);
                            if (usuario == null) return;

                            final Booking? reserva = await Navigator.of(context).push<Booking>(
                              MaterialPageRoute(
                                builder: (_) => BookingFormPage(
                                  initialIdActividad: actividad.id,
                                  initialIdUsuario: usuario.id,
                                ),
                              ),
                            );

                            if (reserva == null) return;
                            try {
                              await ref.read(reservationsProvider.notifier).agregar(reserva);
                              if (!context.mounted) return;
                              showSuccessSnackBar(context, 'Reserva realizada con éxito');
                            } catch (e) {
                              if (!context.mounted) return;
                              
                              // EXTRACTOR ULTRA-SEGURO PARA FORZAR EL ERROR EN PANTALLA
                              String mensajeError = 'Error desconocido al realizar la reserva';
                              
                              try {
                                final dynamic errorDinamico = e;
                                // Comprueba si el objeto de error tiene una propiedad 'message' o 'msg'
                                mensajeError = errorDinamico.message ?? errorDinamico.msg ?? e.toString();
                              } catch (_) {
                                mensajeError = e.toString();
                              }

                              showErrorSnackBar(context, mensajeError);
                            }
                          }
                        : null,
                  );
                },
              );
            },
            ),
          ),
        ],
      ),
    );
  }
}