import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';

class UsersPageController {
  TipoRol? rolFiltro;
  bool? activoFiltro;

  bool get hayFiltros => rolFiltro != null || activoFiltro != null;

  void mostrarFiltros(BuildContext context, StateSetter setState) {
    TipoRol? rolTemp = rolFiltro;
    bool? activoTemp = activoFiltro;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: 'Estado',
          chips: [
            FilterChipSpec(
              label: 'Activos',
              seleccionado: activoTemp == true,
              onToggle: () => setModal(() => activoTemp = activoTemp == true ? null : true),
            ),
            FilterChipSpec(
              label: 'Inactivos',
              seleccionado: activoTemp == false,
              onToggle: () => setModal(() => activoTemp = activoTemp == false ? null : false),
            ),
          ],
        ),
        FilterGrupo(
          titulo: 'Rol',
          chips: TipoRol.values
              .map((TipoRol r) => FilterChipSpec(
                    label: r.nombre,
                    seleccionado: rolTemp == r,
                    onToggle: () => setModal(() => rolTemp = rolTemp == r ? null : r),
                  ))
              .toList(),
        ),
      ],
      onLimpiar: () => setModal(() { rolTemp = null; activoTemp = null; }),
      onApply: () {
        setState(() {
          rolFiltro = rolTemp;
          activoFiltro = activoTemp;
        });
        Navigator.pop(context);
      },
    ));
  }
}
