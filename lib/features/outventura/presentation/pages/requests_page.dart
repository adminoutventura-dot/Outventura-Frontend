import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/controllers/requests_page_controller.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/search_controller.dart';
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
    final AsyncValue<List<Request>> filtradas = ref.watch(filteredRequestsProvider((
      query: _search.query,
      idUsuario: widget.puedeGestionar ? null : usuarioActual?.id,
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
      floatingActionButton: widget.puedeCrear
          ? AddFab(
              onPressed: () async {
                final Request? nueva = await Navigator.of(context)
                    .push<Request>(
                      MaterialPageRoute(
                        builder: (_) => const SolicitudFormPage(),
                      ),
                    );
                if (nueva == null) {
                  return;
                }
                ref.read(requestsProvider.notifier).agregar(nueva);
                if (!context.mounted) {
                  return;
                }
                final String mensaje = nueva.reservationId != null
                    ? s.requestCreatedWithReservation
                    : s.requestCreated;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje)),
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
          // Lista
          Expanded(
            child: filtradas.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (List<Request> lista) => lista.isEmpty
                ? Center(
                    child: Text(
                      s.noRequests,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final Request soli = lista[index];
                      final Activity? actividad = ref.watch(activityByIdProvider(soli.activityId));

                      final String? nombreUsuario = soli.userId != null
                          ? ref.watch(userNameProvider(soli.userId!))
                          : null;

                      if (actividad == null) return const SizedBox.shrink();

                      return RequestCard(
                        solicitud: soli,
                        actividad: actividad,
                        nombreUsuario: (!widget.puedeGestionar)
                            ? null
                            : nombreUsuario,
                        onGestionar:
                            widget.puedeGestionar &&
                                soli.status == RequestStatus.pendiente
                            ? () => _controller.aceptar(
                                solicitud: soli,
                                context: context,
                                ref: ref,
                                isMounted: () => mounted,
                              )
                            : null,
                        onCancelar: soli.status == RequestStatus.pendiente
                            ? () => _controller.rechazar(
                                solicitud: soli,
                                context: context,
                                ref: ref,
                                isMounted: () => mounted,
                              )
                            : null,
                        onEditar: (!widget.puedeGestionar && soli.status != RequestStatus.pendiente)
                            ? null
                            : () => _controller.editar(
                                solicitud: soli,
                                context: context,
                                ref: ref,
                                // Si el usuario no puede gestionar, se le asigna su propio ID para que solo pueda editar su solicitud
                                fixedIdUsuario: widget.puedeGestionar ? null : ref.read(currentUserProvider)?.id,
                              ),
                        onVerDetalle: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RequestDetailPage(solicitud: soli),
                          ));
                        },
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
