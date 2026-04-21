import 'package:flutter/material.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/data/fakes/excursions_fake.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/data/fakes/reservations_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';

class ReservationsController extends ChangeNotifier {
  // TODO: Revisar
  EstadoReserva? filtro;

  List<Reserva> get filtradas {
    if (filtro == null) {
      return List<Reserva>.unmodifiable(reservasFake);
    }
    return reservasFake.where((r) => r.estado == filtro).toList();
  }

  void establecerFiltro(EstadoReserva? value) {
    filtro = value;
    notifyListeners();
  }

  // Resolvers

  String nombreEquipamiento(int id) {
    final List<Equipamiento> coincidencias = equipamientosFake.where((m) => m.id == id).toList();
    if (coincidencias.isNotEmpty) {
      return coincidencias.first.nombre;
    }

    if (equipamientosFake.isNotEmpty) {
      return equipamientosFake.first.nombre;
    }

    return '';
  }

  String? imagenEquipamiento(int id) {
    final List<Equipamiento> coincidencias = equipamientosFake.where((m) => m.id == id).toList();
    if (coincidencias.isNotEmpty) {
      return coincidencias.first.imagenAsset;
    }

    if (equipamientosFake.isNotEmpty) {
      return equipamientosFake.first.imagenAsset;
    }

    return null;
  }

  String nombreUsuario(int id) {
    final List<Usuario> coincidencias = usuariosFake.where((u) => u.id == id).toList();
    if (coincidencias.isNotEmpty) {
      final Usuario u = coincidencias.first;
      return '${u.nombre} ${u.apellidos}';
    }

    if (usuariosFake.isNotEmpty) {
      final Usuario u = usuariosFake.first;
      return '${u.nombre} ${u.apellidos}';
    }

    return '';
  }

  String? nombreExcursion(int? id) {
    if (id == null) {
      return null;
    }

    final List<Excursion> coincidencias = catalogoExcursiones.where((e) => e.id == id).toList();
    if (coincidencias.isNotEmpty) {
      final Excursion ex = coincidencias.first;
      return '${ex.puntoInicio} → ${ex.puntoFin}';
    }

    if (catalogoExcursiones.isNotEmpty) {
      final Excursion ex = catalogoExcursiones.first;
      return '${ex.puntoInicio} → ${ex.puntoFin}';
    }

    return null;
  }

  int contarPorEstado(EstadoReserva estado) {
    int total = 0;
    for (final Reserva r in reservasFake) {
      if (r.estado == estado) {
        total++;
      }
    }
    return total;
  }

  // Devuelve los datos resueltos de cada línea para mostrar en el diálogo.
  List<({String nombre, double cargoPorDanio, int cantidad, int idEquipamiento})> lineasResueltas(Reserva r) {
    return r.lineas.map((LineaReserva l) {
      final Equipamiento eq = equipamientosFake.firstWhere(
        (Equipamiento e) => e.id == l.idEquipamiento,
        orElse: () => equipamientosFake.first,
      );
      return (nombre: eq.nombre, cargoPorDanio: eq.cargoPorDanio, cantidad: l.cantidad, idEquipamiento: l.idEquipamiento);
    }).toList();
  }

  // Acciones

  void aprobar(Reserva r) {
    _cambiarEstado(r, EstadoReserva.confirmada);
  }

  void rechazar(Reserva r) {
    _cambiarEstado(r, EstadoReserva.cancelada);
  }

  void cancelar(Reserva r) {
    _cambiarEstado(r, EstadoReserva.cancelada);
  }

  void registrarDevolucion(Reserva r) {
    _cambiarEstado(r, EstadoReserva.devuelta);
  }

  void _cambiarEstado(Reserva reserva, EstadoReserva nuevoEstado) {
    final Reserva actualizada = reserva.copyWith(estado: nuevoEstado);
    editar(reserva, actualizada);
  }

  void editar(Reserva old, Reserva nuevo) {
    final int i = reservasFake.indexOf(old);

    if (i == -1) {
      return;
    }

    reservasFake[i] = nuevo;
    notifyListeners();
  }
}
