import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/filter_date_range_row.dart';
import 'package:outventura/l10n/app_localizations.dart';

// Especificación de un chip individual dentro de un grupo de filtros.
class FilterChipSpec {
  final String label;
  final bool seleccionado;
  final VoidCallback onToggle;

  const FilterChipSpec({
    required this.label,
    required this.seleccionado,
    required this.onToggle,
  });
}

// Grupo de chips de filtro con título de sección.
class FilterGrupo {
  final String titulo;
  final List<FilterChipSpec> chips;

  const FilterGrupo({required this.titulo, required this.chips});
}

// Panel de filtros 
class FilterBottomSheetContent extends StatelessWidget {
  const FilterBottomSheetContent({
    super.key,
    required this.grupos,
    this.mostrarFechas = false,
    this.fechaDesde,
    this.fechaHasta,
    this.onFechaDesdeChanged,
    this.onFechaHastaChanged,
    this.onFechasClear,
    required this.onLimpiar,
    required this.onApply,
  });

  final List<FilterGrupo> grupos;
  final bool mostrarFechas;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final ValueChanged<DateTime>? onFechaDesdeChanged;
  final ValueChanged<DateTime>? onFechaHastaChanged;
  final VoidCallback? onFechasClear;
  final VoidCallback onLimpiar;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB( 20, 12, 20, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cabecera: título + botón limpiar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.filtersTitle,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TertiaryButton(
                label: s.clearAll,
                onPressed: onLimpiar,
                icon: Icons.clear_all,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grupos de chips
          for (final FilterGrupo grupo in grupos) ...[
            Text(
              grupo.titulo.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            AppChipWrap(
              children: grupo.chips
                  .map(
                    (FilterChipSpec spec) => AppFilterChip(
                      label: spec.label,
                      seleccionado: spec.seleccionado,
                      onSelected: (_) => spec.onToggle(),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Rango de fechas (opcional)
          if (mostrarFechas) ...[
            Text(
              s.dates,
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            FilterDateRangeRow(
              start: fechaDesde,
              end: fechaHasta,
              onStartChanged: onFechaDesdeChanged!,
              onEndChanged: onFechaHastaChanged!,
              onClear: onFechasClear!,
            ),
            const SizedBox(height: 16),
          ],

          // Botón aplicar
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(label: s.applyFilters, onPressed: onApply),
          ),
        ],
      ),
    );
  }
}

// Abre el bottom-sheet de filtros
Future<void> mostrarFiltrosSheet(
  BuildContext context,
  FilterBottomSheetContent Function(StateSetter setModal) builder,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext ctx) => StatefulBuilder(
      builder: (_, StateSetter setModal) => builder(setModal),
    ),
  );
}
