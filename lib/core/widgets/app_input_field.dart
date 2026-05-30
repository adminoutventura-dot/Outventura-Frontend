import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool enabled; // 🌟 1. Añadimos la propiedad enabled

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true, // 🌟 2. Por defecto estará activo (true)
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled, // 🌟 3. Se lo pasamos al TextFormField
      style: textTheme.bodyMedium?.copyWith(
        // Cambia el color del texto si está deshabilitado para que se note el modo lectura
        color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withAlpha(120),
      ),
      
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: textTheme.bodySmall?.copyWith(
          color: enabled ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withAlpha(120),
        ),
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: colorScheme.primary.withAlpha(enabled ? 150 : 80), size: 22) 
            : null,
        suffixIcon: suffixIcon,

        // Estilo de los bordes
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.onSurfaceVariant.withAlpha(50), width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primaryContainer, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.onSurfaceVariant.withAlpha(50), width: 1.5),
        ),
        // Estilo especial cuando el campo esté deshabilitado en modo lectura
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.onSurfaceVariant.withAlpha(20), width: 1.5),
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      ),
    );
  }
}