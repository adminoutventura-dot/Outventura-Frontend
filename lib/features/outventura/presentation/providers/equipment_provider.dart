import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';

// Expone una lista de equipamientos y métodos para modificarlos
final NotifierProvider<EquipamientosNotifier, List<Equipamiento>> equipamientosProvider =
    NotifierProvider<EquipamientosNotifier, List<Equipamiento>>(
  EquipamientosNotifier.new,
);

class EquipamientosNotifier extends Notifier<List<Equipamiento>> {
  @override
  List<Equipamiento> build() => [...equipamientosFake];

  void agregar(Equipamiento equipamiento) {
    final List<Equipamiento> listaActual = state;
    listaActual.add(equipamiento);
    state = listaActual;
  }

  void actualizar(Equipamiento viejo, Equipamiento nuevo) {
    final List<Equipamiento> listaNueva = [...state];
    final int index = listaNueva.indexOf(viejo);

    if (index != -1) {
      listaNueva[index] = nuevo;
    }

    state = listaNueva;
  }

  void eliminar(Equipamiento equipamiento) {
    final List<Equipamiento> listaNueva = [...state];
    listaNueva.remove(equipamiento);
    state = listaNueva;
  }
}
