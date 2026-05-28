import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/controllers/requests_page_controller.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
import 'package:outventura/features/outventura/presentation/pages/request_detail_page.dart';

class RequestsPage extends ConsumerStatefulWidget {
  final bool puedeGestionar;
  final bool puedeCrear;

  const RequestsPage({
    super.key,
    this.puedeGestionar = true,
    this.puedeCrear = true,
  });

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  final SearchFieldController _search = SearchFieldController();
  final RequestsPageController _controller = RequestsPageController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    final usuarioActual = ref.watch(currentUserProvider);
    
    final bool isGuide = usuarioActual?.role.code == 'GUIDE';
    
    // Si es gestor de verdad (ADMIN/SUPER) ve todas. 
    // Si es CLIENTE o GUÍA, se le pasa su propio ID para que solo vea las suyas.
    final int? idFiltro = widget.puedeGestionar ? null : usuarioActual?.id;

    final AsyncValue<List<Request>> filtradasAsync = ref.watch(filteredRequestsProvider((
      query: _search.query,
      idUsuario: idFiltro,
      estado: _controller.estadoFiltro,
      fechaDesde: _controller.fechaDesde,
      fechaHasta: _controller.fechaHasta,
    )));

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.puedeGestionar ? s.requestManagement : s.requestsTitle,
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
      // 🌟 MODIFICADO: Solo muestra el FAB si tiene permiso Y NO ES GUÍA.
      floatingActionButton: (widget.puedeCrear && !isGuide)
          ? AddFab(
              onPressed: () async {
                final Request? nueva = await Navigator.of(context)
                    .push<Request>(
                      MaterialPageRoute(
                        builder: (_) => SolicitudFormPage(
                        initialIdUsuario: (widget.puedeGestionar && !isGuide) ? null : usuarioActual?.id,
                      ),
                      ),
                    );

                if (nueva == null) return;

                try {
                  await ref.read(requestsProvider.notifier).agregar(nueva);
                  if (!context.mounted) return;

                  final String mensaje = nueva.bookingId != null
                      ? s.requestCreatedWithReservation
                      : s.requestCreated;
                  showSuccessSnackBar(context, mensaje);
                } catch (e) {
                  if (!context.mounted) return;
                  showErrorSnackBar(context, s.error(e.toString()));
                }
              },
            )
          : null,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: s.searchByActividadRoute,
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

          Expanded(
            child: filtradasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(s.error(error.toString()))),
              data: (List<Request> listaCompleta) {
                
                // Filtro para que el guía solo vea las suyas (o las asignadas)
                List<Request> listaFinal = listaCompleta;
                if (isGuide) {
                  final int? miIdUsuario = usuarioActual?.id; 
                  listaFinal = listaCompleta.where((r) => 
                    r.guideId == miIdUsuario || r.userId == miIdUsuario
                  ).toList();
                }

                if (listaFinal.isEmpty) {
                  return Center(
                    child: Text(
                      s.noRequests,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                    itemCount: listaFinal.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final Request soli = listaFinal[index];
                      final Activity? actividad = ref.watch(activityByIdProvider(soli.activityId));
                      
                      final String? nombreUsuario = soli.userId != null
                          ? ref.watch(userNameProvider(soli.userId!))
                          : null;
                          
                      // 🌟 BUSCAMOS EL NOMBRE DEL EXPERTO
                      final String? nombreExperto = soli.guideId != null
                          ? ref.watch(userNameProvider(soli.guideId!))
                          : null;
                      
                      if (actividad == null) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Solicitud #${soli.id}: Actividad no encontrada',
                              style: tt.bodySmall?.copyWith(color: cs.error),
                            ),
                          ),
                        );
                      }
                      
                      return RequestCard(
                        solicitud: soli,
                        actividad: actividad,
                        nombreUsuario: (!widget.puedeGestionar || isGuide) ? null : nombreUsuario,
                        nombreExperto: nombreExperto, // 🌟 SE LO PASAMOS A LA TARJETA
                            
                        onGestionar: (!isGuide && widget.puedeGestionar && soli.status == WorkflowStatus.pendiente)
                            ? () async {
                                await _controller.aceptar(solicitud: soli, context: context, ref: ref);
                                ref.invalidate(requestsProvider);
                              }
                            : null,
                            
                        onCancelar: (!isGuide && soli.status == WorkflowStatus.pendiente)
                            ? () async {
                                await _controller.rechazar(solicitud: soli, context: context, ref: ref);
                                ref.invalidate(requestsProvider);
                              }
                            : null,
                            
                        onEditar: isGuide 
                            ? null 
                            : (!widget.puedeGestionar && soli.status != WorkflowStatus.pendiente)
                                ? null 
                                : () async {
                                    await _controller.editar(
                                      solicitud: soli,
                                      context: context,
                                      ref: ref,
                                      fixedIdUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
                                    );
                                    ref.invalidate(requestsProvider);
                                  },
                                  
                        onVerDetalle: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RequestDetailPage(solicitud: soli),
                          ));
                        },
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