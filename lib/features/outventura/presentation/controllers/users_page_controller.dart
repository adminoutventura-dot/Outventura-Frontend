import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class UsersPageController {
  TipoRol? rolFiltro;
  bool? activoFiltro;

  bool get hayFiltros => rolFiltro != null || activoFiltro != null;

  void mostrarFiltros(BuildContext context, StateSetter setState) {
    TipoRol? rolTemp = rolFiltro;
    bool? activoTemp = activoFiltro;
    final s = AppLocalizations.of(context)!;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: s.statusFilter,
          chips: [
            FilterChipSpec(
              label: s.activeFilter,
              seleccionado: activoTemp == true,
              onToggle: () => setModal(() => activoTemp = activoTemp == true ? null : true),
            ),
            FilterChipSpec(
              label: s.inactiveFilter,
              seleccionado: activoTemp == false,
              onToggle: () => setModal(() => activoTemp = activoTemp == false ? null : false),
            ),
          ],
        ),
        FilterGrupo(
          titulo: s.roleFilter,
          chips: TipoRol.values
              .map((TipoRol r) => FilterChipSpec(
                    label: r.localizedLabel(s),
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
