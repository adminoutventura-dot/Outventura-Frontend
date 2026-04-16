import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';

// Retorna true si el usuario confirma, false si cancela o cierra el diálogo.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String cancelLabel = 'Cancelar',
  String confirmLabel = 'Eliminar',
  bool isDanger = true,
}) async {
  final cs = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        SecondaryButton(
          label: cancelLabel,
          onPressed: () => Navigator.pop(context, false),
          backgroundColor: cs.surface,
          borderColor: cs.primary,
        ),
        
        const SizedBox(width: 12),
        PrimaryButton(
          label: confirmLabel,
          onPressed: () => Navigator.pop(context, true),
          backgroundColor: isDanger ? cs.error : null,
          icon: isDanger ? Icons.delete_outline : Icons.check,
        ),
      ],
    ),
  );
  return result ?? false;
}
  