import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final int? value;
  final List<T> items;
  final int? Function(T) itemValue;
  final String Function(T) itemLabel;
  final ValueChanged<int?> onChanged;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(int?)? validator;
  final bool isRequired;
  final String? errorText;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.itemValue,
    required this.itemLabel,
    required this.onChanged,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.validator,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return DropdownButtonFormField<int?>(
      initialValue: value,
      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: cs.primary.withValues(alpha: 0.7),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: cs.primary.withAlpha(150), size: 22)
            : null,
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
            color: cs.primaryContainer,
            width: 2,
          ),
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        errorText: errorText,
      ),
      hint: Text(hint, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(hint, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ),
        for (final T item in items)
          DropdownMenuItem<int?>(
            value: itemValue(item),
            child: Text(itemLabel(item), style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
          ),
      ],
      onChanged: onChanged,
      validator: validator ?? (isRequired ? (int? v) => v == null ? 'Selecciona una opción' : null : null),
    );
  }
}
