import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

// Muestra el diálogo de confirmación para aprobar una reserva.
Future<void> mostrarDialogoAprobacion(
  BuildContext context,
  Reserva r,
  VoidCallback onConfirm,
) async {
  final bool ok = await showConfirmDialog(
    context: context,
    title: 'Aprobar reserva',
    content: '¿Confirmar la reserva #${r.id}?',
    confirmLabel: 'Aprobar',
    isDanger: false,
  );
  if (!context.mounted || !ok) return;
  onConfirm();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Reserva aprobada.')),
  );
}

// Muestra el diálogo de confirmación para rechazar una reserva.
Future<void> mostrarDialogoRechazo(
  BuildContext context,
  Reserva r,
  VoidCallback onConfirm,
) async {
  final bool ok = await showConfirmDialog(
    context: context,
    title: 'Rechazar reserva',
    content: '¿Rechazar la reserva #${r.id}?',
    confirmLabel: 'Rechazar',
  );
  if (!context.mounted || !ok) return;
  onConfirm();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Reserva rechazada.')),
  );
}

// Muestra el diálogo de confirmación para cancelar una reserva.
Future<void> mostrarDialogoCancelacion(
  BuildContext context,
  Reserva r,
  VoidCallback onConfirm,
) async {
  final bool ok = await showConfirmDialog(
    context: context,
    title: 'Cancelar reserva',
    content: '¿Cancelar la reserva #${r.id}?',
    confirmLabel: 'Cancelar reserva',
  );
  if (!context.mounted || !ok) return;
  onConfirm();
}

// Muestra el diálogo para registrar la devolución de una reserva.
Future<void> mostrarDialogoDevolucion(
  BuildContext context,
  Reserva r,
  VoidCallback onConfirm,
) async {
  final bool ok = await showConfirmDialog(
    context: context,
    title: 'Registrar devolución',
    content: '¿Confirmar la devolución de la reserva #${r.id}? Podrás registrar los daños desde el formulario.',
    confirmLabel: 'Confirmar',
    isDanger: false,
  );
  if (!context.mounted || !ok) return;
  onConfirm();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Devolución registrada.')),
  );
}
