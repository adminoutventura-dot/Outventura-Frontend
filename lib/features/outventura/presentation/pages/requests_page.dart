import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
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

  // TODO: Mover estas funciones a un controller para RequestsPage
  void _aceptar(Solicitud s) async {
    final bool confirm = await showConfirmDialog(
      context: context,
      title: 'Aceptar solicitud',
      content:
          '¿Aceptar la solicitud #${s.id}?\nSe generará una excursión automáticamente.',
      confirmLabel: 'Aceptar',
      isDanger: false,
    );
    if (!confirm) return;
    ref.read(solicitudesProvider.notifier).actualizar(
          s,
          s.copyWith(estado: EstadoSolicitud.confirmada),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aceptada. Excursión generada.')),
      );
    }
  }

  void _editar(Solicitud s) async {
    final Solicitud? result = await Navigator.push<Solicitud>(
      context,
      MaterialPageRoute(
        builder: (_) => SolicitudFormPage(solicitud: s),
      ),
    );
    if (result == null) return;
    ref.read(solicitudesProvider.notifier).actualizar(s, result);
  }

  void _rechazar(Solicitud s) async {
    final bool confirm = await showConfirmDialog(
      context: context,
      title: 'Rechazar solicitud',
      content: '¿Rechazar la solicitud #${s.id}?',
      confirmLabel: 'Rechazar',
    );
    if (!confirm) return;
    ref.read(solicitudesProvider.notifier).actualizar(
          s,
          s.copyWith(estado: EstadoSolicitud.cancelada),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud rechazada.')),
      );
    }
  }

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
      filtradas = solicitudes.where((Solicitud s) => s.estado == _estadoSeleccionado).toList();
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
                      final Solicitud s = filtradas[index];
                      final Excursion excursion = excursiones.firstWhere(
                        (e) => e.id == s.idExcursion,
                        orElse: () => excursiones.first,
                      );
                      return SolicitudCard(
                        solicitud: s,
                        excursion: excursion,
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