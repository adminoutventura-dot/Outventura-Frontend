import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/l10n/app_localizations.dart';

// Muestra el diálogo de confirmación para aprobar una reserva.
Future<void> mostrarDialogoAprobacion(
  BuildContext context,
  Booking r,
  Future<void> Function() onConfirm,
) async {
  final s = AppLocalizations.of(context)!;
  final bool ok = await showConfirmDialog(
    context: context,
    title: s.approveReservation,
    content: s.approveReservationConfirm,
    confirmLabel: s.approve,
    isDanger: false,
  );
  if (!context.mounted || !ok) return;
  try {
    await onConfirm();
    if (!context.mounted) return;
    showSuccessSnackBar(context, s.reservationApproved);
  } catch (e) {
    if (!context.mounted) return;
    showErrorSnackBar(context, e.toString());
  }
}

// Muestra el diálogo de confirmación para rechazar una reserva.
Future<void> mostrarDialogoRechazo(
  BuildContext context,
  Booking r,
  Future<void> Function() onConfirm,
) async {
  final s = AppLocalizations.of(context)!;
  final bool ok = await showConfirmDialog(
    context: context,
    title: s.rejectReservation,
    content: s.rejectReservationConfirm,
    confirmLabel: s.reject,
  );
  if (!context.mounted || !ok) return;
  try {
    await onConfirm();
    if (!context.mounted) return;
    showSuccessSnackBar(context, s.reservationRejected);
  } catch (e) {
    if (!context.mounted) return;
    showErrorSnackBar(context, e.toString());
  }
}

// Muestra el diálogo de confirmación para cancelar una reserva.
Future<void> mostrarDialogoCancelacion(
  BuildContext context,
  Booking r,
  Future<void> Function() onConfirm,
) async {
  final s = AppLocalizations.of(context)!;
  final bool ok = await showConfirmDialog(
    context: context,
    title: s.cancelReservation,
    content: s.cancelReservationConfirm,
    confirmLabel: s.cancelReservation,
  );
  if (!context.mounted || !ok) return;
  try {
    await onConfirm();
  } catch (e) {
    if (!context.mounted) return;
    showErrorSnackBar(context, e.toString());
  }
}

// Muestra el diálogo para registrar la devolución de una reserva.
Future<void> mostrarDialogoDevolucion(
  BuildContext context,
  Booking r,
  Future<void> Function() onConfirm,
) async {
  final s = AppLocalizations.of(context)!;
  final bool ok = await showConfirmDialog(
    context: context,
    title: s.registerReturn,
    content: s.registerReturnConfirm,
    confirmLabel: s.confirm,
    isDanger: false,
  );
  if (!context.mounted || !ok) return;
  try {
    await onConfirm();
    if (!context.mounted) return;
    showSuccessSnackBar(context, s.returnRegistered);
  } catch (e) {
    if (!context.mounted) return;
    showErrorSnackBar(context, e.toString());
  }
}
