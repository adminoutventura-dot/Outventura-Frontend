import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/data/fakes/reservations_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';

// Expone una lista de reservas y métodos para modificarlas
final NotifierProvider<ReservasNotifier, List<Reserva>> reservasProvider =
    NotifierProvider<ReservasNotifier, List<Reserva>>(
  ReservasNotifier.new,
);

class ReservasNotifier extends Notifier<List<Reserva>> {
  @override
  List<Reserva> build() => [...reservasFake];

  // CRUD 
  void agregar(Reserva reserva) {
    final List<Reserva> listaActual = state;
    listaActual.add(reserva);
    state = listaActual;
  }

  void actualizar(Reserva viejo, Reserva nuevo) {
    final List<Reserva> listaNueva = [...state];
    final int index = listaNueva.indexOf(viejo);

    if (index != -1) {
      listaNueva[index] = nuevo;
    }

    state = listaNueva;
  }

  void eliminar(Reserva reserva) {
    final List<Reserva> listaNueva = [...state];
    listaNueva.remove(reserva);
    state = listaNueva;
  }

  //  Acciones 
  void aprobar(Reserva reserva) {
    // Crea una nueva reserva con el mismo contenido pero con estado confirmado
    final Reserva reservaAprobada = reserva.copyWith(estado: EstadoReserva.confirmada);
    // Actualiza la reserva antigua por la nueva
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

  // TODO: Pueden ir en un archivo service/resolvers.dart
  // Resolvers
  String nombreEquipamiento(int id) {
    final List<Equipamiento> equipamientos = ref.read(equipamientosProvider);
    final int index = equipamientos.indexWhere((Equipamiento equip) => equip.id == id);
    if (index == -1) {
      return 'Desconocido';
    }
    return equipamientos[index].nombre;
  }

  String? imagenEquipamiento(int id) {
    final List<Equipamiento> equipamientos = ref.read(equipamientosProvider);
    final int index = equipamientos.indexWhere((Equipamiento equip) => equip.id == id);
    if (index == -1) {
      return null;
    }
    return equipamientos[index].imagenAsset;
  }

  String nombreUsuario(int id) {
    final List<Usuario> usuarios = ref.read(usuariosProvider);
    final int index = usuarios.indexWhere((Usuario usuario) => usuario.id == id);
    if (index == -1) {
      return 'Usuario desconocido';
    }
    final Usuario usuario = usuarios[index];
    return '${usuario.nombre} ${usuario.apellidos}';
  }

  // Devuelve el nombre de la excursión en formato "PuntoInicio → PuntoFin"
  String? nombreExcursion(int? id) {
    if (id == null) {
      return null;
    }
    final List<Excursion> excursiones = ref.read(excursionesProvider);

    final int index = excursiones.indexWhere((Excursion excursion) => excursion.id == id);
    if (index == -1) {
      return null;
    }
    
    final Excursion excursion = excursiones[index];

    return '${excursion.puntoInicio} → ${excursion.puntoFin}';
  }

}
