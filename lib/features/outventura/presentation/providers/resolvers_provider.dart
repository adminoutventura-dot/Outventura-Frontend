import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/services/resolvers.dart';

// Provider que resuelve el nombre completo de un usuario por su ID.
final nombreUsuarioProvider = Provider.family<String, int>((ref, id) {
  final List<Usuario> usuarios = ref.watch(usuariosProvider).value ?? [];
  return resolverNombreUsuario(id, usuarios);
});

// Provider que resuelve el nombre de una excursión por su ID.
final nombreExcursionProvider = Provider.family<String?, int?>((ref, id) {
  if (id == null) return null;
  final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];
  return resolverNombreExcursion(id, excursiones);
});

// Provider que resuelve el nombre de un equipamiento por su ID.
final nombreEquipamientoProvider = Provider.family<String, int>((ref, id) {
  final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider).value ?? [];
  return resolverNombreEquipamiento(id, equipamientos);
});

// Provider que resuelve la imagen de un equipamiento por su ID.
final imagenEquipamientoProvider = Provider.family<String?, int>((ref, id) {
  final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider).value ?? [];
  return resolverImagenEquipamiento(id, equipamientos);
});

// Provider que resuelve una excursión completa por su ID.
final excursionPorIdProvider = Provider.family<Excursion?, int>((ref, id) {
  final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];
  final int index = excursiones.indexWhere((Excursion e) => e.id == id);
  return index != -1 ? excursiones[index] : null;
});

// Provider que resuelve una reserva completa por su ID.
final reservaPorIdProvider = Provider.family<Reserva?, int>((ref, id) {
  final List<Reserva> reservas = ref.watch(reservasProvider).value ?? [];
  final int index = reservas.indexWhere((Reserva r) => r.id == id);
  return index != -1 ? reservas[index] : null;
});
