import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/l10n/app_localizations.dart';

// Muestra el diálogo de confirmación para aprobar una reserva.
Future<void> mostrarDialogoAprobacion(
  BuildContext context,
  Booking r,
  VoidCallback onConfirm,
) async {
  final s = AppLocalizations.of(context)!;
  final bool ok = await showConfirmDialog(
    context: context,
    title: s.approveReservation,
    content: s.approveReservationConfirm(r.id),
    confirmLabel: s.approve,
    isDanger: false,
  );
  if (!context.mounted || !ok) return;
  onConfirm();
  showSuccessSnackBar(context, s.reservationApproved);
}

// Muestra el diálogo de confirmación para rechazar una reserva.
Future<void> mostrarDialogoRechazo(
  BuildContext context,
  Booking r,
  VoidCallback onConfirm,
) async {
  final s = AppLocalizations.of(context)!;
  final bool ok = await showConfirmDialog(
    context: context,
    title: s.rejectReservation,
    content: s.rejectReservationConfirm(r.id),
    confirmLabel: s.reject,
  );
  if (!context.mounted || !ok) return;
  onConfirm();
  showSuccessSnackBar(context, s.reservationRejected);
}

// Muestra el diálogo de confirmación para cancelar una reserva.
Future<void> mostrarDialogoCancelacion(
  BuildContext context,
  Booking r,
  VoidCallback onConfirm,
) async {
  final s = AppLocalizations.of(context)!;
  final bool ok = await showConfirmDialog(
    context: context,
    title: s.cancelReservation,
    content: s.cancelReservationConfirm(r.id),
    confirmLabel: s.cancelReservation,
  );
  if (!context.mounted || !ok) return;
  onConfirm();
}

// Muestra el diálogo para registrar la devolución de una reserva.
Future<void> mostrarDialogoDevolucion(
  BuildContext context,
  Booking r,
  VoidCallback onConfirm,
) async {
  final s = AppLocalizations.of(context)!;
  final bool ok = await showConfirmDialog(
    context: context,
    title: s.registerReturn,
    content: s.registerReturnConfirm(r.id),
    confirmLabel: s.confirm,
    isDanger: false,
  );
  if (!context.mounted || !ok) return;
  onConfirm();
  showSuccessSnackBar(context, s.returnRegistered);
}
