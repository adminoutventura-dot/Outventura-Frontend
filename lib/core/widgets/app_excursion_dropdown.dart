import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

class AppExcursionDropdown extends StatelessWidget {
  final int? value;
  final List<Excursion> excursiones;
  final ValueChanged<int?> onChanged;
  final String label;
  final String hint;
  final String? Function(int?)? validator;

  const AppExcursionDropdown({
    super.key,
    required this.value,
    required this.excursiones,
    required this.onChanged,
    this.label = 'Excursión',
    this.hint = 'Ninguna',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return DropdownButtonFormField<int?>(
      initialValue: value,
      style: TextStyle(color: cs.onSurface),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: cs.primary.withValues(alpha: 0.7),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        prefixIcon: const Icon(Icons.hiking_outlined),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: cs.onSurfaceVariant.withAlpha(50),
            width: 1.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: cs.onSurfaceVariant.withAlpha(50),
            width: 1.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: cs.primary.withAlpha(150),
            width: 2,
          ),
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      ),
      hint: Text(hint, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      items: <DropdownMenuItem<int?>>[
        DropdownMenuItem<int?>(
          value: null,
          child: Text(
            hint,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        for (Excursion e in excursiones)
          DropdownMenuItem<int?>(
            value: e.id,
            child: Text(
              '${e.puntoInicio} → ${e.puntoFin}',
              style: tt.bodyMedium?.copyWith(color: cs.onSurface),
            ),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
