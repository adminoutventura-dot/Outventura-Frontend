import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';

// Fila de selección de rango de fechas (Desde / Hasta) usada dentro del panel de filtros.
class FilterDateRangeRow extends StatelessWidget {
  const FilterDateRangeRow({
    super.key,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onClear,
  });

  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;
  final VoidCallback onClear;

  // Funcion que abre el date picker y llama a [onSelected] si el usuario elige una fecha.
  Future<void> _pickDate(
    BuildContext context, {
    required DateTime? firstDate,
    required DateTime? lastDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    // Cuando el padre actualiza start o end y reconstruye el widget, 
    // build se vuelve a ejecutar y hasAny se recalcula con los nuevos valores.
    final bool hasAny = start != null || end != null;

    return Row(
      children: [
        // Slot "Desde": muestra AppDateSelector si hay fecha, o botón vacío si no
        Expanded(
          child: start != null
              ? AppDateSelector(
                  label: 'Desde',
                  date: start!,
                  lastDate: end,
                  onDateSelected: onStartChanged,
                )
              : SecondaryButton(
                  label: 'Desde',
                  icon: Icons.calendar_today_outlined,
                  onPressed: () => _pickDate(
                    context,
                    firstDate: null,
                    lastDate: end,
                    onSelected: onStartChanged,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        // Slot "Hasta": igual que "Desde" pero respeta la fecha de inicio como mínimo
        Expanded(
          child: end != null
              ? AppDateSelector(
                  label: 'Hasta',
                  date: end!,
                  firstDate: start,
                  onDateSelected: onEndChanged,
                )
              : SecondaryButton(
                  label: 'Hasta',
                  icon: Icons.calendar_today_outlined,
                  onPressed: () => _pickDate(
                    context,
                    firstDate: start,
                    lastDate: null,
                    onSelected: onEndChanged,
                  ),
                ),
        ),
        // Botón limpiar: solo visible cuando hay al menos una fecha seleccionada
        if (hasAny)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Limpiar fechas',
            onPressed: onClear,
          ),
      ],
    );
  }
}

