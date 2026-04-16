import 'package:flutter/material.dart';

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
  final bool selected;
  final void Function(bool) onSelected;

  final Color? selectedColor;

  final Color? selectedBorderColor;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedColor,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final selColor = selectedColor ?? cs.primaryContainer;
    final selBorder = selectedBorderColor ?? cs.primary;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: selColor,
      backgroundColor: cs.onPrimary,
      labelStyle: tt.labelMedium?.copyWith(
        color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
      ),
      side: BorderSide(
        color: selected ? selBorder : cs.onSurfaceVariant,
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
  final bool selected;
  final void Function(bool) onSelected;

  final Color? selectedColor;

  final Color? selectedBorderColor;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedColor,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final selColor = selectedColor ?? cs.primaryContainer;
    final selBorder = selectedBorderColor ?? cs.primary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: selColor,
      backgroundColor: cs.onPrimary,
      labelStyle: tt.labelMedium?.copyWith(
        color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
      ),
      side: BorderSide(
        color: selected ? selBorder : cs.onSurfaceVariant,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
