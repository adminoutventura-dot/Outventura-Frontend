import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';

class RequestsPageController {
  List<Solicitud> filtrarPorEstado({
    required List<Solicitud> solicitudes,
    required EstadoSolicitud? selectedEstado,
  }) {
    if (selectedEstado == null) {
      return solicitudes;
    }
    return solicitudes.where((Solicitud s) => s.estado == selectedEstado).toList();
  }

  int contarPorEstado({
    required List<Solicitud> solicitudes,
    required EstadoSolicitud estado,
  }) {
    return solicitudes.where((Solicitud s) => s.estado == estado).length;
  }

  Future<Solicitud?> editarSolicitud({
    required BuildContext context,
    required Solicitud solicitud,
  }) {
    return Navigator.push<Solicitud>(
      context,
      MaterialPageRoute(
        builder: (_) => SolicitudFormPage(solicitud: solicitud),
      ),
    );
  }

  Future<bool> aceptarSolicitud({
    required BuildContext context,
    required Solicitud solicitud,
    required List<Solicitud> solicitudes,
  }) async {
    final bool confirm = await showConfirmDialog(
      context: context,
      title: 'Aceptar solicitud',
      content:
          '¿Aceptar la solicitud #${solicitud.id}?\nSe generará una excursión automáticamente.',
      confirmLabel: 'Aceptar',
      isDanger: false,
    );
    if (!confirm) {
      return false;
    }

    reemplazarSolicitud(
      solicitudes: solicitudes,
      current: solicitud,
      updated: solicitud.copyWith(estado: EstadoSolicitud.confirmada),
    );
    return true;
  }

  Future<bool> rechazarSolicitud({
    required BuildContext context,
    required Solicitud solicitud,
    required List<Solicitud> solicitudes,
  }) async {
    final bool confirm = await showConfirmDialog(
      context: context,
      title: 'Rechazar solicitud',
      content: '¿Rechazar la solicitud #${solicitud.id}?',
      confirmLabel: 'Rechazar',
    );
    if (!confirm) {
      return false;
    }

    reemplazarSolicitud(
      solicitudes: solicitudes,
      current: solicitud,
      updated: solicitud.copyWith(estado: EstadoSolicitud.cancelada),
    );
    return true;
  }

  void reemplazarSolicitud({
    required List<Solicitud> solicitudes,
    required Solicitud current,
    required Solicitud updated,
  }) {
    final int index = solicitudes.indexOf(current);
    if (index != -1) {
      solicitudes[index] = updated;
    }
  }
}