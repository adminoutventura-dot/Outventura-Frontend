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
          // Mapeo seguro usando las claves del mapa JSON ('code' e 'id_status')
          chips: estadosDisponibles
              .map((dynamic e) {
                final int? idEstado = e['id_status'] as int?;
                final String codeEstado = (e['code'] ?? '') as String;

                // Traducimos el código ('AVAILABLE', etc.) con tus claves de localización
                String labelTraducido = codeEstado;
                if (codeEstado == 'AVAILABLE') labelTraducido = s.statusAvailable;
                if (codeEstado == 'OUT_OF_STOCK') labelTraducido = s.statusOutOfStock;
                if (codeEstado == 'MAINTENANCE') labelTraducido = s.statusMaintenance;
                if (codeEstado == 'OUT_OF_SERVICE') labelTraducido = s.statusOutOfService;
                if (codeEstado == 'UNAVAILABLE') labelTraducido = 'No disponible';
                if (codeEstado == 'DISCONTINUED') labelTraducido = 'Descatalogado';

                return FilterChipSpec(
                  label: labelTraducido,
                  seleccionado: estadoTemp == idEstado,
                  onToggle: () => setModal(() => estadoTemp = estadoTemp == idEstado ? null : idEstado),
                );
              })
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