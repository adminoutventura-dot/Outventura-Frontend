import 'package:flutter/material.dart';

class AppTimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const AppTimeSelector({
    super.key,
    required this.label,
    required this.time,
    required this.onTimeSelected,
  });

  String _formatTime(TimeOfDay t) {
    final String h = t.hour.toString().padLeft(2, '0');
    final String m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
          initialEntryMode: TimePickerEntryMode.input,
          builder: (BuildContext context, Widget? child) {
            final ColorScheme cs = Theme.of(context).colorScheme;

            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  // "Enter time" (texto superior)
                  helpTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant),

                  // Icono de cambio de modo (texto / reloj)
                  entryModeIconColor: cs.onSurfaceVariant,
                  
                  // Fondo de los campos hora/minuto
                  hourMinuteColor: WidgetStateColor.resolveWith(
                    (Set<WidgetState> states) => states.contains(WidgetState.selected)
                        ? cs.primaryContainer.withValues(alpha: 0.5)
                        : cs.onSurfaceVariant.withValues(alpha: 0.15),
                  ),
                ),
              ),
              
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: true, 
                ),
                child: child!,
              ),
            );
          },
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },

      // Botón de selección de hora con vuestra estética corporativa
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_outlined, size: 18, color: cs.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                Text(_formatTime(time), style: tt.labelMedium?.copyWith(color: cs.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}