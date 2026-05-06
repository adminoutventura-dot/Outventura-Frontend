import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

class ExcursionsPageController {
  EstadoExcursion? estadoFiltro;
  CategoriaActividad? categoriaFiltro;
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  bool get hayFiltros => estadoFiltro != null || categoriaFiltro != null || fechaDesde != null || fechaHasta != null;

  void mostrarFiltros(BuildContext context, StateSetter setState) {
    EstadoExcursion? estadoTemp = estadoFiltro;
    CategoriaActividad? categoriaTemp = categoriaFiltro;
    DateTime? desdeTemp = fechaDesde;
    DateTime? hastaTemp = fechaHasta;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: 'Estado',
          chips: EstadoExcursion.values
              .map((EstadoExcursion e) => FilterChipSpec(
                    label: e.label,
                    seleccionado: estadoTemp == e,
                    onToggle: () => setModal(() => estadoTemp = estadoTemp == e ? null : e),
                  ))
              .toList(),
        ),
        FilterGrupo(
          titulo: 'Categoría',
          chips: CategoriaActividad.values
              .map((CategoriaActividad c) => FilterChipSpec(
                    label: c.label,
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
