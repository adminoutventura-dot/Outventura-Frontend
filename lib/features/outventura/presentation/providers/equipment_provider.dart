import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

final NotifierProvider<EquipamientosNotifier, List<Equipamiento>> equipamientosProvider =
    NotifierProvider<EquipamientosNotifier, List<Equipamiento>>(
  EquipamientosNotifier.new,
);

class EquipamientosNotifier extends Notifier<List<Equipamiento>> {
  @override
  List<Equipamiento> build() => <Equipamiento>[...equipamientosFake];

  void agregar(Equipamiento equipamiento) {
    final List<Equipamiento> listaActual = state;
    final List<Equipamiento> listaNueva = <Equipamiento>[...listaActual, equipamiento];
    state = listaNueva;
  }

  void actualizar(Equipamiento viejo, Equipamiento nuevo) {
    final List<Equipamiento> listaActual = state;
    final List<Equipamiento> listaNueva = <Equipamiento>[];

    for (final Equipamiento equipamiento in listaActual) {
      if (equipamiento == viejo) {
        listaNueva.add(nuevo);
      } else {
        listaNueva.add(equipamiento);
      }
    }

    state = listaNueva;
  }

  void eliminar(Equipamiento equipamiento) {
    final List<Equipamiento> listaActual = state;
    final List<Equipamiento> listaNueva = <Equipamiento>[];

    for (final Equipamiento item in listaActual) {
      if (item != equipamiento) {
        listaNueva.add(item);
      }
    }

    state = listaNueva;
  }
}
