import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class EquipmentPageController {
  int? estadoFiltro;
  Category? categoriaFiltro;

  bool get hayFiltros => estadoFiltro != null || categoriaFiltro != null;

  void mostrarFiltros(
    BuildContext context, 
    StateSetter setState, 
    List<dynamic> estadosDisponibles,
    List<Category> categoriasDisponibles, 
  ) {
    int? estadoTemp = estadoFiltro;
    Category? categoriaTemp = categoriaFiltro;
    final s = AppLocalizations.of(context)!;

    mostrarFiltrosSheet(context, (setModal) => FilterBottomSheetContent(
      grupos: [
        FilterGrupo(
          titulo: s.statusFilter,
          chips: estadosDisponibles
              .map((dynamic e) {
                final int? idEstado = (e['id_status'] as int?) ?? (e['id'] as int?);
                final String codeEstado = ((e['code'] as String?) ?? (e['name'] as String?)) ?? '';

                // Traducciones 
                String labelTraducido = codeEstado;
                if (codeEstado == 'AVAILABLE') labelTraducido = s.statusAvailable;
                if (codeEstado == 'OUT_OF_STOCK') labelTraducido = s.statusOutOfStock;
                if (codeEstado == 'MAINTENANCE') labelTraducido = s.statusMaintenance;
                if (codeEstado == 'OUT_OF_SERVICE') labelTraducido = s.statusOutOfService;
                if (codeEstado == 'UNAVAILABLE') labelTraducido = 'No disponible'; 
                if (codeEstado == 'DISCONTINUED') labelTraducido = 'Descatalogado';

                // Si por algún motivo el código llega totalmente vacío, lo marca para depurar
                if (labelTraducido.isEmpty) labelTraducido = 'Desconocido';

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
          chips: categoriasDisponibles
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