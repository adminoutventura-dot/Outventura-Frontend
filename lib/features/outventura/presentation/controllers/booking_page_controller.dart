import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
// Importa el enum TipoReserva desde su provider
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';

class ReservationsPageController {
  WorkflowStatus? estadoFiltro;
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  // Guarda el estado de la pestaña seleccionada (Todas, Materiales, Actividades)
  TipoReserva tipoFiltro = TipoReserva.todas;

  bool get hayFiltros =>
      estadoFiltro != null || fechaDesde != null || fechaHasta != null || tipoFiltro != TipoReserva.todas;

  void mostrarFiltros(BuildContext context, StateSetter setState, {VoidCallback? onApply}) {
    WorkflowStatus? estadoTemp = estadoFiltro;
    DateTime? desdeTemp = fechaDesde;
    DateTime? hastaTemp = fechaHasta;
    TipoReserva tipoTemp = tipoFiltro;

    mostrarFiltrosSheet(
      context,
      (setModal) => FilterBottomSheetContent(
        grupos: [
          FilterGrupo(
            titulo: AppLocalizations.of(context)!.statusFilter,
            chips: WorkflowStatus.values
                .map(
                  (WorkflowStatus e) => FilterChipSpec(
                    label: e.localizedLabel(AppLocalizations.of(context)!),
                    seleccionado: estadoTemp == e,
                    onToggle: () =>
                        setModal(() => estadoTemp = estadoTemp == e ? null : e),
                  ),
                )
                .toList(),
          ),
          FilterGrupo(
            titulo: 'Tipo',
            useErrorColor: true,
            chips: TipoReserva.values
                .map(
                  (TipoReserva e) => FilterChipSpec(
                    label: e == TipoReserva.todas ? 'Totes' : (e == TipoReserva.materiales ? 'Materials' : 'Excursions'),
                    seleccionado: tipoTemp == e,
                    onToggle: () =>
                        setModal(() => tipoTemp = tipoTemp == e ? TipoReserva.todas : e),
                  ),
                )
                .toList(),
          ),
        ],
        mostrarFechas: true,
        fechaDesde: desdeTemp,
        fechaHasta: hastaTemp,
        onFechaDesdeChanged: (d) => setModal(() => desdeTemp = d),
        onFechaHastaChanged: (d) => setModal(() => hastaTemp = d),
        onFechasClear: () => setModal(() {
          desdeTemp = null;
          hastaTemp = null;
        }),
        onLimpiar: () => setModal(() {
          estadoTemp = null;
          desdeTemp = null;
          hastaTemp = null;
          tipoTemp = TipoReserva.todas;
        }),
        onApply: () {
          setState(() {
            estadoFiltro = estadoTemp;
            fechaDesde = desdeTemp;
            fechaHasta = hastaTemp;
            tipoFiltro = tipoTemp;
          });
          onApply?.call();
          Navigator.pop(context);
        },
      ),
    );
  }
}
