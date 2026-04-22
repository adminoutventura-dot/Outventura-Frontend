import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/controllers/requests_page_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_category_tab.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';

class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  EstadoSolicitud? _estadoSeleccionado;
  final RequestsPageController _controller = RequestsPageController();

  // TODO: En equipamiento las acciones estaban en ek mismo  onEditar, onEliminar...
  void _aceptar(Solicitud soli) => _controller.aceptar(
        solicitud: soli,
        context: context,
        ref: ref,
        isMounted: () => mounted,
      );

  void _editar(Solicitud soli) => _controller.editar(
        solicitud: soli,
        context: context,
        ref: ref,
      );

  void _rechazar(Solicitud soli) => _controller.rechazar(
        solicitud: soli,
        context: context,
        ref: ref,
        isMounted: () => mounted,
      );

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Solicitud> solicitudes = ref.watch(solicitudesProvider);
    final List<Excursion> excursiones = ref.watch(excursionesProvider);

    List<Solicitud> filtradas;
    if (_estadoSeleccionado == null) {
      filtradas = solicitudes;
    } else {
      filtradas = solicitudes.where((Solicitud soli) => soli.estado == _estadoSeleccionado).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de solicitudes'),
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
                  seleccionado: _estadoSeleccionado == null,
                  onTap: () => setState(() => _estadoSeleccionado = null),
                ),
              ),
              for (final EstadoSolicitud e in EstadoSolicitud.values)
                Expanded(
                  child: ExcursionCategoryTab(
                    label: e.label,
                    seleccionado: _estadoSeleccionado == e,
                    onTap: () => setState(() => _estadoSeleccionado = e),
                  ),
                ),
            ],
          ),
          

          // Lista
          Expanded(
            child: filtradas.isEmpty
                ? Center(
                    child: Text(
                      'No hay solicitudes',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtradas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {

                      final Solicitud soli = filtradas[index];
                      Excursion excursion = excursiones.first;
                      for (final Excursion e in excursiones) {
                        if (e.id == soli.idExcursion) {
                          excursion = e;
                          break;
                        }
                      }

                      return SolicitudCard(
                        solicitud: soli,
                        excursion: excursion,
                        onGestionar: soli.estado == EstadoSolicitud.pendiente ? () => _aceptar(soli) : null,
                        onCancelar: soli.estado == EstadoSolicitud.pendiente ? () => _rechazar(soli) : null,
                        onEditar: () => _editar(soli),
                        onVerDetalle: () {} 
                        // => showSolicitudDetailSheet(
                        //   context: context,
                        //   solicitud: s,
                        //   onAceptar: () => _aceptar(s),
                        //   onRechazar: () => _rechazar(s),
                        // ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}