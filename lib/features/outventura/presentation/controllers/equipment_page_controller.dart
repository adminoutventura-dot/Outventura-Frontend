import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class EquipmentPageController {
  int? estadoFiltro;
  Category? categoriaFiltro;

  bool get hayFiltros => estadoFiltro != null || categoriaFiltro != null;

  void mostrarFiltros(BuildContext context, StateSetter setState, List<dynamic> estadosDisponibles) {
    int? estadoTemp = estadoFiltro;
    Category? categoriaTemp = categoriaFiltro;
    final s = AppLocalizations.of(context)!;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: s.statusFilter,
          // Mapea de forma dinámica la lista de estados reales que le inyectamos desde el widget
          chips: estadosDisponibles
              .map((dynamic e) => FilterChipSpec(
                    label: e.name as String, 
                    seleccionado: estadoTemp == e.id,
                    onToggle: () => setModal(() => estadoTemp = estadoTemp == e.id ? null : e.id as int),
                  ))
              .toList(),
        ),
        FilterGrupo(
          titulo: s.categoryFilter,
          chips: Category.values
              .map((Category c) => FilterChipSpec(
                    label: c.localizedLabel(s),
                    seleccionado: categoriaTemp == c,
                    onToggle: () => setModal(() => categoriaTemp = categoriaTemp == c ? null : c),
                  ))
              .toList(),
        ),
      ],
      onLimpiar: () => setModal(() {
        estadoTemp = null;
        categoriaTemp = null;
      }),
      onApply: () {
        setState(() {
          estadoFiltro = estadoTemp;
          categoriaFiltro = categoriaTemp;
        });
        Navigator.pop(context);
      },
    ));
  }
}