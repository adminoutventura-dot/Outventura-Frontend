import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/data/fakes/solicitudes_fake.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/controllers/requests_page_controller.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_category_tab.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
// import 'package:outventura/features/outventura/presentation/widgets/request_detail_sheet.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final _controller = RequestsPageController();
  EstadoSolicitud? _selectedEstado;

  List<Solicitud> get _filtered {
    return _controller.filterByEstado(
      solicitudes: solicitudesFake,
      selectedEstado: _selectedEstado,
    );
  }

  void _aceptar(Solicitud s) async {
    final updated = await _controller.aceptarSolicitud(
      context: context,
      solicitud: s,
      solicitudes: solicitudesFake,
    );
    if (!updated) return;
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aceptada. Excursión generada.')),
      );
    }
  }

  void _editar(Solicitud s) async {
    final result = await _controller.editSolicitud(
      context: context,
      solicitud: s,
    );
    if (result == null) return;
    setState(() {
      _controller.replaceSolicitud(
        solicitudes: solicitudesFake,
        current: s,
        updated: result,
      );
    });
  }

  void _rechazar(Solicitud s) async {
    final updated = await _controller.rechazarSolicitud(
      context: context,
      solicitud: s,
      solicitudes: solicitudesFake,
    );
    if (!updated) return;
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud rechazada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
          ColoredBox(
            color: cs.surface,
            child: Row(
              children: [
                Expanded(
                  child: ExcursionCategoryTab(
                    label: 'Todas',
                    selected: _selectedEstado == null,
                    onTap: () => setState(() => _selectedEstado = null),
                  ),
                ),
                for (final e in EstadoSolicitud.values)
                  Expanded(
                    child: ExcursionCategoryTab(
                      label: e.nombre,
                      selected: _selectedEstado == e,
                      onTap: () => setState(() => _selectedEstado = e),
                    ),
                  ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No hay solicitudes',
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = _filtered[index];
                      return SolicitudCard(
                        solicitud: s,
                        onGestionar: s.estado == EstadoSolicitud.pendiente ? () => _aceptar(s) : null,
                        onCancelar: s.estado == EstadoSolicitud.pendiente ? () => _rechazar(s) : null,
                        onEditar: () => _editar(s),
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