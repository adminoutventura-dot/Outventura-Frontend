import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class RequestsPageController {
  // --- Filtros ---
  WorkflowStatus? estadoFiltro;
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  bool get hayFiltros => estadoFiltro != null || fechaDesde != null || fechaHasta != null;

  void mostrarFiltros(BuildContext context, StateSetter setState) {
    WorkflowStatus? estadoTemp = estadoFiltro;
    DateTime? desdeTemp = fechaDesde;
    DateTime? hastaTemp = fechaHasta;
    final s = AppLocalizations.of(context)!;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: s.statusFilter,
          chips: WorkflowStatus.values
              .map((WorkflowStatus e) => FilterChipSpec(
                    label: e.localizedLabel(s),
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
    required Request solicitud,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final s = AppLocalizations.of(context)!;
    final bool confirm = await showConfirmDialog(
      context: context,
      title: s.acceptRequest,
      content: s.acceptRequestConfirm,
      confirmLabel: s.accept,
      isDanger: false,
    );

    if (!confirm) {
      return;
    }

    try {
      await ref.read(requestsProvider.notifier).aceptar(solicitud);
      
      if (!context.mounted) return;
      showSuccessSnackBar(context, s.requestAccepted);
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, s.error(e.toString()));
    }
  }

  // Navega a la página de edición de la solicitud. Si el resultado no es nulo, actualiza la solicitud con el resultado.
  Future<void> editar({
    required Request solicitud,
    required BuildContext context,
    required WidgetRef ref,
    int? fixedIdUsuario,
  }) async {
    final s = AppLocalizations.of(context)!;
    final Request? result = await Navigator.push<Request>(
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
    
    try {
      await ref.read(requestsProvider.notifier).actualizar(solicitud, result);
      
      if (!context.mounted) return;
      if (result.bookingId != null && solicitud.bookingId == null) {
        final s = AppLocalizations.of(context)!;
        showSuccessSnackBar(context, s.materialReservationCreated);
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, s.error(e.toString()));
    }
  }

  // Rechaza la solicitud después de pedir confirmación al usuario.
  Future<void> rechazar({
    required Request solicitud,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final s = AppLocalizations.of(context)!;
    final bool confirm = await showConfirmDialog(
      context: context,
      title: s.rejectRequest,
      content: s.rejectRequestConfirm,
      confirmLabel: s.reject,
    );
    if (!confirm) {
      return;
    }

    try {
      await ref.read(requestsProvider.notifier).rechazar(solicitud);
      
      if (!context.mounted) return;
      showSuccessSnackBar(context, s.requestRejected);
    } catch (e) {
      if (!context.mounted) return;
      showErrorSnackBar(context, s.error(e.toString()));
    }
  }
}
