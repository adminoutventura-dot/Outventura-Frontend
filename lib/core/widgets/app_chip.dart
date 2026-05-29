import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

// Organiza la distribución espacial de los chips con espaciados fijos.
class AppChipWrap extends StatelessWidget {
  final List<Widget> children;

  const AppChipWrap({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}

// Representa un chip de selección única optimizado para estados mutuamente excluyentes.
// Chip que permite una sola selección (ahora con onPressed opcional).
class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback?
  onPressed; 

  final Color? selectedColor;
  final Color? selectedBorderColor;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.seleccionado,
    this.onPressed,
    this.selectedColor,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color selColor = selectedColor ?? cs.tertiary;
    final Color selBorder = selectedBorderColor ?? cs.tertiary;

    return Container(
      padding: seleccionado
          ? const EdgeInsets.all(1.5)
          : const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: seleccionado ? AppGradients.cardAccent(selBorder) : null,
      ),
      child: ChoiceChip(
        label: seleccionado
            ? ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    AppGradients.cardAccent(selColor).createShader(bounds),
                child: Text(label),
              )
            : Text(label),

        selected: seleccionado,
        // Ejecuta el callback solo si no es nulo
        onSelected: (_) {
          if (onPressed != null) onPressed!();
        },
        selectedColor: cs.surface,
        backgroundColor: cs.onPrimary,
        checkmarkColor: selColor,

        // Quita el margen invisible que añade Material Design alrededor del widget
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelStyle: tt.labelMedium?.copyWith(
          color: seleccionado ? selColor : cs.onSurfaceVariant,
        ),
        side: BorderSide(
          color: seleccionado ? Colors.transparent : cs.onSurfaceVariant,
          width: seleccionado ? 0 : 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Representa un chip de selección múltiple interactivo.
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

    final Color selColor = selectedColor ?? cs.primary;
    final Color selBorder = selectedBorderColor ?? cs.primary;

    return Container(
      padding: seleccionado
          ? const EdgeInsets.all(1.5)
          : const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: seleccionado ? AppGradients.cardAccent(selBorder) : null,
      ),
      child: FilterChip(
        label: seleccionado
            ? ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    AppGradients.cardAccent(selColor).createShader(bounds),
                child: Text(label),
              )
            : Text(label),
        selected: seleccionado,
        onSelected: onSelected,
        selectedColor: cs.surface,
        backgroundColor: cs.onPrimary,
        checkmarkColor: selColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelStyle: tt.labelMedium?.copyWith(
          color: seleccionado ? selColor : cs.onSurfaceVariant,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: seleccionado ? Colors.transparent : cs.onSurfaceVariant,
          width: seleccionado ? 0 : 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Control estructural encapsulado para validación y gestión múltiple de categorías.
class AppFilterChipFormField extends StatelessWidget {
  final List<Category> seleccionados;
  final void Function(Category) onToggle;
  final String? Function(List<Category>?)? validator;

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
    final s = AppLocalizations.of(context)!;

    return FormField<List<Category>>(
      initialValue: seleccionados,
      validator: validator,
      builder: (FormFieldState<List<Category>> field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Renderiza de forma dinámica las propiedades iteradas del enum de categorías
          AppChipWrap(
            children: Category.values.map((Category cat) {
              return AppFilterChip(
                label: cat.localizedLabel(s),
                seleccionado: seleccionados.contains(cat),
                onSelected: (_) {
                  onToggle(cat);
                  // Notifica al FormField el cambio estructural para relanzar la validación interactiva
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
