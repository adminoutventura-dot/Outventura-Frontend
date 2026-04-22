import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/fakes/requests_fake.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

// Expone una lista de solicitudes y métodos para modificarlas
final NotifierProvider<SolicitudesNotifier, List<Solicitud>> solicitudesProvider =
    NotifierProvider<SolicitudesNotifier, List<Solicitud>>(
  SolicitudesNotifier.new,
);

class SolicitudesNotifier extends Notifier<List<Solicitud>> {
  @override
  List<Solicitud> build() => [...solicitudesFake];

  void agregar(Solicitud solicitud) {
    final List<Solicitud> listaActual = state;
    listaActual.add(solicitud);
    state = listaActual;
  }

  void actualizar(Solicitud viejo, Solicitud nuevo) {
    final List<Solicitud> listaNueva = [...state];
    final int index = listaNueva.indexOf(viejo);

    if (index != -1) {
      listaNueva[index] = nuevo;
    }

    state = listaNueva;
  }

  void eliminar(Solicitud solicitud) {
    final List<Solicitud> listaNueva = [...state];
    listaNueva.remove(solicitud);
    state = listaNueva;
  }

  // int contarPorEstado(EstadoSolicitud estado) {
  //   int contador = 0;

  //   for (final Solicitud solicitud in state) {
  //     if (solicitud.estado == estado) {
  //       contador++;
  //     }
  //   }

  //   return contador;
  // }
}
