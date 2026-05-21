import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';

// --- Funciones de resolución ---

// Resuelve el nombre completo de un usuario por su ID.
String resolverNombreUsuario(int id, List<User> usuarios) {
  final int index = usuarios.indexWhere((User u) => u.id == id);
  if (index == -1) return 'Usuario desconocido';
  final User u = usuarios[index];
  return '${u.name} ${u.surname}';
}

// Resuelve el nombre de una actividad por su ID (formato "PuntoInicio → PuntoFin").
String? resolverNombreActividad(int? id, List<Activity> actividades) {
  if (id == null) return null;
  final int index = actividades.indexWhere((Activity e) => e.id == id);
  if (index == -1) return null;
  final Activity e = actividades[index];
  return '${e.startPoint} → ${e.endPoint}';
}

// Resuelve el nombre de un equipamiento por su ID.
String resolverNombreEquipamiento(int id, List<Equipment> equipamientos) {
  final int index = equipamientos.indexWhere((Equipment e) => e.id == id);
  return index != -1 ? equipamientos[index].title : 'Desconocido';
}

// Resuelve la imagen de un equipamiento por su ID.
String? resolverImagenEquipamiento(int id, List<Equipment> equipamientos) {
  final int index = equipamientos.indexWhere((Equipment e) => e.id == id);
  return index != -1 ? equipamientos[index].imageAsset : null;
}
