import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/request_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';

class RequestsPageController {

  // Acepta una solicitud después de pedir confirmación al usuario.
  Future<void> aceptar({
    required Solicitud solicitud,
    required BuildContext context,
    required WidgetRef ref,
    required bool Function() isMounted,
  }) async {

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool confirm = await showConfirmDialog(
      context: context,
      title: 'Aceptar solicitud',
      content: '¿Aceptar la solicitud #${solicitud.id}?\nSe generará una excursión automáticamente.',
      confirmLabel: 'Aceptar',
      isDanger: false,
    );

    if (!confirm) {
      return;
    }
    ref.read(solicitudesProvider.notifier).actualizar(
          solicitud,
          solicitud.copyWith(estado: EstadoSolicitud.confirmada),
        );

    if (isMounted()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Solicitud aceptada. Excursión generada.')),
      );
    }
  }

  // Navega a la página de edición de la solicitud. Si el resultado no es nulo, actualiza la solicitud con el resultado.
  Future<void> editar({
    required Solicitud solicitud,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final Solicitud? result = await Navigator.push<Solicitud>(
      context,
      MaterialPageRoute(
        builder: (BuildContext _) => SolicitudFormPage(solicitud: solicitud),
      ),
    );
    
    if (result == null) {
      return;
    }
    ref.read(solicitudesProvider.notifier).actualizar(solicitud, result);
  }

  // Rechaza la solicitud después de pedir confirmación al usuario.
  Future<void> rechazar({
    required Solicitud solicitud,
    required BuildContext context,
    required WidgetRef ref,
    required bool Function() isMounted,
  }) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool confirm = await showConfirmDialog(
      context: context,
      title: 'Rechazar solicitud',
      content: '¿Rechazar la solicitud #${solicitud.id}?',
      confirmLabel: 'Rechazar',
    );
    if (!confirm) {
      return;
    }

    ref.read(solicitudesProvider.notifier).actualizar(
          solicitud,
          solicitud.copyWith(estado: EstadoSolicitud.cancelada),
        );

    if (isMounted()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Solicitud rechazada.')),
      );
    }
  }
}
