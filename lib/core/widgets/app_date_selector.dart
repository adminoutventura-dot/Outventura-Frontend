import 'package:flutter/material.dart';

class AppDateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateSelected;

  const AppDateSelector({
    super.key,
    required this.label,
    required this.date,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final formatted = '${date.day} ${_months[date.month - 1]} ${date.year}';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime(2100),
        );
        if (picked != null) onDateSelected(picked);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.onSurfaceVariant.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: cs.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  formatted,
                  style: tt.labelMedium?.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
