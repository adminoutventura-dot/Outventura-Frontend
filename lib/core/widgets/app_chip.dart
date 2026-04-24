import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

// Grupo de chips que se pueden seleccionar. 
//El AppChipWrap organiza los chips y el AppChoiceChip representa cada chip individual.
class AppChipWrap extends StatelessWidget {
  final List<Widget> children;

  const AppChipWrap({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}

// Chip que se permite una sola selección. 
class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final void Function(bool) onSelected;

  final Color? selectedColor;

  final Color? selectedBorderColor;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onSelected,
    this.selectedColor,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color selColor = selectedColor ?? cs.secondaryContainer;
    final Color selBorder = selectedBorderColor ?? cs.onSecondaryContainer;

    return ChoiceChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: onSelected,
      selectedColor: selColor,
      checkmarkColor: cs.onSurface,
      backgroundColor: cs.onPrimary,
      labelStyle: tt.labelMedium?.copyWith(
        color: seleccionado ? cs.onSurface : cs.onSurfaceVariant,
      ),
      side: BorderSide(
        color: seleccionado ? selBorder : cs.onSurfaceVariant,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// Filter chip para selección múltiple.
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final void Function(bool) onSelected;

  final Color? selectedColor;

  final Color? selectedBorderColor;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onSelected,
    this.selectedColor,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color selColor = selectedColor ?? cs.secondary.withValues(alpha: 0.2);
    final Color selBorder = selectedBorderColor ?? cs.primary;

    return FilterChip(
      label: Text(label),
      // Indica si el chip debe mostrarse como seleccionado o no.
      selected: seleccionado,
      // Callback que se ejecuta cuando el usuario pulsa el chip.
      onSelected: onSelected,
      selectedColor: selColor,
      checkmarkColor: cs.onPrimaryContainer,
      backgroundColor: cs.onPrimary,
      labelStyle: tt.labelMedium?.copyWith(
        color: seleccionado ? cs.onPrimaryContainer : cs.onSurfaceVariant,
      ),
      side: BorderSide(
        color: seleccionado ? selBorder : cs.onSurfaceVariant,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// FormField de selección múltiple con chips que se integra con Form y muestra errores.
class AppFilterChipFormField extends StatelessWidget {
  final List<CategoriaActividad> seleccionados;
  final void Function(CategoriaActividad) onToggle;
  final String? Function(List<CategoriaActividad>?)? validator;

  const AppFilterChipFormField({
    super.key,
    required this.seleccionados,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return FormField<List<CategoriaActividad>>(
      initialValue: seleccionados,
      validator: validator,
      builder: (FormFieldState<List<CategoriaActividad>> field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppChipWrap(
            children: CategoriaActividad.values.map((CategoriaActividad cat) {
              return AppFilterChip(
                label: cat.label,
                seleccionado: seleccionados.contains(cat),
                onSelected: (_) {
                  onToggle(cat);
                  // Le notifica al FormField que su valor ha cambiado, para que pueda re-evaluar la validación.
                  field.didChange(List.from(seleccionados));
                },
              );
            }).toList(),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                field.errorText!,
                style: tt.bodySmall?.copyWith(color: cs.error),
              ),
            ),
        ],
      ),
    );
  }
}