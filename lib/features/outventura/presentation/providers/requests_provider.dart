import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/fakes/requests_fake.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

final NotifierProvider<SolicitudesNotifier, List<Solicitud>> solicitudesProvider =
    NotifierProvider<SolicitudesNotifier, List<Solicitud>>(
  SolicitudesNotifier.new,
);

class SolicitudesNotifier extends Notifier<List<Solicitud>> {
  @override
  List<Solicitud> build() => <Solicitud>[...solicitudesFake];

  void agregar(Solicitud solicitud) {
    final List<Solicitud> listaActual = state;
    final List<Solicitud> listaNueva = <Solicitud>[...listaActual, solicitud];
    state = listaNueva;
  }

  void actualizar(Solicitud viejo, Solicitud nuevo) {
    final List<Solicitud> listaActual = state;
    final List<Solicitud> listaNueva = <Solicitud>[];

    for (final Solicitud solicitud in listaActual) {
      if (solicitud == viejo) {
        listaNueva.add(nuevo);
      } else {
        listaNueva.add(solicitud);
      }
    }

    state = listaNueva;
  }

  void eliminar(Solicitud solicitud) {
    final List<Solicitud> listaActual = state;
    final List<Solicitud> listaNueva = <Solicitud>[];

    for (final Solicitud item in listaActual) {
      if (item != solicitud) {
        listaNueva.add(item);
      }
    }

    state = listaNueva;
  }

  int contarPorEstado(EstadoSolicitud estado) {
    int contador = 0;

    for (final Solicitud solicitud in state) {
      if (solicitud.estado == estado) {
        contador++;
      }
    }

    return contador;
  }
}
