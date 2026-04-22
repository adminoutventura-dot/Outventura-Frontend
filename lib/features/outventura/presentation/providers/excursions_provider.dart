import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/fakes/excursions_fake.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

// Expone una lista de excursiones y métodos para modificarlos
final NotifierProvider<ExcursionesNotifier, List<Excursion>> excursionesProvider =
    NotifierProvider<ExcursionesNotifier, List<Excursion>>(
  ExcursionesNotifier.new,
);

class ExcursionesNotifier extends Notifier<List<Excursion>> {
  @override
  List<Excursion> build() => [...catalogoExcursiones];

  void agregar(Excursion excursion) {
    final List<Excursion> listaActual = state;
    listaActual.add(excursion);
    state = listaActual;
  }

  void actualizar(Excursion viejo, Excursion nuevo) {
    final List<Excursion> listaNueva = [...state];
    final int index = listaNueva.indexOf(viejo);

    if (index != -1) {
      listaNueva[index] = nuevo;
    }

    state = listaNueva;
  }

  void eliminar(Excursion excursion) {
    final List<Excursion> listaNueva = [...state];
    listaNueva.remove(excursion);
    state = listaNueva;
  }

}
