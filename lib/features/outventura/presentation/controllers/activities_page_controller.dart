import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class ActivitiesPageController {
  ActivityStatus? estadoFiltro;
  ActivityCategory? categoriaFiltro;
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  bool get hayFiltros => estadoFiltro != null || categoriaFiltro != null || fechaDesde != null || fechaHasta != null;

  void mostrarFiltros(BuildContext context, StateSetter setState) {
    ActivityStatus? estadoTemp = estadoFiltro;
    ActivityCategory? categoriaTemp = categoriaFiltro;
    DateTime? desdeTemp = fechaDesde;
    DateTime? hastaTemp = fechaHasta;
    final s = AppLocalizations.of(context)!;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: s.statusFilter,
          chips: ActivityStatus.values
              .map((ActivityStatus e) => FilterChipSpec(
                    label: e.localizedLabel(s),
                    seleccionado: estadoTemp == e,
                    onToggle: () => setModal(() => estadoTemp = estadoTemp == e ? null : e),
                  ))
              .toList(),
        ),
        FilterGrupo(
          titulo: s.categoryFilter,
          chips: ActivityCategory.values
              .map((ActivityCategory c) => FilterChipSpec(
                    label: c.localizedLabel(s),
                    seleccionado: categoriaTemp == c,
                    onToggle: () => setModal(() => categoriaTemp = categoriaTemp == c ? null : c),
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
        categoriaTemp = null;
        desdeTemp = null;
        hastaTemp = null;
      }),
      onApply: () {
        setState(() {
          estadoFiltro = estadoTemp;
          categoriaFiltro = categoriaTemp;
          fechaDesde = desdeTemp;
          fechaHasta = hastaTemp;
        });
        Navigator.pop(context);
      },
    ));
  }
}
