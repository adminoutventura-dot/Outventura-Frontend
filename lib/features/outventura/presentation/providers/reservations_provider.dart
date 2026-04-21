import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/data/fakes/reservations_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';

final NotifierProvider<ReservasNotifier, List<Reserva>> reservasProvider =
    NotifierProvider<ReservasNotifier, List<Reserva>>(
  ReservasNotifier.new,
);

class ReservasNotifier extends Notifier<List<Reserva>> {
  // TODO: Revisar
  @override
  List<Reserva> build() => <Reserva>[...reservasFake];

  // CRUD 
  void agregar(Reserva reserva) {
    final List<Reserva> listaActual = state;
    final List<Reserva> listaNueva = <Reserva>[...listaActual, reserva];
    state = listaNueva;
  }

  void actualizar(Reserva viejo, Reserva nuevo) {
    final List<Reserva> listaActual = state;
    final List<Reserva> listaNueva = <Reserva>[];

    for (final Reserva reserva in listaActual) {
      if (reserva == viejo) {
        listaNueva.add(nuevo);
      } else {
        listaNueva.add(reserva);
      }
    }

    state = listaNueva;
  }

  void eliminar(Reserva reserva) {
    final List<Reserva> listaActual = state;
    final List<Reserva> listaNueva = <Reserva>[];

    for (final Reserva item in listaActual) {
      if (item != reserva) {
        listaNueva.add(item);
      }
    }

    state = listaNueva;
  }

  //  Acciones 
  void aprobar(Reserva reserva) {
    final Reserva reservaAprobada = reserva.copyWith(estado: EstadoReserva.confirmada);
    actualizar(reserva, reservaAprobada);
  }

  void rechazar(Reserva reserva) {
    final Reserva reservaRechazada = reserva.copyWith(estado: EstadoReserva.cancelada);
    actualizar(reserva, reservaRechazada);
  }

  void cancelar(Reserva reserva) {
    final Reserva reservaCancelada = reserva.copyWith(estado: EstadoReserva.cancelada);
    actualizar(reserva, reservaCancelada);
  }

  void registrarDevolucion(Reserva reserva) {
    final Reserva reservaDevuelta = reserva.copyWith(estado: EstadoReserva.devuelta);
    actualizar(reserva, reservaDevuelta);
  }

  // Resolvers

  String nombreEquipamiento(int id) {
    final List<Equipamiento> equipamientos = ref.read(equipamientosProvider);
    return equipamientos
        .firstWhere((Equipamiento m) => m.id == id, orElse: () => equipamientos.first)
        .nombre;
  }

  String? imagenEquipamiento(int id) {
    final List<Equipamiento> equipamientos = ref.read(equipamientosProvider);
    return equipamientos
        .firstWhere((Equipamiento m) => m.id == id, orElse: () => equipamientos.first)
        .imagenAsset;
  }

  String nombreUsuario(int id) {
    final List<Usuario> usuarios = ref.read(usuariosProvider);
    final Usuario u = usuarios.firstWhere((Usuario u) => u.id == id, orElse: () => usuarios.first);
    return '${u.nombre} ${u.apellidos}';
  }

  String? nombreExcursion(int? id) {
    if (id == null) return null;
    final List<Excursion> excursiones = ref.read(excursionesProvider);
    final Excursion ex = excursiones.firstWhere((Excursion e) => e.id == id, orElse: () => excursiones.first);
    return '${ex.puntoInicio} → ${ex.puntoFin}';
  }

  int contarPorEstado(EstadoReserva estado) {
    int contador = 0;

    for (final Reserva reserva in state) {
      if (reserva.estado == estado) {
        contador++;
      }
    }

    return contador;
  }
}
