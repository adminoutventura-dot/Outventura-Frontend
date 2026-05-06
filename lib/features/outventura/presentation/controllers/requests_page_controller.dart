import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';

class RequestsPageController {
  // --- Filtros ---
  EstadoSolicitud? estadoFiltro;
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  bool get hayFiltros => estadoFiltro != null || fechaDesde != null || fechaHasta != null;

  void mostrarFiltros(BuildContext context, StateSetter setState) {
    EstadoSolicitud? estadoTemp = estadoFiltro;
    DateTime? desdeTemp = fechaDesde;
    DateTime? hastaTemp = fechaHasta;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: 'Estado',
          chips: EstadoSolicitud.values
              .map((EstadoSolicitud e) => FilterChipSpec(
                    label: e.label,
                    seleccionado: estadoTemp == e,
                    onToggle: () => setModal(() => estadoTemp = estadoTemp == e ? null : e),
                  ))
              .toList(),
        ),
      ],
      mostrarFechas: true,
      fechaDesde: desdeTemp,
      fechaHasta: hastaTemp,
      onFechaDesdeChanged: (d) => setModal(() => desdeTemp = d),
      onFechaHastaChanged: (d) => setModal(() => hastaTemp = d),
      onFechasClear: () => setModal(() { desdeTemp = null; hastaTemp = null; }),
      onLimpiar: () => setModal(() {
        estadoTemp = null;
        desdeTemp = null;
        hastaTemp = null;
      }),
      onApply: () {
        setState(() {
          estadoFiltro = estadoTemp;
          fechaDesde = desdeTemp;
          fechaHasta = hastaTemp;
        });
        Navigator.pop(context);
      },
    ));
  }

  // --- Acciones ---
  // Acepta una solicitud después de pedir confirmación al usuario.
  Future<void> aceptar({
    required Solicitud solicitud,
    required BuildContext context,
    required WidgetRef ref,
    required bool Function() isMounted,
  }) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool confirm = await showConfirmDialog(
      context: context,
      title: 'Aceptar solicitud',
      content:
          '¿Aceptar la solicitud #${solicitud.id}?\nSe generará una excursión automáticamente.',
      confirmLabel: 'Aceptar',
      isDanger: false,
    );

    if (!confirm) {
      return;
    }
    ref.read(solicitudesProvider.notifier).aceptar(solicitud);

    if (isMounted()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Solicitud aceptada. Excursión generada.'),
        ),
      );
    }
  }

  // Navega a la página de edición de la solicitud. Si el resultado no es nulo, actualiza la solicitud con el resultado.
  Future<void> editar({
    required Solicitud solicitud,
    required BuildContext context,
    required WidgetRef ref,
    int? fixedIdUsuario,
  }) async {
    final Solicitud? result = await Navigator.push<Solicitud>(
      context,
      MaterialPageRoute(
        builder: (BuildContext _) => SolicitudFormPage(
          solicitud: solicitud,
          initialIdUsuario: fixedIdUsuario,
        ),
      ),
    );

    if (result == null) {
      return;
    }
    ref.read(solicitudesProvider.notifier).actualizar(solicitud, result);
    if (!context.mounted) {
      return;
    }
    if (result.idReserva != null && solicitud.idReserva == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva de materiales creada correctamente.')),
      );
    }
  }

  // Rechaza la solicitud después de pedir confirmación al usuario.
  Future<void> rechazar({
    required Solicitud solicitud,
    required BuildContext context,
    required WidgetRef ref,
    required bool Function() isMounted,
  }) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool confirm = await showConfirmDialog(
      context: context,
      title: 'Rechazar solicitud',
      content: '¿Rechazar la solicitud #${solicitud.id}?',
      confirmLabel: 'Rechazar',
    );
    if (!confirm) {
      return;
    }

    ref.read(solicitudesProvider.notifier).rechazar(solicitud);

    if (isMounted()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Solicitud rechazada.')),
      );
    }
  }
}
