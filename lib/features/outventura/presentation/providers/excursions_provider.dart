import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/fakes/excursions_fake.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';

final NotifierProvider<ExcursionesNotifier, List<Excursion>> excursionesProvider =
    NotifierProvider<ExcursionesNotifier, List<Excursion>>(
  ExcursionesNotifier.new,
);

class ExcursionesNotifier extends Notifier<List<Excursion>> {
  @override
  List<Excursion> build() => <Excursion>[...catalogoExcursiones];

  void agregar(Excursion excursion) {
    final List<Excursion> listaActual = state;
    final List<Excursion> listaNueva = <Excursion>[...listaActual, excursion];
    state = listaNueva;
  }

  void actualizar(Excursion viejo, Excursion nuevo) {
    final List<Excursion> listaActual = state;
    final List<Excursion> listaNueva = <Excursion>[];

    for (final Excursion excursion in listaActual) {
      if (excursion == viejo) {
        listaNueva.add(nuevo);
      } else {
        listaNueva.add(excursion);
      }
    }

    state = listaNueva;
  }

  void eliminar(Excursion excursion) {
    final List<Excursion> listaActual = state;
    final List<Excursion> listaNueva = <Excursion>[];

    for (final Excursion item in listaActual) {
      if (item != excursion) {
        listaNueva.add(item);
      }
    }

    state = listaNueva;
  }
}
