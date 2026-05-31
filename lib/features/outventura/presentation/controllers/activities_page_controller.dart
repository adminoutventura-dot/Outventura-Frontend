import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class ActivitiesPageController {
  Category? categoriaFiltro;
  int? dificultadFiltro;
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  bool get hayFiltros =>
      categoriaFiltro != null ||
      dificultadFiltro != null ||
      fechaDesde != null ||
      fechaHasta != null;

  void mostrarFiltros(
    BuildContext context, 
    StateSetter setState,
    List<Category> categoriasDisponibles,
    List<int> dificultadesDisponibles,
  ) {
    Category? categoriaTemp = categoriaFiltro;
    int? dificultadTemp = dificultadFiltro;
    DateTime? desdeTemp = fechaDesde;
    DateTime? hastaTemp = fechaHasta;
    final s = AppLocalizations.of(context)!;

    mostrarFiltrosSheet(
      context,
      (setModal) => FilterBottomSheetContent(
        grupos: [
          FilterGrupo(
            titulo: s.categoryFilter,
            chips: categoriasDisponibles
                .map(
                  (Category c) => FilterChipSpec(
                    label: c.localizedLabel(s),
                    seleccionado: categoriaTemp == c,
                    onToggle: () => setModal(
                      () => categoriaTemp = categoriaTemp == c ? null : c,
                    ),
                  ),
                )
                .toList(),
          ),
          FilterGrupo(
            titulo: s.difficulty,
            chips: dificultadesDisponibles
                .map(
                  (int d) => FilterChipSpec(
                    label: '${s.level} $d',
                    seleccionado: dificultadTemp == d,
                    onToggle: () => setModal(
                      () => dificultadTemp = dificultadTemp == d ? null : d,
                    ),
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
          categoriaTemp = null;
          dificultadTemp = null;
          desdeTemp = null;
          hastaTemp = null;
        }),
        onApply: () {
          setState(() {
            categoriaFiltro = categoriaTemp;
            dificultadFiltro = dificultadTemp;
            fechaDesde = desdeTemp;
            fechaHasta = hastaTemp;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}