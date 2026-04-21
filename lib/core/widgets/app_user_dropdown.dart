import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

class AppUserDropdown extends StatelessWidget {
  final int? value;
  final List<Usuario> users;
  final ValueChanged<int?> onChanged;
  final String label;
  final String hint;
  final String? Function(int?)? validator;

  const AppUserDropdown({
    super.key,
    required this.value,
    required this.users,
    required this.onChanged,
    this.label = 'Experto asignado',
    this.hint = 'Sin asignar',
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
      
      // Estilo
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
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
        // Indica que el campo no tiene fondo, solo una línea inferior
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
        for (Usuario u in users)
          DropdownMenuItem<int?>(
            value: u.id,
            child: Text(
              '${u.nombre} ${u.apellidos}',
              style: tt.bodyMedium?.copyWith(color: cs.onSurface),
            ),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
