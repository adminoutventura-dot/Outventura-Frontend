import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class EquipmentPageController {
  EstadoEquipamiento? estadoFiltro;
  CategoriaActividad? categoriaFiltro;

  bool get hayFiltros => estadoFiltro != null || categoriaFiltro != null;

  void mostrarFiltros(BuildContext context, StateSetter setState) {
    EstadoEquipamiento? estadoTemp = estadoFiltro;
    CategoriaActividad? categoriaTemp = categoriaFiltro;
    final s = AppLocalizations.of(context)!;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: s.statusFilter,
          chips: EstadoEquipamiento.values
              .map((EstadoEquipamiento e) => FilterChipSpec(
                    label: e.localizedLabel(s),
                    seleccionado: estadoTemp == e,
                    onToggle: () => setModal(() => estadoTemp = estadoTemp == e ? null : e),
                  ))
              .toList(),
        ),
        FilterGrupo(
          titulo: s.categoryFilter,
          chips: CategoriaActividad.values
              .map((CategoriaActividad c) => FilterChipSpec(
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
