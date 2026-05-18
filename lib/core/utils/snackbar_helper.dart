import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, Object error) {
  final String mensaje = error.toString().replaceFirst('Exception: ', '');

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    ),
  );
}

/// Muestra un SnackBar con un mensaje de éxito.
void showSuccessSnackBar(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Theme.of(context).colorScheme.primary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}

// Muestra un diálogo de error con un título y un mensaje.
// void showErrorDialog(
//   BuildContext context, {
//   String title = 'Error',
//   required String message,
// }) {
//   showDialog<void>(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: Text(title),
//       content: Text(message),
//       actions: [
//         TextButton(
//           onPressed: Navigator.of(context).pop,
//           child: const Text('OK'),
//         ),
//       ],
//     ),
//   );
// }
