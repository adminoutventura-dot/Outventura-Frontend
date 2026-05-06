import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

class EquipmentPageController {
  EstadoEquipamiento? estadoFiltro;
  CategoriaActividad? categoriaFiltro;

  bool get hayFiltros => estadoFiltro != null || categoriaFiltro != null;

  void mostrarFiltros(BuildContext context, StateSetter setState) {
    EstadoEquipamiento? estadoTemp = estadoFiltro;
    CategoriaActividad? categoriaTemp = categoriaFiltro;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: 'Estado',
          chips: EstadoEquipamiento.values
              .map((EstadoEquipamiento e) => FilterChipSpec(
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
