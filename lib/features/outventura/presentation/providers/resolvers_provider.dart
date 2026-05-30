import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
import 'package:outventura/features/outventura/services/resolvers.dart';

// Resuelve el nombre completo de un usuario por su ID.
// String -> Valor que devuelve
// int -> Parámetro que recibe
final userNameProvider = Provider.family<String, int>((ref, id) {
  final List<User> usuarios = ref.watch(usuariosProvider).value ?? [];
  return resolverNombreUsuario(id, usuarios);
});

// Resuelve el nombre de una actividad por su ID.
final activityNameProvider = Provider.family<String?, int?>((ref, id) {
  if (id == null) {
    return null;
  }
  final List<Activity> actividades = ref.watch(allActivitiesProvider);
  return resolverNombreActividad(id, actividades);
});

// Resuelve el nombre de un equipamiento por su ID.
final equipmentNameProvider = Provider.family<String, int>((ref, id) {
  final List<Equipment> equipamientos = ref.watch(allEquipmentProvider);
  return resolverNombreEquipamiento(id, equipamientos);
});

// Resuelve la imagen de un equipamiento por su ID.
final equipmentImageProvider = Provider.family<String?, int>((ref, id) {
  final List<Equipment> equipamientos = ref.watch(allEquipmentProvider);
  return resolverImagenEquipamiento(id, equipamientos);
});

// Resuelve una actividad completa por su ID.
final activityByIdProvider = Provider.family<Activity?, int>((ref, id) {
  final List<Activity> actividades = ref.watch(allActivitiesProvider);
  final int index = actividades.indexWhere((Activity e) => e.id == id);
  return index != -1 ? actividades[index] : null;
});

// Resuelve una reserva completa por su ID.
final reservationByIdProvider = Provider.family<Booking?, int>((ref, id) {
  final List<Booking> reservas = ref.watch(reservationsProvider).value ?? [];
  final int index = reservas.indexWhere((Booking r) => r.id == id);
  return index != -1 ? reservas[index] : null;
});

// Resuelve un equipamiento completo por su ID.
final equipmentByIdProvider = Provider.family<Equipment?, int>((ref, id) {
  final List<Equipment> equipamientos = ref.watch(allEquipmentProvider);
  final int index = equipamientos.indexWhere((Equipment e) => e.id == id);
  return index != -1 ? equipamientos[index] : null;
});
